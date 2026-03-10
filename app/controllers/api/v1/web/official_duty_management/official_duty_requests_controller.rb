class Api::V1::Web::OfficialDutyManagement::OfficialDutyRequestsController < ApplicationController
  include LeaveOdRequest

  before_action :set_official_duty, :only => [:show]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def bulk_export
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    filter_employee_data_on_request
    if not current_user.employee.nil?
      if current_user.is_location_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id).order('id DESC')
      elsif current_user.is_branch_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id).order('id DESC')
      elsif current_user.is_department_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id).order('id DESC')
      elsif current_user.all_company_department == true
        @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id).order('id DESC')
      elsif current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq).order('id DESC')
      else
        @employees = []
      end
    end
    start_date      = params[:start_date]
    end_date        = params[:end_date]
    od_status       = params[:od_status]
    if od_status == "All"
      od_status = ["Cancelled", "Rejected", "Availed", "Waiting For Approval", "Revert", "Waiting For 2nd Approval"]
    end
    @official_duty_requests = OfficialDuty.where(:company_id => params[:company_id], :request_status => od_status, :employee_id => @employees.collect(&:id)).where(['start_date >= ? AND end_date <= ?', start_date.to_date.beginning_of_day, end_date.to_date.end_of_day]).order('id DESC')
    time = Time.now
    book = Axlsx::Package.new
    check_directory("#{Rails.public_path}/excel")
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'Official Duty')
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
    sheet.add_row ["Sr #", "Employee Code", "Employee Name", "Department", "Apply Date", "Applied By", "Request Status", "Official Duty Mode", "No of Days", "Start Date", "End Date", "Full Day", "Start Time", "End Time", "Forwarded To", "Remarks"], :style => header_style
    old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    count = 0
    @official_duty_requests.each do |official_duty_request|
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

      current_row_value << official_duty_request.employee_code.to_i
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << official_duty_request.employee_name
      current_row_style << row_format
      current_row_type << :string

      department = Employee.find_by(:id => official_duty_request.employee_id )
      current_row_value << department.department_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(official_duty_request.created_at)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << official_duty_request.apply_status
      current_row_style << row_format
      current_row_type << :string

      current_row_value << official_duty_request.request_status
      current_row_style << row_format
      current_row_type << :string

      current_row_value << official_duty_request.normalized_official_duty_mode
      current_row_style << row_format
      current_row_type << :string

      current_row_value << official_duty_request.request_count
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << ReportFormat.date_format(official_duty_request.start_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(official_duty_request.end_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(official_duty_request.is_full_day)
      current_row_style << row_format
      current_row_type << :string

      if official_duty_request.start_time.nil?
        current_row_value << "-"
        current_row_style << row_format
        current_row_type << :string
      else
        current_row_value << official_duty_request.start_time.strftime("%I:%M%p")
        current_row_style << row_format
        current_row_type << :string
      end
      if official_duty_request.end_time.nil?
        current_row_value << "-"
        current_row_style << row_format
        current_row_type << :string
      else
        current_row_value << official_duty_request.end_time.strftime("%I:%M%p")
        current_row_style << row_format
        current_row_type << :string
      end

      current_row_value << official_duty_request.request_sender_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << official_duty_request.reason
      current_row_style << row_format
      current_row_type << :string

      sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
    end
    file_name = "official_duty_request"
    url_path = save_excel_file(book, file_name)
    render json: {message: "Excel Created", path: url_path}
  end

  def calculate_official_duty
  	if params[:employee_id].blank?
  		if not current_user.employee.nil?
	      employee      	= current_user.employee
	      start_date      = params[:start_date].to_date.beginning_of_day
	      end_date        = params[:end_date].to_date.end_of_day
	      requested_data  = OfficialDuty.calculate_official_duty(employee, start_date, end_date)
	      render json: {:request_count => requested_data[0], :message => requested_data[1], :employee_id => employee.id, :company_id => employee.company_id}, status: 200    
	    else
	      render json: {errors: "Request Employee not Found in System"}, status: :unprocessable_entity
	    end
	  else
	  	employee      	= Employee.find(params[:employee_id])
      start_date      = params[:start_date].to_date.beginning_of_day
      end_date        = params[:end_date].to_date.end_of_day
      requested_data  = OfficialDuty.calculate_official_duty(employee, start_date, end_date)
      render json: {:request_count => requested_data[0], :message => requested_data[1], :employee_id => employee.id, :company_id => employee.company_id}, status: 200    
  	end
  end

  def calculate_bulk_official_duty
    if params[:employee_id].blank?
      if not current_user.employee.nil?
        employee        = current_user.employee
        requested_data  = OfficialDuty.calculate_bulk_official_duty(employee)
        request_allowed = true
        if requested_data.include?("You are not allowed to applied request") == true
          request_allowed = false  
        end
        render json: {:message => requested_data, :employee_id => employee.id, :company_id => employee.company_id, :request_allowed => request_allowed}, status: 200    
      else
        render json: {errors: "Request Employee not Found in System"}, status: :unprocessable_entity
      end
    else
      employee        = Employee.find(params[:employee_id])
      requested_data  = OfficialDuty.calculate_bulk_official_duty(employee)
      request_allowed = true
      if requested_data.include?("You are not allowed to applied request") == true
        request_allowed = false  
      end
      render json: {:message => requested_data, :employee_id => employee.id, :company_id => employee.company_id, :request_allowed => request_allowed}, status: 200    
    end
  end

  def filter_data
    @official_duty_requests = OfficialDuty.where(:company_id => params[:company_id]).order('id DESC')
    render status:200, template: 'api/v1/web/official_duty_management/official_duty_requests/index'
  end

  def filter_data1
    @request_flow = RequestFlow.find_by(:company_id => params[:company_id],:id => 2)
    render status:200, template: 'api/v1/web/official_duty_management/official_duty_requests/od_back_date'
  end

  def create
    employee      = Employee.find(params[:employee_id])
    official_duty = OfficialDuty.new
    official_duty.company_id 				= params[:company_id]
		official_duty.employee_id 			= params[:employee_id]
		official_duty.request_count 		= params[:request_count]
		official_duty.start_date 				= params[:start_date].to_date
		official_duty.end_date 					= params[:end_date].to_date
    request_sender_name = RequestFlow.request_flow_username(employee, "Official Duty Request")
    official_duty.request_sender_name = request_sender_name
		if params[:start_time].nil?
      official_duty.start_time = nil
    else
      official_duty.start_time 				= params[:start_time].to_datetime
    end
		if params[:end_time].nil?
      official_duty.end_time = nil
    else
      official_duty.end_time 					= params[:end_time].to_datetime
    end
    official_duty.reason            = params[:reason]
    official_duty.is_full_day       = params[:is_full_day]
    official_duty.official_duty_mode = params[:official_duty_mode]
    if ActiveModel::Type::Boolean.new.cast(params[:auto_approved])
      official_duty.request_status    = "Availed"
      request_user_full_name          = ReportFormat.request_user_full_name(current_user)
      official_duty.approval_name     = request_user_full_name
    else
      official_duty.request_status    = "Waiting For Approval"
    end
		if not current_user.employee.nil?
      if current_user.employee.id == employee.id
        official_duty.apply_status    = "Employee"
      else
        official_duty.apply_status    = "#{current_user.first_name} #{current_user.last_name}"
      end
    else
      official_duty.apply_status      = "#{current_user.first_name} #{current_user.last_name}"
    end  
    official_duty.is_cancelled     		= false
    od_validation = OfficialDuty.validate_od_restriction(employee, official_duty.start_date, official_duty.end_date)
    if od_validation[0] == true
      render json: {errors: od_validation[1]}, status: :unprocessable_entity
    else
      if official_duty.save
        render json:{}, status: :created
      else
        render json: {errors: official_duty.errors.full_messages}, status: :unprocessable_entity
      end
    end
  end

  def save_bulk_official_duty
    response_messages = []
    employee      = Employee.find(params[:employee_id])
    offical_duty_details = params[:offical_duty_details]
    if offical_duty_details.present?
      Array.new(offical_duty_details.count).each_index do |index|
        official_duty = OfficialDuty.new
        official_duty.company_id        = employee.company_id
        official_duty.employee_id       = params[:employee_id]
        official_duty.request_count     = 1
        official_duty.start_date        = offical_duty_details[index.to_s][:selected_date].to_date
        official_duty.end_date          = offical_duty_details[index.to_s][:selected_date].to_date
        request_sender_name = RequestFlow.request_flow_username(employee, "Official Duty Request")
        official_duty.request_sender_name = request_sender_name
        if offical_duty_details[index.to_s][:start_time].nil?
          official_duty.start_time = nil
        else
          official_duty.start_time      = offical_duty_details[index.to_s][:start_time].to_datetime
        end
        if offical_duty_details[index.to_s][:end_time].nil?
          official_duty.end_time = nil
        else
          official_duty.end_time        = offical_duty_details[index.to_s][:end_time].to_datetime
        end
        official_duty.reason            = offical_duty_details[index.to_s][:reason]
        official_duty.is_full_day       = offical_duty_details[index.to_s][:is_full_day]
        official_duty.official_duty_mode = offical_duty_details[index.to_s][:official_duty_mode]
        if ActiveModel::Type::Boolean.new.cast(params[:auto_approved])
          official_duty.request_status    = "Availed"
          request_user_full_name          = ReportFormat.request_user_full_name(current_user)
          official_duty.approval_name     = request_user_full_name
        else
          official_duty.request_status    = "Waiting For Approval" 
        end
        if not current_user.employee.nil?
          if current_user.employee.id == employee.id
            official_duty.apply_status    = "Employee"
          else
            official_duty.apply_status    = "#{current_user.first_name} #{current_user.last_name}"
          end
        else
          official_duty.apply_status      = "#{current_user.first_name} #{current_user.last_name}"
        end  
        official_duty.is_cancelled        = false
        od_validation = OfficialDuty.validate_od_restriction(employee, official_duty.start_date, official_duty.end_date)
        if od_validation[0] == true
          temp_obj = {
            selected_date: ReportFormat.date_format(offical_duty_details[index.to_s][:selected_date].to_date),
            remarks: od_validation[1]
          }
          response_messages << temp_obj
        else
          if official_duty.save
            temp_obj = {
              selected_date: ReportFormat.date_format(offical_duty_details[index.to_s][:selected_date].to_date),
              remarks: "Official Duty Applied"
            }
            response_messages << temp_obj
          else
            temp_obj = {
              selected_date: ReportFormat.date_format(offical_duty_details[index.to_s][:selected_date].to_date),
              remarks: official_duty.errors.full_messages.join(',')
            }
            response_messages << temp_obj
          end
        end
      end
      render json:{:response_messages => response_messages}, status: 200
    else
      render json: {errors: "Employee Not Found"}, status: :unprocessable_entity  
    end
        
  end

  def revert_request
    official_duty = OfficialDuty.find(params[:id])
    official_duty.request_status = "Revert"
    official_duty.save
    render json:{}, status: 200
  end

  def show
    render status:200, template: 'api/v1/web/official_duty_management/official_duty_requests/show'
  end

	private

	def set_official_duty
    @official_duty = OfficialDuty.find(params[:id])
  end

  def filter_employee_data_on_request
    if not params[:location_id].blank?
      @employees = Employee.location_related_employee(@employees, params[:location_id].to_i)
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:line_manager_id].blank?
      @employees = Employee.line_manager_related_employee(@employees, params[:line_manager_id].to_i)
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
