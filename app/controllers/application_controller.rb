class ApplicationController < ActionController::Base

  protect_from_forgery with: :null_session
  before_action :authenticate_user_from_token!

  private
  def save_excel_file(book, file_name)
    file_path = "/excel/#{file_name}_#{Time.now.to_i}.xlsx"
    book.serialize "#{Rails.public_path.to_s + file_path}"
    file_path
  end

  def save_pdf_file(pdf, file_name)
    dir_path = "#{Rails.public_path}/pdf"
    unless File.directory?(dir_path)
      Dir.mkdir(dir_path)
    end
    file_path = "/pdf/#{file_name}_#{Time.now.to_i}.pdf"
    File.open("#{Rails.public_path.to_s + file_path}", 'wb') do |file|
      file << pdf
    end
    file_path
  end

  def authenticate_user_from_token!
    user_email = params[:user_email].presence
    user       = user_email && User.find_by_email(user_email)
    if user && Devise.secure_compare(user.authentication_token, params[:user_token])
      @user  = User.find_by_email(params[:user_email])
      @current_user = @user
      User.current = @current_user
    else
      User.current = nil
      render json: {:errors => ["Invalid login credentials"], debug_error_from: "DEBUG_INFO: authenticate_user_from_token!"}, :status => 401
    end  
  end

  def mill_instance?
    ENV.fetch("APP_URL").include?('millshrmsbe.dfl.com.pk')
  end

  def dtl_instance?
    ENV.fetch("APP_URL").include?('dtlbe.srl.com.pk')
  end

  def srl_instance?
    ENV.fetch("APP_URL").include?('hrmsbe.sapphirepakistan.pk')
  end

  def record_not_found
    render status:404, json: {message: "No Record Found"}
  end

end
