class Api::V1::Web::PayrollManagement::TaxSlabsController < ApplicationController

	before_filter :set_tax_slab, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @tax_slabs = TaxSlab.all.order('id DESC')
    else
      @tax_slabs = TaxSlab.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/payroll_management/tax_slabs/index.json.jbuilder'
  end

  def filter_data
    @tax_slabs = TaxSlab.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/payroll_management/tax_slabs/index.json.jbuilder'
  end

  def create
    @tax_slab       = TaxSlab.new tax_slab_params
    if @tax_slab.save
    	save_or_update_tax_slab_detail
      render json:{}, status: :created
    else
      render json: {errors: @tax_slab.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/payroll_management/tax_slabs/show.json.jbuilder'
  end

  def update
  	if @tax_slab.update(tax_slab_params)
    	save_or_update_tax_slab_detail
      render json: {}, status: 204
    else
      render json: {errors: @tax_slab.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @tax_slab.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @tax_slab.errors.full_messages}, status: :unprocessable_entity
  	end
  end

  def destroy_tax_slab_detail
  	tax_slab_detail = TaxSlabDetail.find params[:tax_slab_detail_id]
  	tax_slab_detail.destroy
  	render json: {}, status: 204
  end

	private

	def tax_slab_params
		params.permit(:company_id, :name, :code, :is_active, :description)
	end

  def set_tax_slab
    @tax_slab = TaxSlab.find(params[:id])
  end

  def save_or_update_tax_slab_detail
  	########## Slabs ##########
    if params[:tax_slab_details].present?
      tax_slab_details = params[:tax_slab_details]
      if tax_slab_details.count > 0
        Array.new(tax_slab_details.count).each_index do |index|
          if tax_slab_details[index.to_s][:tax_slab_detail_id].nil?
            new_slab 											= @tax_slab.tax_slab_details.build
						new_slab.lower_limit					= tax_slab_details[index.to_s][:lower_limit].to_f
						new_slab.upper_limit					= tax_slab_details[index.to_s][:upper_limit].to_f
						new_slab.tax_percentage				= tax_slab_details[index.to_s][:tax_percentage].to_f
						new_slab.fixed_amount					= tax_slab_details[index.to_s][:fixed_amount].to_f
						new_slab.save
          else
            edit_slab 										=	@tax_slab.tax_slab_details.find tax_slab_details[index.to_s][:tax_slab_detail_id]
            edit_slab.lower_limit					= tax_slab_details[index.to_s][:lower_limit].to_f
						edit_slab.upper_limit					= tax_slab_details[index.to_s][:upper_limit].to_f
						edit_slab.tax_percentage			= tax_slab_details[index.to_s][:tax_percentage].to_f
						edit_slab.fixed_amount				= tax_slab_details[index.to_s][:fixed_amount].to_f
						edit_slab.save
          end
        end
      end
    end
  end

end
