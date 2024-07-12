class Api::V1::Web::PayrollManagement::CustomTaxSlabsController < ApplicationController

	before_action :set_custom_tax_slab, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @custom_tax_slabs = CustomTaxSlab.all.order('id DESC')
    else
      @custom_tax_slabs = CustomTaxSlab.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/payroll_management/custom_tax_slabs/index'
  end

  def filter_data
    @custom_tax_slabs = CustomTaxSlab.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/payroll_management/custom_tax_slabs/index'
  end

  def create
    @custom_tax_slab       = CustomTaxSlab.new custom_tax_slab_params
    if @custom_tax_slab.save
    	save_or_update_custom_tax_slab_detail
      render json:{}, status: :created
    else
      render json: {errors: @custom_tax_slab.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/payroll_management/custom_tax_slabs/show'
  end

  def update
  	if @custom_tax_slab.update(custom_tax_slab_params)
    	save_or_update_custom_tax_slab_detail
      render json: {}, status: 204
    else
      render json: {errors: @custom_tax_slab.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @custom_tax_slab.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @custom_tax_slab.errors.full_messages}, status: :unprocessable_entity
  	end
  end

  def destroy_custom_tax_slab_detail
  	custom_tax_slab_detail = CustomTaxSlabDetail.find params[:custom_tax_slab_detail_id]
  	custom_tax_slab_detail.destroy
  	render json: {}, status: 204
  end

	private

	def custom_tax_slab_params
		params.permit(:company_id, :name, :code, :is_active, :description)
	end

  def set_custom_tax_slab
    @custom_tax_slab = CustomTaxSlab.find(params[:id])
  end

  def save_or_update_custom_tax_slab_detail
  	########## Slabs ##########
    if params[:custom_tax_slab_details].present?
      custom_tax_slab_details = params[:custom_tax_slab_details]
      if custom_tax_slab_details.count > 0
        Array.new(custom_tax_slab_details.count).each_index do |index|
          if custom_tax_slab_details[index.to_s][:custom_tax_slab_detail_id].nil?
            new_slab 											= @custom_tax_slab.custom_tax_slab_details.build
						new_slab.lower_limit					= custom_tax_slab_details[index.to_s][:lower_limit].to_f
						new_slab.upper_limit					= custom_tax_slab_details[index.to_s][:upper_limit].to_f
						new_slab.tax_percentage				= custom_tax_slab_details[index.to_s][:tax_percentage].to_f
						new_slab.fixed_amount					= custom_tax_slab_details[index.to_s][:fixed_amount].to_f
						new_slab.save
          else
            edit_slab 										=	@custom_tax_slab.custom_tax_slab_details.find custom_tax_slab_details[index.to_s][:custom_tax_slab_detail_id]
            edit_slab.lower_limit					= custom_tax_slab_details[index.to_s][:lower_limit].to_f
						edit_slab.upper_limit					= custom_tax_slab_details[index.to_s][:upper_limit].to_f
						edit_slab.tax_percentage			= custom_tax_slab_details[index.to_s][:tax_percentage].to_f
						edit_slab.fixed_amount				= custom_tax_slab_details[index.to_s][:fixed_amount].to_f
						edit_slab.save
          end
        end
      end
    end
  end

end
