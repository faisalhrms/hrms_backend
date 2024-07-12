class Api::V1::Web::TokensController < ApplicationController

	before_action :authenticate_user_from_token!, :except => [:validate]

  def validate
    user_email = params[:user_email].presence
    user       = user_email && User.find_by_email(user_email)
    @user_permissions = []
    if user && Devise.secure_compare(user.authentication_token, params[:user_token])
      @user  = User.find_by_email(params[:user_email])
      if not @user.role.nil?
        @user_permissions = @user.role.role_permissions
      end
      @notis = user.recieved_notifications.where(:did_read => false).order('id DESC')
      render status:200, template: 'api/v1/web/tokens/validate'
    else
      render json: {:errors => ["Invalid login credentials"], debug_error_from: "DEBUG_INFO: authenticate_user_from_token!"}, :status => 401
    end
  end

end
