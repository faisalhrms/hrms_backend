class Api::V1::CustomDevise::SessionsController < Devise::SessionsController
  before_action :authenticate_user_from_token!, except: [:create, :destroy]
  skip_before_action :require_no_authentication, only: [:create]
  skip_before_action :verify_signed_out_user
  skip_before_action :verify_authenticity_token
  include Devise::Controllers::Helpers

  respond_to :json

  def create
    user = User.find_by(email: params[:user][:email].downcase)
    if user
      if user.valid_password?(params[:user][:password])
        user.last_sign_in_at = Time.now
        user.authentication_token = SecureRandom.urlsafe_base64
        user.login_count = user.login_count + 1
        user.save!
        @user_session = user
        @user_permissions = []
        if @user_session.is_active == true
          if not @user_session.role.nil?
            @user_permissions = @user_session.role.role_permissions
          end
          render status:200, template: 'api/v1/custom_devise/sessions/create.json.jbuilder'
        else
          render json: {:message => "Account is In-Active. Contact to Admin"}, :status => 422
        end
      else
        render json: {:message => "Invalid login credentials"}, :status => 422
      end
    else
      render json: {:message => "Not a Valid User"}, :status => 422
    end
  end

  def destroy
    user_email = params[:user_email].presence
    user       = user_email && User.find_by_email(user_email)
    if user && Devise.secure_compare(user.authentication_token, params[:user_token])
      user.firebase_token == ""
      user.authentication_token = SecureRandom.urlsafe_base64
      user.save
      render json: {message: "Successfully Logout"}, status: 200
    else
      render json: {:message => "Invalid login credentials"}, :status => 401
    end
  end

  private

  def skip_set_cookies_header
    reset_session = {}
  end

end
