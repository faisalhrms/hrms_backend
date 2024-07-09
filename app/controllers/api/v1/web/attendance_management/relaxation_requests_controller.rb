class Api::V1::Web::AttendanceManagement::RelaxationRequestsController < ApplicationController

	before_filter :set_relaxation, :only => [:show]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if not current_user.employee.nil?
      @relaxation_requests = RelaxationRequest.where(:employee_id => current_user.employee.id).order('id DESC')
    else
      @relaxation_requests = []
    end
    render status:200, template: 'api/v1/web/attendance_management/relaxation_requests/index.json.jbuilder'
  end

  def bulk_index
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :excluded_from_reports => false).order('id DESC')
    filter_employee_data_on_request
    if not current_user.employee.nil?
      if current_user.is_location_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.is_branch_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.is_department_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.all_company_department == true
        @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :excluded_from_reports => false).order('id DESC')
      else
        @employees = []
      end
    end
    start_date      = params[:start_date]
    end_date        = params[:end_date]
    selected_status    		= params[:od_status]
    if selected_status == "All"
      selected_status = ["Cancelled", "Rejected", "Availed", "Waiting For Approval"]
    end
    @relaxation_requests = RelaxationRequest.where(:company_id => params[:company_id], :request_status => selected_status, :employee_id => @employees.collect(&:id)).where(['start_date >= ? AND end_date <= ?', start_date.to_date.beginning_of_day, end_date.to_date.end_of_day]).order('id DESC')
    render status:200, template: 'api/v1/web/attendance_management/relaxation_requests/index.json.jbuilder'
  end

  def bulk_export
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :excluded_from_reports => false).order('id DESC')
    filter_employee_data_on_request
    if not current_user.employee.nil?
      if current_user.is_location_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.is_branch_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.is_department_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.all_company_department == true
        @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
      elsif current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :excluded_from_reports => false).order('id DESC')
      else
        @employees = []
      end
    end
    start_date      = params[:start_date]
    end_date        = params[:end_date]
    selected_status       = params[:od_status]
    if selected_status == "All"
      selected_status = ["Cancelled", "Rejected", "Availed", "Waiting For Approval"]
    end
    @relaxation_requests = RelaxationRequest.where(:company_id => params[:company_id], :request_status => selected_status, :employee_id => @employees.collect(&:id)).where(['start_date >= ? AND end_date <= ?', start_date.to_date.beginning_of_day, end_date.to_date.end_of_day]).order('id DESC')
    time = Time.now
    book = Axlsx::Package.new
    check_directory("#{Rails.public_path}/excel")
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'Relaxation Request')
    book.use_autowidth = false
    sheet.sheet_view do |view|
      view.show_outline_symbols = true
    end
    book.use_autowidth = true
    
    cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
    sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']

    header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
    bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
    sheet.add_row ["Sr #", "Employee Code", "Employee Name", "Relaxation Type", "Apply Date", "Applied By", "Request Status", "No of Days", "Start Date", "End Date", "Forwarded To"], :style => header_style
    old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    count = 0
    @relaxation_requests.each do |relaxation_request|
      count = count + 1
      row_format = old_row_format 

      if count.even? == true
        row_format = even_row_format
      else
        row_format = old_row_format 
      end
      current_row_value = []
      current_row_style = []
      current_row_type = []

      current_row_value << count
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << relaxation_request.employee_code.to_i
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << relaxation_request.employee_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << relaxation_request.attendance_type_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(relaxation_request.created_at)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << relaxation_request.apply_status
      current_row_style << row_format
      current_row_type << :string

      current_row_value << relaxation_request.request_count
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << relaxation_request.request_status
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(relaxation_request.start_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(relaxation_request.end_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << relaxation_request.request_sender_name
      current_row_style << row_format
      current_row_type << :string

      sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
    end
    file_name = "relaxation_request"
    url_path = save_excel_file(book, file_name)
    render json: {message: "Excel Created", path: url_path}
  end

  def calculate_relaxation
  	if params[:employee_id].blank?
  		if not current_user.employee.nil?
	      employee      	= current_user.employee
	      start_date      = params[:start_date].to_date.beginning_of_day
        end_date        = params[:end_date].to_date.end_of_day
        if ENV.fetch("APP_URL").include?('hrmsbe.sapphirepakistan.pk')
        relaxation_start_date      = params[:relaxation_start_date].to_date.beginning_of_day
        relaxation_end_date        = params[:relaxation_end_date].to_date.end_of_day
        else
          relaxation_start_date      = params[:start_date].to_date.beginning_of_day
          relaxation_end_date        = params[:end_date].to_date.end_of_day
        end
	      requested_data  = RelaxationRequest.calculate_relaxation(employee,relaxation_start_date, relaxation_end_date ,start_date, end_date,)
        employee_attendance = EmployeeAttendance.find_by(employee_id: employee.id, attendance_date: params[:start_date].to_date)
        render json: {:request_count => requested_data[0], :message => requested_data[1], :start_time => employee_attendance.try(:in_time), :end_time => employee_attendance.try(:out_time), :employee_id => employee.id, :company_id => employee.company_id}, status: 200
	    else
	      render json: {errors: "Request Employee not Found in System"}, status: :unprocessable_entity
	    end
	  else
	  	employee      	= Employee.find(params[:employee_id])
      start_date      = params[:start_date].to_date.beginning_of_day
      end_date        = params[:end_date].to_date.end_of_day
      if ENV.fetch("APP_URL").include?('hrmsbe.sapphirepakistan.pk')
        relaxation_start_date      = params[:relaxation_start_date].to_date.beginning_of_day
        relaxation_end_date        = params[:relaxation_end_date].to_date.end_of_day
      else
        relaxation_start_date      = params[:start_date].to_date.beginning_of_day
        relaxation_end_date        = params[:end_date].to_date.end_of_day
      end
      requested_data  = RelaxationRequest.calculate_relaxation(employee,relaxation_start_date, relaxation_end_date , start_date, end_date,)
      employee_attendance = EmployeeAttendance.find_by(employee_id: employee.id, attendance_date: params[:start_date].to_date)
      render json: {:request_count => requested_data[0], :message => requested_data[1], :start_time => employee_attendance.try(:in_time), :end_time => employee_attendance.try(:out_time), :employee_id => employee.id, :company_id => employee.company_id}, status: 200
  	end
  end

  def filter_data
    @relaxation_requests = RelaxationRequest.where(:company_id => params[:company_id]).order('id DESC')
    render status:200, template: 'api/v1/web/attendance_management/relaxation_requests/index.json.jbuilder'
  end

  def create
    employee      = Employee.find(params[:employee_id])
    relaxation = RelaxationRequest.new
    relaxation.company_id 				  = params[:company_id]
		relaxation.employee_id 			    = params[:employee_id]
		relaxation.request_count 		    = params[:request_count]
    if ENV.fetch("APP_URL").include?('hrmsbe.sapphirepakistan.pk')
    relaxation.relaxation_start_date  = params[:relaxation_start_date].to_date
    relaxation.relaxation_end_date  	= params[:relaxation_end_date].to_date
    else
      relaxation.relaxation_start_date  = nil
      relaxation.relaxation_end_date  	= nil
    end
		relaxation.start_date 				  = params[:start_date].to_date
		relaxation.end_date 					  = params[:end_date].to_date
		relaxation.start_time 				  = params[:start_time].to_datetime
		relaxation.end_time 					  = params[:end_time].to_datetime
    relaxation.reason               = params[:reason]
    relaxation.attendance_type_id   = params[:attendance_type_id]
    request_sender_name = RequestFlow.request_flow_username(employee, "Relaxation Request")
    relaxation.request_sender_name = request_sender_name
		if params[:auto_approved] == "true"
      relaxation.request_status    = "Availed"
    else
      relaxation.request_status    = "Waiting For Approval"  
    end
		if not current_user.employee.nil?
      if current_user.employee.id == employee.id
        relaxation.apply_status    = "Employee"
      else
        relaxation.apply_status    = "#{current_user.first_name} #{current_user.last_name}"
      end
    else
      relaxation.apply_status      = "#{current_user.first_name} #{current_user.last_name}"
    end  
    relaxation.is_cancelled     		= false
    if relaxation.save
      render json:{}, status: :created
    else
      render json: {errors: relaxation.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def save_bulk_relaxation
    response_messages = []
    employee      = Employee.find(params[:employee_id])
    relaxation_details = params[:relaxation_details]
    if relaxation_details.present?
      Array.new(relaxation_details.count).each_index do |index|
        relaxation = RelaxationRequest.new
        request_sender_name = RequestFlow.request_flow_username(employee, "Relaxation Request")
        relaxation.request_sender_name = request_sender_name
        relaxation.company_id           = employee.company_id
        relaxation.employee_id          = params[:employee_id]
        relaxation.request_count        = 1
        relaxation.criteria 		          = params[:criteria]
        if ENV.fetch("APP_URL").include?('hrmsbe.sapphirepakistan.pk')
          relaxation.relaxation_start_date  = params[:relaxation_start_date].to_date
          relaxation.relaxation_end_date  	= params[:relaxation_end_date].to_date
        else
          relaxation.relaxation_start_date  = nil
          relaxation.relaxation_end_date  	= nil
        end
        relaxation.start_date           = relaxation_details[index.to_s][:selected_date].to_date
        relaxation.end_date             = relaxation_details[index.to_s][:selected_date].to_date
        relaxation.start_time           = relaxation_details[index.to_s][:start_time].to_datetime
        relaxation.end_time             = relaxation_details[index.to_s][:end_time].to_datetime
        relaxation.reason               = relaxation_details[index.to_s][:reason]
        relaxation.attendance_type_id   = relaxation_details[index.to_s][:attendance_type_id]
        if params[:auto_approved] == "true"
          relaxation.request_status    = "Availed"
        else
          relaxation.request_status    = "Waiting For Approval"  
        end
        if not current_user.employee.nil?
          if current_user.employee.id == employee.id
            relaxation.apply_status    = "Employee"
          else
            relaxation.apply_status    = "#{current_user.first_name} #{current_user.last_name}"
          end
        else
          relaxation.apply_status      = "#{current_user.first_name} #{current_user.last_name}"
        end  
        relaxation.is_cancelled        = false
        if relaxation.save
          temp_obj = {
            selected_date: ReportFormat.date_format(relaxation_details[index.to_s][:selected_date].to_date),
            remarks: "Relaxation Applied"
          }
          response_messages << temp_obj
        else
          temp_obj = {
            selected_date: ReportFormat.date_format(relaxation_details[index.to_s][:selected_date].to_date),
            remarks: relaxation.errors.full_messages.join(',')
          }
          response_messages << temp_obj
        end
      end
      render json:{:response_messages => response_messages}, status: 200
    else
      render json: {errors: "Employee Not Found"}, status: :unprocessable_entity  
    end
        
  end

  def cancel_request
    relaxation = RelaxationRequest.find(params[:id])
    relaxation.is_cancelled = true
    relaxation.request_status = "Cancelled"
    relaxation.save
    render json:{}, status: 200
  end

  def approved_request
    relaxation = RelaxationRequest.find(params[:id])
    relaxation.add_impact_to_approval_request(current_user)
    render json:{}, status: 200
  end

  def show
    render status:200, template: 'api/v1/web/attendance_management/relaxation_requests/show.json.jbuilder'
  end

	private

	def set_relaxation
    @relaxation = RelaxationRequest.find(params[:id])
  end

  def filter_employee_data_on_request
    if not params[:location_id].blank?
      @employees = Employee.location_related_employee(@employees, params[:location_id].to_i)
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
  end

  def delete_pdf_reports
    files = Dir.glob(File.join("#{Rails.public_path}/pdf", '**', '*')).select { |file| File.file?(file) }
    if files.count > 0
      files.each do |aFile|
        File.delete(aFile)
      end
    end
  end

  def delete_excel_reports
    files = Dir.glob(File.join("#{Rails.public_path}/excel", '**', '*')).select { |file| File.file?(file) }
    if files.count > 0
      files.each do |aFile|
        File.delete(aFile)
      end
    end
  end

  def check_directory(dir_path)
    unless File.directory?(dir_path)
      Dir.mkdir(dir_path)
    end
  end

end
