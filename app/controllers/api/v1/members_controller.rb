class Api::V1::MembersController < ApplicationController

	before_action :authenticate_user_from_token!, :except => [:create, :update_password_by_token, :reset_password]
  before_action :set_member, :only => [:show, :update, :destroy, :update_password]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @members = User.all.order('id DESC')
  end

  def filter_data
    if params[:active_filter] == "All"
      @members = User.where(:is_active => true).order('id DESC')
    elsif params[:active_filter] == "Trashed"  
      @members = User.where(:is_active => false).order('id DESC')
    end
    render status:200, template: 'api/v1/members/index.json.jbuilder'
  end

  def create
    @member       = User.new new_user_params
    @member.is_confirmed = true
    if @member.save
      render json:{:errors => "User Created"}, status: :created
    else
      render json: {errors: @member.errors.full_messages}, status: 422
    end
  end

  def show
  end

  def update
    if params[:branch_ids].nil? or params[:branch_ids].blank?
      @member.branch_ids = nil
    else
      @member.branch_ids = params[:branch_ids].map(&:to_i).join(',')
    end
    if @member.update(edit_user_params)
      render json:{:errors => "User Updated"}, status: 201
    else
      render json: {errors: @member.errors.full_messages}, status: 422
    end
  end

  def user_update_password
    @member  = User.find_by_email(params[:email])
    my_password = BCrypt::Password.new(@member.encrypted_password)
    if my_password == params[:current_password]
      if params[:password] == params[:password_confirmation]
        @member.password = params[:password]
        @member.password_confirmation = params[:password_confirmation]
        @member.first_login = true
        @member.save
        Notification.create_custom_notification(@member, @member, @member, "#{@member.full_name} change your password")
        ip_address = request.ip
        role_name = "-"
        company_id = nil
        if not @member.nil?
          company_id = @member.company_id
          if not @member.role.nil?
            role_name = @member.role.name
          end
        end
        UserActivity.create(:action_performed => "#{@member.full_name} change your password", :email => params[:email], :full_name => @member.full_name, :ip_address => ip_address, :role_name => role_name, :company_id => company_id)
        render status: 200, json:{message: "Password Updated Successfully..."}
      else
        render status: 422, json:{message: "Password Don't Match..."}
      end
    else
      render status: 422, json:{message: "Current Password Is Not Correct!!!"}
    end
  end

  def reset_password
    user = User.find_by_email(params[:email])
    if user
      user.send_password_reset(params[:link])
      render status: 200, json: {}
    else
      render status: 404, json: {}
    end
  end

  def update_password
    user  = User.find_by_email(params[:user_email])
    my_password = BCrypt::Password.new(@member.encrypted_password)
    if params[:password] == params[:password_confirmation]
      @member.password = params[:password]
      @member.password_confirmation = params[:password_confirmation]
      @member.save(:validate => false)
      Notification.create_custom_notification(@user, @member, @member, "#{@user.full_name} change your password")
      ip_address = request.ip
      role_name = "-"
      company_id = nil
      if not user.nil?
        company_id = user.company_id
        if not user.role.nil?
          role_name = user.role.name
        end
      end
      UserActivity.create(:action_performed => "#{@user.full_name} change password of #{@member.full_name}", :email => params[:user_email], :full_name => @user.full_name, :ip_address => ip_address, :role_name => role_name, :company_id => company_id)
      render status: 200, json:{message: "Password Updated Successfully..."}
    else
      render status: 422, json:{message: "Password Don't Match..."}
    end
  end

  def update_password_by_token
    @user = User.find_by_reset_password_token!(params[:id])
    if @user.reset_password_sent_at < 2.hours.ago
      render status: 422, json: {}
    else
      @user.password = params[:password]
      if @user.save
        Notification.create_custom_notification(@user, @user, @user, "#{@user.full_name} reset his/her own password")
        ip_address = request.ip
        role_name = "-"
        company_id = nil
        if not @user.nil?
          company_id = @user.company_id
          if not @user.role.nil?
            role_name = @user.role.name
          end
        end
        UserActivity.create(:action_performed => "#{@user.full_name} reset his/her own password", :email => @user.email, :full_name => @user.full_name, :ip_address => ip_address, :role_name => role_name, :company_id => company_id)
        render status: 200, json: {}
      else
        render status: 422, json: {}
      end
    end
  end

  def destroy
    if @member.destroy
      render json: {}, status: 201
    else
      render status: 422, json:{ errors: @member.errors }
    end
  end

  private

  def new_user_params
    params.permit(:first_name, :last_name, :email, :password, :password_confirmation, :is_active, :is_admin,:is_dtl, :is_wager,:is_piece_rate,:custom_right, :role_id, :company_id, :is_company_head, :is_location_head, :is_branch_head, :is_department_head, :is_sub_department_head, :hris_dashboard, :salary_dashboard, :attendance_dashboard)
  end

  def edit_user_params
    params.permit(:first_name, :last_name, :email, :is_active, :is_admin,:is_dtl, :is_wager,:is_piece_rate,:custom_right, :role_id, :company_id, :is_company_head, :is_location_head, :is_branch_head, :is_department_head, :is_sub_department_head, :multi_branch_allowed, :all_company_department, :request_on_dashboard, :hris_dashboard, :salary_dashboard, :attendance_dashboard)
  end

  def set_member
    @member = User.find(params[:id])
  end

end
