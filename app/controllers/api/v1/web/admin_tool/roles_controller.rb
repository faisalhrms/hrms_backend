class Api::V1::Web::AdminTool::RolesController < ApplicationController

	before_filter :set_role, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @roles = Role.all.order('id DESC')
    else
      @roles = Role.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/admin_tool/roles/index.json.jbuilder'
  end

  def filter_data
    @roles = Role.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/admin_tool/roles/index.json.jbuilder'
  end

  def create
    @role       = Role.new role_params
    if @role.save
      save_or_update_role_permissions
      render json:{}, status: :created
    else
      render json: {errors: @role.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/admin_tool/roles/show.json.jbuilder'
  end

  def update
    if @role.update(role_params)
      save_or_update_role_permissions
      render json: {}, status: 204
    else
      render json: {errors: @role.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @role.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @role.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def role_params
		params.permit(:company_id, :name, :is_active)
	end

  def set_role
    @role = Role.find(params[:id])
  end

  def save_or_update_role_permissions
    ######### Organization ##########
    if params[:organization].present?
      if params[:organization][:role_permissions].present?
        role_permissions = params[:organization][:role_permissions]
        if role_permissions.count > 0
          Array.new(role_permissions.count).each_index do |index|
            if role_permissions[index.to_s][:role_permission_id].nil?
              role_permission = @role.role_permissions.build
              role_permission.main_module     = role_permissions[index.to_s][:main_module]
              role_permission.display_name    = role_permissions[index.to_s][:display_name]
              role_permission.module_name     = role_permissions[index.to_s][:module_name]
              role_permission.index_access    = role_permissions[index.to_s][:index_access]
              role_permission.create_access   = role_permissions[index.to_s][:create_access]
              role_permission.view_access     = role_permissions[index.to_s][:view_access]
              role_permission.update_access   = role_permissions[index.to_s][:update_access]
              role_permission.delete_access   = role_permissions[index.to_s][:delete_access]
              role_permission.save
            else
              edit_role_permission = @role.role_permissions.find role_permissions[index.to_s][:role_permission_id]
              edit_role_permission.main_module    = role_permissions[index.to_s][:main_module]
              edit_role_permission.display_name   = role_permissions[index.to_s][:display_name]
              edit_role_permission.module_name    = role_permissions[index.to_s][:module_name]
              edit_role_permission.index_access   = role_permissions[index.to_s][:index_access]
              edit_role_permission.create_access  = role_permissions[index.to_s][:create_access]
              edit_role_permission.view_access    = role_permissions[index.to_s][:view_access]
              edit_role_permission.update_access  = role_permissions[index.to_s][:update_access]
              edit_role_permission.delete_access  = role_permissions[index.to_s][:delete_access]
              edit_role_permission.save
            end
          end
        end
      end
    end
    ######### Organization ##########
    ########## Admin Tool ##########
    if params[:admin_tool].present?
      if params[:admin_tool][:role_permissions].present?
        role_permissions = params[:admin_tool][:role_permissions]
        if role_permissions.count > 0
          Array.new(role_permissions.count).each_index do |index|
            if role_permissions[index.to_s][:role_permission_id].nil?
              role_permission = @role.role_permissions.build
              role_permission.main_module     = role_permissions[index.to_s][:main_module]
              role_permission.display_name    = role_permissions[index.to_s][:display_name]
              role_permission.module_name     = role_permissions[index.to_s][:module_name]
              role_permission.index_access    = role_permissions[index.to_s][:index_access]
              role_permission.create_access   = role_permissions[index.to_s][:create_access]
              role_permission.view_access     = role_permissions[index.to_s][:view_access]
              role_permission.update_access   = role_permissions[index.to_s][:update_access]
              role_permission.delete_access   = role_permissions[index.to_s][:delete_access]
              role_permission.save
            else
              edit_role_permission = @role.role_permissions.find role_permissions[index.to_s][:role_permission_id]
              edit_role_permission.main_module    = role_permissions[index.to_s][:main_module]
              edit_role_permission.display_name   = role_permissions[index.to_s][:display_name]
              edit_role_permission.module_name    = role_permissions[index.to_s][:module_name]
              edit_role_permission.index_access   = role_permissions[index.to_s][:index_access]
              edit_role_permission.create_access  = role_permissions[index.to_s][:create_access]
              edit_role_permission.view_access    = role_permissions[index.to_s][:view_access]
              edit_role_permission.update_access  = role_permissions[index.to_s][:update_access]
              edit_role_permission.delete_access  = role_permissions[index.to_s][:delete_access]
              edit_role_permission.save
            end
          end
        end
      end
    end
    ########## Admin Tool ##########
    ########## Employee Management ##########
    if params[:employee_management].present?
      if params[:employee_management][:role_permissions].present?
        role_permissions = params[:employee_management][:role_permissions]
        if role_permissions.count > 0
          Array.new(role_permissions.count).each_index do |index|
            if role_permissions[index.to_s][:role_permission_id].nil?
              role_permission = @role.role_permissions.build
              role_permission.main_module     = role_permissions[index.to_s][:main_module]
              role_permission.display_name    = role_permissions[index.to_s][:display_name]
              role_permission.module_name     = role_permissions[index.to_s][:module_name]
              role_permission.index_access    = role_permissions[index.to_s][:index_access]
              role_permission.create_access   = role_permissions[index.to_s][:create_access]
              role_permission.view_access     = role_permissions[index.to_s][:view_access]
              role_permission.update_access   = role_permissions[index.to_s][:update_access]
              role_permission.delete_access   = role_permissions[index.to_s][:delete_access]
              role_permission.save
            else
              edit_role_permission = @role.role_permissions.find role_permissions[index.to_s][:role_permission_id]
              edit_role_permission.main_module    = role_permissions[index.to_s][:main_module]
              edit_role_permission.display_name   = role_permissions[index.to_s][:display_name]
              edit_role_permission.module_name    = role_permissions[index.to_s][:module_name]
              edit_role_permission.index_access   = role_permissions[index.to_s][:index_access]
              edit_role_permission.create_access  = role_permissions[index.to_s][:create_access]
              edit_role_permission.view_access    = role_permissions[index.to_s][:view_access]
              edit_role_permission.update_access  = role_permissions[index.to_s][:update_access]
              edit_role_permission.delete_access  = role_permissions[index.to_s][:delete_access]
              edit_role_permission.save
            end
          end
        end
      end
    end
    ########## Employee Management ##########
    ########## Performance Management ##########
    if params[:performance_management].present?
      if params[:performance_management][:role_permissions].present?
        role_permissions = params[:performance_management][:role_permissions]
        if role_permissions.count > 0
          Array.new(role_permissions.count).each_index do |index|
            if role_permissions[index.to_s][:role_permission_id].nil?
              role_permission = @role.role_permissions.build
              role_permission.main_module     = role_permissions[index.to_s][:main_module]
              role_permission.display_name    = role_permissions[index.to_s][:display_name]
              role_permission.module_name     = role_permissions[index.to_s][:module_name]
              role_permission.index_access    = role_permissions[index.to_s][:index_access]
              role_permission.create_access   = role_permissions[index.to_s][:create_access]
              role_permission.view_access     = role_permissions[index.to_s][:view_access]
              role_permission.update_access   = role_permissions[index.to_s][:update_access]
              role_permission.delete_access   = role_permissions[index.to_s][:delete_access]
              role_permission.save
            else
              edit_role_permission = @role.role_permissions.find role_permissions[index.to_s][:role_permission_id]
              edit_role_permission.main_module    = role_permissions[index.to_s][:main_module]
              edit_role_permission.display_name   = role_permissions[index.to_s][:display_name]
              edit_role_permission.module_name    = role_permissions[index.to_s][:module_name]
              edit_role_permission.index_access   = role_permissions[index.to_s][:index_access]
              edit_role_permission.create_access  = role_permissions[index.to_s][:create_access]
              edit_role_permission.view_access    = role_permissions[index.to_s][:view_access]
              edit_role_permission.update_access  = role_permissions[index.to_s][:update_access]
              edit_role_permission.delete_access  = role_permissions[index.to_s][:delete_access]
              edit_role_permission.save
            end
          end
        end
      end
    end
    ########## Performance Management ##########
    ########### Leave Management ############
    if params[:leave_management].present?
      if params[:leave_management][:role_permissions].present?
        role_permissions = params[:leave_management][:role_permissions]
        if role_permissions.count > 0
          Array.new(role_permissions.count).each_index do |index|
            if role_permissions[index.to_s][:role_permission_id].nil?
              role_permission = @role.role_permissions.build
              role_permission.main_module     = role_permissions[index.to_s][:main_module]
              role_permission.display_name    = role_permissions[index.to_s][:display_name]
              role_permission.module_name     = role_permissions[index.to_s][:module_name]
              role_permission.index_access    = role_permissions[index.to_s][:index_access]
              role_permission.create_access   = role_permissions[index.to_s][:create_access]
              role_permission.view_access     = role_permissions[index.to_s][:view_access]
              role_permission.update_access   = role_permissions[index.to_s][:update_access]
              role_permission.delete_access   = role_permissions[index.to_s][:delete_access]
              role_permission.save
            else
              edit_role_permission = @role.role_permissions.find role_permissions[index.to_s][:role_permission_id]
              edit_role_permission.main_module    = role_permissions[index.to_s][:main_module]
              edit_role_permission.display_name   = role_permissions[index.to_s][:display_name]
              edit_role_permission.module_name    = role_permissions[index.to_s][:module_name]
              edit_role_permission.index_access   = role_permissions[index.to_s][:index_access]
              edit_role_permission.create_access  = role_permissions[index.to_s][:create_access]
              edit_role_permission.view_access    = role_permissions[index.to_s][:view_access]
              edit_role_permission.update_access  = role_permissions[index.to_s][:update_access]
              edit_role_permission.delete_access  = role_permissions[index.to_s][:delete_access]
              edit_role_permission.save
            end
          end
        end
      end
    end
    ########### Leave Management ###########
    ########### Official Duty Management ############
    if params[:official_duty_management].present?
      if params[:official_duty_management][:role_permissions].present?
        role_permissions = params[:official_duty_management][:role_permissions]
        if role_permissions.count > 0
          Array.new(role_permissions.count).each_index do |index|
            if role_permissions[index.to_s][:role_permission_id].nil?
              role_permission = @role.role_permissions.build
              role_permission.main_module     = role_permissions[index.to_s][:main_module]
              role_permission.display_name    = role_permissions[index.to_s][:display_name]
              role_permission.module_name     = role_permissions[index.to_s][:module_name]
              role_permission.index_access    = role_permissions[index.to_s][:index_access]
              role_permission.create_access   = role_permissions[index.to_s][:create_access]
              role_permission.view_access     = role_permissions[index.to_s][:view_access]
              role_permission.update_access   = role_permissions[index.to_s][:update_access]
              role_permission.delete_access   = role_permissions[index.to_s][:delete_access]
              role_permission.save
            else
              edit_role_permission = @role.role_permissions.find role_permissions[index.to_s][:role_permission_id]
              edit_role_permission.main_module    = role_permissions[index.to_s][:main_module]
              edit_role_permission.display_name   = role_permissions[index.to_s][:display_name]
              edit_role_permission.module_name    = role_permissions[index.to_s][:module_name]
              edit_role_permission.index_access   = role_permissions[index.to_s][:index_access]
              edit_role_permission.create_access  = role_permissions[index.to_s][:create_access]
              edit_role_permission.view_access    = role_permissions[index.to_s][:view_access]
              edit_role_permission.update_access  = role_permissions[index.to_s][:update_access]
              edit_role_permission.delete_access  = role_permissions[index.to_s][:delete_access]
              edit_role_permission.save
            end
          end
        end
      end
    end
    ########### Official Duty Management ###########
    ########### Roster Management ############
    if params[:roster_management].present?
      if params[:roster_management][:role_permissions].present?
        role_permissions = params[:roster_management][:role_permissions]
        if role_permissions.count > 0
          Array.new(role_permissions.count).each_index do |index|
            if role_permissions[index.to_s][:role_permission_id].nil?
              role_permission = @role.role_permissions.build
              role_permission.main_module     = role_permissions[index.to_s][:main_module]
              role_permission.display_name    = role_permissions[index.to_s][:display_name]
              role_permission.module_name     = role_permissions[index.to_s][:module_name]
              role_permission.index_access    = role_permissions[index.to_s][:index_access]
              role_permission.create_access   = role_permissions[index.to_s][:create_access]
              role_permission.view_access     = role_permissions[index.to_s][:view_access]
              role_permission.update_access   = role_permissions[index.to_s][:update_access]
              role_permission.delete_access   = role_permissions[index.to_s][:delete_access]
              role_permission.save
            else
              edit_role_permission = @role.role_permissions.find role_permissions[index.to_s][:role_permission_id]
              edit_role_permission.main_module    = role_permissions[index.to_s][:main_module]
              edit_role_permission.display_name   = role_permissions[index.to_s][:display_name]
              edit_role_permission.module_name    = role_permissions[index.to_s][:module_name]
              edit_role_permission.index_access   = role_permissions[index.to_s][:index_access]
              edit_role_permission.create_access  = role_permissions[index.to_s][:create_access]
              edit_role_permission.view_access    = role_permissions[index.to_s][:view_access]
              edit_role_permission.update_access  = role_permissions[index.to_s][:update_access]
              edit_role_permission.delete_access  = role_permissions[index.to_s][:delete_access]
              edit_role_permission.save
            end
          end
        end
      end
    end
    ########### Roster Management ###########
    ########### Attendance Management ############
    if params[:attendance_management].present?
      if params[:attendance_management][:role_permissions].present?
        role_permissions = params[:attendance_management][:role_permissions]
        if role_permissions.count > 0
          Array.new(role_permissions.count).each_index do |index|
            if role_permissions[index.to_s][:role_permission_id].nil?
              role_permission = @role.role_permissions.build
              role_permission.main_module     = role_permissions[index.to_s][:main_module]
              role_permission.display_name    = role_permissions[index.to_s][:display_name]
              role_permission.module_name     = role_permissions[index.to_s][:module_name]
              role_permission.index_access    = role_permissions[index.to_s][:index_access]
              role_permission.create_access   = role_permissions[index.to_s][:create_access]
              role_permission.view_access     = role_permissions[index.to_s][:view_access]
              role_permission.update_access   = role_permissions[index.to_s][:update_access]
              role_permission.delete_access   = role_permissions[index.to_s][:delete_access]
              role_permission.save
            else
              edit_role_permission = @role.role_permissions.find role_permissions[index.to_s][:role_permission_id]
              edit_role_permission.main_module    = role_permissions[index.to_s][:main_module]
              edit_role_permission.display_name   = role_permissions[index.to_s][:display_name]
              edit_role_permission.module_name    = role_permissions[index.to_s][:module_name]
              edit_role_permission.index_access   = role_permissions[index.to_s][:index_access]
              edit_role_permission.create_access  = role_permissions[index.to_s][:create_access]
              edit_role_permission.view_access    = role_permissions[index.to_s][:view_access]
              edit_role_permission.update_access  = role_permissions[index.to_s][:update_access]
              edit_role_permission.delete_access  = role_permissions[index.to_s][:delete_access]
              edit_role_permission.save
            end
          end
        end
      end
    end
    ########### Attendance Management ###########
    ########### Incentive Management ############
    if params[:incentive_management].present?
      if params[:incentive_management][:role_permissions].present?
        role_permissions = params[:incentive_management][:role_permissions]
        if role_permissions.count > 0
          Array.new(role_permissions.count).each_index do |index|
            if role_permissions[index.to_s][:role_permission_id].nil?
              role_permission = @role.role_permissions.build
              role_permission.main_module     = role_permissions[index.to_s][:main_module]
              role_permission.display_name    = role_permissions[index.to_s][:display_name]
              role_permission.module_name     = role_permissions[index.to_s][:module_name]
              role_permission.index_access    = role_permissions[index.to_s][:index_access]
              role_permission.create_access   = role_permissions[index.to_s][:create_access]
              role_permission.view_access     = role_permissions[index.to_s][:view_access]
              role_permission.update_access   = role_permissions[index.to_s][:update_access]
              role_permission.delete_access   = role_permissions[index.to_s][:delete_access]
              role_permission.save
            else
              edit_role_permission = @role.role_permissions.find role_permissions[index.to_s][:role_permission_id]
              edit_role_permission.main_module    = role_permissions[index.to_s][:main_module]
              edit_role_permission.display_name   = role_permissions[index.to_s][:display_name]
              edit_role_permission.module_name    = role_permissions[index.to_s][:module_name]
              edit_role_permission.index_access   = role_permissions[index.to_s][:index_access]
              edit_role_permission.create_access  = role_permissions[index.to_s][:create_access]
              edit_role_permission.view_access    = role_permissions[index.to_s][:view_access]
              edit_role_permission.update_access  = role_permissions[index.to_s][:update_access]
              edit_role_permission.delete_access  = role_permissions[index.to_s][:delete_access]
              edit_role_permission.save
            end
          end
        end
      end
    end
    ########### Incentive Management ###########
    ############ PayRoll Management ############
    if params[:payroll_management].present?
      if params[:payroll_management][:role_permissions].present?
        role_permissions = params[:payroll_management][:role_permissions]
        if role_permissions.count > 0
          Array.new(role_permissions.count).each_index do |index|
            if role_permissions[index.to_s][:role_permission_id].nil?
              role_permission = @role.role_permissions.build
              role_permission.main_module     = role_permissions[index.to_s][:main_module]
              role_permission.display_name    = role_permissions[index.to_s][:display_name]
              role_permission.module_name     = role_permissions[index.to_s][:module_name]
              role_permission.index_access    = role_permissions[index.to_s][:index_access]
              role_permission.create_access   = role_permissions[index.to_s][:create_access]
              role_permission.view_access     = role_permissions[index.to_s][:view_access]
              role_permission.update_access   = role_permissions[index.to_s][:update_access]
              role_permission.delete_access   = role_permissions[index.to_s][:delete_access]
              role_permission.save
            else
              edit_role_permission = @role.role_permissions.find role_permissions[index.to_s][:role_permission_id]
              edit_role_permission.main_module    = role_permissions[index.to_s][:main_module]
              edit_role_permission.display_name   = role_permissions[index.to_s][:display_name]
              edit_role_permission.module_name    = role_permissions[index.to_s][:module_name]
              edit_role_permission.index_access   = role_permissions[index.to_s][:index_access]
              edit_role_permission.create_access  = role_permissions[index.to_s][:create_access]
              edit_role_permission.view_access    = role_permissions[index.to_s][:view_access]
              edit_role_permission.update_access  = role_permissions[index.to_s][:update_access]
              edit_role_permission.delete_access  = role_permissions[index.to_s][:delete_access]
              edit_role_permission.save
            end
          end
        end
      end
    end
    ############ PayRoll Management ###########
    ########### Report Management ##########
    if params[:report_management].present?
      if params[:report_management][:role_permissions].present?
        role_permissions = params[:report_management][:role_permissions]
        if role_permissions.count > 0
          Array.new(role_permissions.count).each_index do |index|
            if role_permissions[index.to_s][:role_permission_id].nil?
              role_permission = @role.role_permissions.build
              role_permission.main_module     = role_permissions[index.to_s][:main_module]
              role_permission.display_name    = role_permissions[index.to_s][:display_name]
              role_permission.module_name     = role_permissions[index.to_s][:module_name]
              role_permission.index_access    = role_permissions[index.to_s][:index_access]
              role_permission.create_access   = role_permissions[index.to_s][:create_access]
              role_permission.view_access     = role_permissions[index.to_s][:view_access]
              role_permission.update_access   = role_permissions[index.to_s][:update_access]
              role_permission.delete_access   = role_permissions[index.to_s][:delete_access]
              role_permission.save
            else
              edit_role_permission = @role.role_permissions.find role_permissions[index.to_s][:role_permission_id]
              edit_role_permission.main_module    = role_permissions[index.to_s][:main_module]
              edit_role_permission.display_name   = role_permissions[index.to_s][:display_name]
              edit_role_permission.module_name    = role_permissions[index.to_s][:module_name]
              edit_role_permission.index_access   = role_permissions[index.to_s][:index_access]
              edit_role_permission.create_access  = role_permissions[index.to_s][:create_access]
              edit_role_permission.view_access    = role_permissions[index.to_s][:view_access]
              edit_role_permission.update_access  = role_permissions[index.to_s][:update_access]
              edit_role_permission.delete_access  = role_permissions[index.to_s][:delete_access]
              edit_role_permission.save
            end
          end
        end
      end
    end
    ########### Report Management ##########
    ############### Main Menu ##############
    if params[:main_menu].present?
      if params[:main_menu][:role_permissions].present?
        role_permissions = params[:main_menu][:role_permissions]
        if role_permissions.count > 0
          Array.new(role_permissions.count).each_index do |index|
            if role_permissions[index.to_s][:role_permission_id].nil?
              role_permission = @role.role_permissions.build
              role_permission.main_module     = role_permissions[index.to_s][:main_module]
              role_permission.display_name    = role_permissions[index.to_s][:display_name]
              role_permission.module_name     = role_permissions[index.to_s][:module_name]
              role_permission.index_access    = role_permissions[index.to_s][:index_access]
              role_permission.create_access   = role_permissions[index.to_s][:create_access]
              role_permission.view_access     = role_permissions[index.to_s][:view_access]
              role_permission.update_access   = role_permissions[index.to_s][:update_access]
              role_permission.delete_access   = role_permissions[index.to_s][:delete_access]
              role_permission.save
            else
              edit_role_permission = @role.role_permissions.find role_permissions[index.to_s][:role_permission_id]
              edit_role_permission.main_module    = role_permissions[index.to_s][:main_module]
              edit_role_permission.display_name   = role_permissions[index.to_s][:display_name]
              edit_role_permission.module_name    = role_permissions[index.to_s][:module_name]
              edit_role_permission.index_access   = role_permissions[index.to_s][:index_access]
              edit_role_permission.create_access  = role_permissions[index.to_s][:create_access]
              edit_role_permission.view_access    = role_permissions[index.to_s][:view_access]
              edit_role_permission.update_access  = role_permissions[index.to_s][:update_access]
              edit_role_permission.delete_access  = role_permissions[index.to_s][:delete_access]
              edit_role_permission.save
            end
          end
        end
      end
    end
    ############### Main Menu ##############
  end

end
