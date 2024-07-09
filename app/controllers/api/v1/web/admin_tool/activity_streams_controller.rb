class Api::V1::Web::AdminTool::ActivityStreamsController < ApplicationController

	def selected_activity_stream
    ip_address = request.ip
    logger.debug "\n client ip => #{ip_address} \n"
    #start_date = "Fri Feb 08 2016 00:00:00 GMT 0500 (PKT)"
    #end_date = "Sun Mar 05 2016 00:00:00 GMT 0500 (PKT)"
    @user_activities = UserActivity.where(:created_at => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day, :company_id => params[:company_id]).order('id DESC')
    if @user_activities.count > 0
      if params[:report_type].to_i == 1
        render status:200, template: 'api/v1/web/admin_tool/activity_streams/selected_activity_stream.json.jbuilder'
      elsif params[:report_type].to_i == 2
        time = Time.now
        url_path = ""

        check_directory("#{Rails.public_path}/pdf")

        pdf = WickedPdf.new.pdf_from_string(
          render_to_string("api/v1/web/admin_tool/activity_streams/view_activity_stream.pdf.erb"),
          footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
          :margin => {
            :top      => '0.5in',
            :bottom   => '0.5in',
            :left     => '0.5in',
            :right    => '0.5in'
          },
          dpi: 450,
          orientation: 'Landscape'
        )

        url_path = save_pdf_file(pdf, 'view_activity_stream')
        render json: {message: "Pdf Created", path: url_path}
      end
    else
      render status: :not_found, json: {errors: "Not Record Found"}
    end
  end

  def create_log
    ip_address  = request.ip
    role_name   = "-"
    logger.debug "\n client ip => #{ip_address} \n"
    company_id = nil
    user = User.find_by_email(params[:user_email])
    if not user.nil?
      company_id = user.company_id
      if not user.role.nil?
        role_name = user.role.name
      end
    end
    UserActivity.create(:action_performed => params[:action_performed], :email => params[:user_email], :full_name => params[:full_name], :ip_address => ip_address, :role_name => role_name, :company_id => company_id)
    render status: 204, json: {}
  end

  private

  def check_directory(dir_path)
    unless File.directory?(dir_path)
      Dir.mkdir(dir_path)
    end
  end

end
