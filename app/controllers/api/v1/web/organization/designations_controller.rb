class Api::V1::Web::Organization::DesignationsController < ApplicationController

	before_filter :set_designation, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @designations = Designation.all.order('id DESC')
    else
      @designations = Designation.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/organization/designations/index.json.jbuilder'
  end

  def filter_data
    if (current_user.is_admin == true) or (current_user.is_wager == true) or (current_user.is_piece_rate == true) or  (current_user.is_company_head == true)
      @designations = Designation.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    else
      if current_user.employee.nil?
        @designations = Designation.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
      else
        @designations = Designation.where(:id => current_user.employee.designation_id, :is_active => true).order('id DESC')
      end
    end
    render status:200, template: 'api/v1/web/organization/designations/index.json.jbuilder'
  end

  def grade_related_designations
    grade_ids = params[:grade_id].kind_of?(Array) ? params[:grade_id].map(&:to_i) : params[:grade_id].to_s.split(',').map(&:to_i)
    @designations = Designation.where(:grade_id => grade_ids, :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/organization/designations/index.json.jbuilder'
  end

  def multi_filter_data
    if params[:grade_ids].blank?
      grade_ids = []
    else
      grade_ids = params[:grade_ids].split(',').map(&:to_i)
    end
    @designations = Designation.where(:grade_id => grade_ids, :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/organization/designations/index.json.jbuilder'
  end

  def create
    @designation       = Designation.new designation_params
    if @designation.save
      render json:{}, status: :created
    else
      render json: {errors: @designation.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/organization/designations/show.json.jbuilder'
  end

  def update
    if @designation.update(designation_params)
      render json: {}, status: 204
    else
      render json: {errors: @designation.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @designation.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @designation.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def designation_params
		params.permit(:company_id, :name, :code, :description, :is_active, :grade_id)
	end

  def set_designation
    @designation = Designation.find(params[:id])
  end

end
