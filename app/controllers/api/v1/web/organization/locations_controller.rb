class Api::V1::Web::Organization::LocationsController < ApplicationController

	before_action :set_location, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @locations = Location.all.order('id DESC')
    elsif current_user.is_company_head == true
      if not current_user.employee.nil?
        @locations = Location.where(:company_id => current_user.employee.company_id).order('id DESC')
      else
        @locations = Location.where(:company_id => current_user.company_id).order('id DESC')
      end
    elsif current_user.is_location_head == true
      if not current_user.employee.nil?
        @locations = Location.where(:id => current_user.employee.location_id).order('id DESC')  
      else
        @locations = []
      end
    else
      @locations = []
    end
    render status:200, template: 'api/v1/web/organization/locations/index'
  end

  def filter_data
    if current_user.is_admin == true
      @locations = Location.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    elsif current_user.is_dtl == true
      @locations = Location.where(:company_id => params[:company_id],:id => 6, :is_active => true).order('id DESC')
    elsif (current_user.is_wager == true) and  (current_user.is_piece_rate == true)
      @locations = Location.where(:company_id => params[:company_id],:id => [8,9], :is_active => true).order('id DESC')
    elsif current_user.is_wager == true
      @locations = Location.where(:company_id => params[:company_id],:id => 8, :is_active => true).order('id DESC')
    elsif current_user.is_piece_rate == true
      @locations = Location.where(:company_id => params[:company_id],:id => 9, :is_active => true).order('id DESC')
    elsif (current_user.email == "syedali.imran@srl.com.pk") or (current_user.email == "murtaza.khan@srl.com.pk")
      @locations = Location.where(:company_id => params[:company_id],:id => [8,10], :is_active => true).order('id DESC')
    elsif current_user.is_company_head == true
      if not current_user.employee.nil?
        @locations = Location.where(:company_id => current_user.employee.company_id, :is_active => true).order('id DESC')
      else
        @locations = Location.where(:company_id => current_user.company_id, :is_active => true).order('id DESC')
      end
    elsif current_user.is_location_head == true
      if not current_user.employee.nil?
        @locations = Location.where(:id => current_user.employee.location_id, :is_active => true).order('id DESC')  
      else
        @locations = []
      end
    elsif not current_user.employee.nil?
      if current_user.multi_branch_allowed == true
        branch_ids = current_user.branch_ids.split(',').map(&:to_i)
        location_ids = Branch.where(:is_active => true, :id => branch_ids).collect(&:location_id).uniq
        location_ids << current_user.employee.location_id
        @locations = Location.where(:id => location_ids, :is_active => true).order('id DESC')  
      else
        @locations = Location.where(:id => current_user.employee.location_id, :is_active => true).order('id DESC')  
      end
    elsif current_user.multi_branch_allowed == true
      branch_ids = current_user.branch_ids.split(',').map(&:to_i)
      location_ids = Branch.where(:is_active => true, :id => branch_ids).collect(&:location_id).uniq
      @locations = Location.where(:id => location_ids, :is_active => true).order('id DESC')  
    else
      @locations = []
    end
    render status:200, template: 'api/v1/web/organization/locations/index'
  end

  def hris_dashboard_filter
    if current_user.is_admin == true
      @locations = Location.where(:company_id => current_user.company_id, :is_active => true).order('id DESC')
    else
      @locations = []
    end
    render status:200, template: 'api/v1/web/organization/locations/index'
  end

  def salary_dashboard_filter
    if current_user.is_admin == true
      @locations = Location.where(:company_id => current_user.company_id, :is_active => true).order('id DESC')
    else
      @locations = []
    end
    render status:200, template: 'api/v1/web/organization/locations/index'
  end

  def attendance_dashboard_filter
    if current_user.is_admin == true
      @locations = Location.where(:company_id => current_user.company_id, :is_active => true).order('id DESC')
    else
      @locations = []
    end
    render status:200, template: 'api/v1/web/organization/locations/index'
  end

  def create
    @location       = Location.new location_params
    if @location.save
      render json:{}, status: :created
    else
      render json: {errors: @location.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/organization/locations/show'
  end

  def update
    if @location.update(location_params)
      render json: {}, status: 204
    else
      render json: {errors: @location.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @location.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @location.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def location_params
		params.permit(:company_id, :name, :code, :description, :is_active, :employee_code_prefix)
	end

  def set_location
    @location = Location.find(params[:id])
  end

end
