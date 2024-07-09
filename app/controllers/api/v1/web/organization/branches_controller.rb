class Api::V1::Web::Organization::BranchesController < ApplicationController

	before_filter :set_branch, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @branches = Branch.all.order('id DESC')
    elsif current_user.is_company_head == true
      if not current_user.employee.nil?
        @branches = Branch.where(:company_id => current_user.employee.company_id).order('id DESC')
      else
        @branches = Branch.where(:company_id => current_user.company_id).order('id DESC')
      end
    elsif current_user.is_location_head == true
      if not current_user.employee.nil?
        @branches = Branch.where(:location_id => current_user.employee.location_id).order('id DESC')
      else
        @branches = []
      end
    elsif current_user.is_branch_head == true
      if not current_user.employee.nil?
        @branches = Branch.where(:id => current_user.employee.branch_id).order('id DESC')
      else
        @branches = []
      end
    else
      @branches = Branch.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/organization/branches/index.json.jbuilder'
  end

  def filter_data
    @branches = Branch.where(:location_id => params[:location_id], :is_active => true).order('id DESC')
    if (current_user.is_admin == true) or (current_user.is_dtl == true) or (current_user.is_wager == true) or (current_user.is_piece_rate == true) or (current_user.email == "syedali.imran@srl.com.pk") or (current_user.email == "murtaza.khan@srl.com.pk")
      @branches = Branch.where(:location_id => params[:location_id], :is_active => true).order('id DESC')
    elsif current_user.is_company_head == true
      if not current_user.employee.nil?
        @branches = Branch.where(:location_id => params[:location_id], :is_active => true).order('id DESC')
      end
    elsif current_user.is_location_head == true
      if not current_user.employee.nil?
        @branches = Branch.where(:location_id => current_user.employee.location_id).order('id DESC')
      else
        @branches = []
      end
    elsif current_user.is_branch_head == true
      if not current_user.employee.nil?
        @branches = Branch.where(:id => current_user.employee.branch_id).order('id DESC')
      else
        @branches = []
      end
    else
      if not current_user.employee.nil?
        if current_user.multi_branch_allowed == true
          branch_ids = current_user.branch_ids.split(',').map(&:to_i)
          branch_ids << current_user.employee.branch_id
          branch_ids = branch_ids.uniq
          @branches = @branches.where(:id => branch_ids).order('id DESC')
        else
          @branches = @branches.where(:id => current_user.employee.branch_id).order('id DESC')
        end
      else
        if current_user.multi_branch_allowed == true
          branch_ids = current_user.branch_ids.split(',').map(&:to_i)
          branch_ids = branch_ids.uniq
          @branches = @branches.where(:id => branch_ids).order('id DESC')
        else
          @branches = []
        end
      end
    end
    @branches = @branches.includes(:location) if @branches.present?
    render status:200, template: 'api/v1/web/organization/branches/index.json.jbuilder'
  end

  def multi_filter_data
    if params[:location_ids].blank?
      location_ids = []
    else
      location_ids = params[:location_ids].split(',').map(&:to_i)
    end
    @branches = Branch.where(:location_id => location_ids, :is_active => true).order('id DESC')
    if current_user.is_location_head == true
      if not current_user.employee.nil?
        @branches = Branch.where(:location_id => current_user.employee.location_id).order('id DESC')
      else
        @branches = []
      end
    elsif current_user.is_branch_head == true
      if not current_user.employee.nil?
        @branches = Branch.where(:id => current_user.employee.branch_id).order('id DESC')
      else
        @branches = []
      end
    end
    render status:200, template: 'api/v1/web/organization/branches/index.json.jbuilder'
  end

  def company_filter_data
    @branches = Branch.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    if current_user.is_admin == true
      @branches = Branch.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    elsif current_user.is_company_head == true
      if not current_user.employee.nil?
        @branches = Branch.where(:company_id => current_user.employee.company_id, :is_active => true).order('id DESC')
      else
        @branches = []
      end
    else
      @branches = []
    end
    render status:200, template: 'api/v1/web/organization/branches/index.json.jbuilder'
  end

  def create
    @branch       = Branch.new branch_params
    if @branch.save
      render json:{}, status: :created
    else
      render json: {errors: @branch.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/organization/branches/show.json.jbuilder'
  end

  def update
    if @branch.update(branch_params)
      render json: {}, status: 204
    else
      render json: {errors: @branch.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @branch.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @branch.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def branch_params
		params.permit(:company_id, :location_id, :country_id, :state_id, :city_id, :name, :code, :description, :is_active, :employee_code_prefix, :shop_id)
	end

  def set_branch
    @branch = Branch.find(params[:id])
  end

end
