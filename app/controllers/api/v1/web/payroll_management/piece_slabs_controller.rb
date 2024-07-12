class Api::V1::Web::PayrollManagement::PieceSlabsController < ApplicationController

  before_action :set_piece_slab, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @piece_slabs = PieceSlab.all.order('id DESC')
    else
      @piece_slabs = PieceSlab.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/payroll_management/piece_slabs/index'
  end

  def filter_data
    @piece_slabs = PieceSlab.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/payroll_management/piece_slabs/index'
  end

  def create
    @piece_slab       = PieceSlab.new piece_slab_params
    if @piece_slab.save
      save_or_update_piece_slab_detail
      render json:{}, status: :created
    else
      render json: {errors: @piece_slab.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/payroll_management/piece_slabs/show'
  end

  def update
    if @piece_slab.update(piece_slab_params)
      save_or_update_piece_slab_detail
      render json: {}, status: 204
    else
      render json: {errors: @piece_slab.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
    if @piece_slab.destroy
      render json: {}, status: 204
    else
      render json: {errors: @piece_slab.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy_piece_slab_detail
    piece_slab_detail = PieceSlabDetail.find params[:piece_slab_detail_id]
    piece_slab_detail.destroy
    render json: {}, status: 204
  end

  private

  def piece_slab_params
    params.permit(:company_id, :name, :location_id, :is_active)
  end

  def set_piece_slab
    @piece_slab = PieceSlab.find(params[:id])
  end

  def save_or_update_piece_slab_detail
    ########## Slabs ##########
    if params[:piece_slab_details].present?
      piece_slab_details = params[:piece_slab_details]
      if piece_slab_details.count > 0
        Array.new(piece_slab_details.count).each_index do |index|
          if piece_slab_details[index.to_s][:piece_slab_detail_id].nil?
            new_slab 											= @piece_slab.piece_slab_details.build
            new_slab.lower_limit					= piece_slab_details[index.to_s][:lower_limit].to_f
            new_slab.upper_limit					= piece_slab_details[index.to_s][:upper_limit].to_f
            new_slab.fixed_amount					= piece_slab_details[index.to_s][:fixed_amount].to_f
            new_slab.save
          else
            edit_slab 										=	@piece_slab.piece_slab_details.find piece_slab_details[index.to_s][:piece_slab_detail_id]
            edit_slab.lower_limit					= piece_slab_details[index.to_s][:lower_limit].to_f
            edit_slab.upper_limit					= piece_slab_details[index.to_s][:upper_limit].to_f
            edit_slab.fixed_amount				= piece_slab_details[index.to_s][:fixed_amount].to_f
            edit_slab.save
          end
        end
      end
    end
  end

end
