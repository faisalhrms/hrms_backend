class Api::V1::Web::LeaveManagement::LeaveRequestsController < ApplicationController
  include LeaveOdRequest

	before_filter :set_leave_request, :only => [:show]
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
      elsif current_user.is_department_head == true
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
    leave_status    = params[:leave_status]
    if leave_status == "All"
      leave_status = ["Cancelled", "Rejected", "Availed", "Waiting For Approval", "Revert", "System Deducted"]
    end
    @leave_requests = LeaveRequest.where(:company_id => params[:company_id], :request_status => leave_status, :employee_id => @employees.collect(&:id)).where(['start_date >= ? AND end_date <= ?', start_date.to_date.beginning_of_day, end_date.to_date.end_of_day]).order('id DESC')
    time = Time.now
    book = Axlsx::Package.new
    check_directory("#{Rails.public_path}/excel")
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'Leave Request')
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
    sheet.add_row ["Sr #", "Employee Code", "Employee Name","Department","Leave Type", "Apply Date", "Applied By", "Request Status", "No of Days", "Start Date", "End Date", "Forwarded To"], :style => header_style
    old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    count = 0
    @leave_requests.each do |leave_request|
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

      current_row_value << leave_request.employee_code.to_i
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << leave_request.employee_name
      current_row_style << row_format
      current_row_type << :string

      department = Employee.find_by(:id => leave_request.employee_id )
      current_row_value << department.department_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << leave_request.leave_type_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(leave_request.created_at)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << leave_request.apply_status
      current_row_style << row_format
      current_row_type << :string

      current_row_value << leave_request.request_status
      current_row_style << row_format
      current_row_type << :string

      current_row_value << leave_request.request_count.to_f
      current_row_style << row_format
      current_row_type << :float

      current_row_value << ReportFormat.date_format(leave_request.start_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(leave_request.end_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << leave_request.request_sender_name
      current_row_style << row_format
      current_row_type << :string
      sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
    end
    file_name = "leave_request"
    url_path = save_excel_file(book, file_name)
    render json: {message: "Excel Created", path: url_path}
  end

  def employee_leave_quota
    if params[:employee_id].to_i == 0
      if not current_user.employee.nil?
        @leave_type = LeaveType.find(params[:leave_type_id])
        @leave_allocation = LeaveAllocation.find_by(:leave_type_id => params[:leave_type_id], :employee_id => current_user.employee.id, :is_active => true)
        if not @leave_allocation.nil?
          render status:200, template: 'api/v1/web/leave_management/leave_requests/employee_leave_quota.json.jbuilder'
        else
          render json: {errors: "Leave Quota not assigned to you"}, status: :unprocessable_entity
        end
      else
        render json: {errors: "You are not a Employee"}, status: :unprocessable_entity
      end
    else
      @leave_type = LeaveType.find(params[:leave_type_id])
      @leave_allocation = LeaveAllocation.find_by(:leave_type_id => params[:leave_type_id], :employee_id => params[:employee_id], :is_active => true)
      if not @leave_allocation.nil?
        render status:200, template: 'api/v1/web/leave_management/leave_requests/employee_leave_quota.json.jbuilder'
      else
        render json: {errors: "Leave Quota not assigned to you"}, status: :unprocessable_entity
      end
    end      
  end

  def calculate_leave
    begin
      leave_type      = LeaveType.find(params[:leave_type_id])
      begin
        if leave_type.is_composite == true
          if not params[:start_date].to_s.blank?
            if not params[:end_date].to_s.blank?
              employee        = Employee.find(params[:employee_id])
              start_date      = params[:start_date].to_date.beginning_of_day
              end_date        = params[:end_date].to_date.end_of_day
              leave_category  = params[:leave_category]
              requested_data  = LeaveRequest.calculate_composite_employee_leave(leave_type, employee, start_date, end_date, leave_category)
              render json: {:request_count => requested_data[0], :sandwich_count => requested_data[1], :message => requested_data[2]}, status: 200
            else
              render json: {errors: "Leave End Date Should not be empty"}, status: :unprocessable_entity
            end
          else
            render json: {errors: "Leave Start Date Should not be empty"}, status: :unprocessable_entity
          end
        else
          if not params[:start_date].to_s.blank?
            if not params[:end_date].to_s.blank?
              employee        = Employee.find(params[:employee_id])
              start_date      = params[:start_date].to_date.beginning_of_day
              end_date        = params[:end_date].to_date.end_of_day
              leave_category  = params[:leave_category]
              requested_data  = LeaveRequest.calculate_employee_leave(leave_type, employee, start_date, end_date, leave_category)
              render json: {:request_count => requested_data[0], :sandwich_count => requested_data[1], :message => requested_data[2]}, status: 200  
            else
              render json: {errors: "Leave End Date Should not be empty"}, status: :unprocessable_entity
            end
          else
            render json: {errors: "Leave Start Date Should not be empty"}, status: :unprocessable_entity
          end
        end
      rescue ActiveRecord::RecordNotFound
        render json: {errors: "Request Employee not Found in System"}, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: {errors: "Please select Leave Type"}, status: :unprocessable_entity
    end
  end

  def filter_data
    @leave_requests = LeaveRequest.where(:company_id => params[:company_id]).order('id DESC')
    render status:200, template: 'api/v1/web/leave_management/leave_requests/index.json.jbuilder'
  end

  def bulk_save
    employees = Employee.find(params[:employees])
    leave_type = LeaveType.find(params[:leave_type_id])
    start_date = params[:start_date].to_date
    end_date = params[:end_date].to_date
    leave_category = params[:leave_category]
    response_messages, temp_obj = [], ''
    employees.each do |employee|
      leave_allocation = LeaveAllocation.find_by(:leave_type_id => leave_type.id, :employee_id => employee.id, :is_active => true)
      if leave_allocation
        requested_data  = LeaveRequest.calculate_composite_employee_leave(leave_type, employee, start_date, end_date, leave_category)
        if leave_type.is_composite
          allocated_quota	= leave_allocation.composite_allocated_quota
          used_quota = leave_allocation.composite_used_quota
          remaining_quota	= leave_allocation.composite_remaining_quota
        else
          allocated_quota =	leave_allocation.allocated_quota
          used_quota =	leave_allocation.used_quota
          remaining_quota =	leave_allocation.remaining_quota
        end
        if remaining_quota >= requested_data[0]
          leave_request = LeaveRequest.new
          leave_request.company_id       = employee.company_id
          leave_request.employee_id      = employee.id
          leave_request.leave_type_id    = leave_type.id
          leave_request.allocated_quota  = allocated_quota.to_f
          leave_request.used_quota       = used_quota.to_f
          leave_request.remaining_quota  = remaining_quota.to_f
          leave_request.request_count    = requested_data[0]
          leave_request.sandwich_count   = requested_data[1]
          leave_request.start_date       = start_date
          leave_request.end_date         = end_date
          leave_request.reason           = params[:reason]
          leave_request.leave_category   = leave_category
          request_sender_name = RequestFlow.request_flow_username(employee, 'Leave Request')
          leave_request.request_sender_name = request_sender_name
          leave_request.request_status    = 'Waiting For Approval'
          leave_request.is_composite = leave_type.is_composite
          leave_request.apply_status = "#{current_user.first_name} #{current_user.last_name}"
          leave_request.is_cancelled = false
          if leave_request.save
            temp_obj = {
                employee_name: "(#{employee.employee_code}) #{employee.full_name}",
                remarks: 'Leave request applied successfully.'
            }
          else
            temp_obj = {
                employee_name: "#{employee.employee_code}: #{employee.full_name}",
                remarks: "#{leave_request.errors.full_messages.join(',')}"
            }
          end
        else
          temp_obj = {
              employee_name: "#{employee.employee_code}: #{employee.full_name}",
              remarks: 'Remaining quota is less than requested quota '
          }
        end
      else
        temp_obj = {
            employee_name: "#{employee.employee_code}: #{employee.full_name}",
            remarks: 'No leave allocation found. '
        }
      end
      response_messages << temp_obj
    end
    render json: {response_messages: response_messages}, status: 200
  end

  def create
    employee      = Employee.find(params[:employee_id])
    leave_type    = LeaveType.find(params[:leave_type_id])
    leave_request = LeaveRequest.new
    leave_request.company_id       = employee.company_id
    leave_request.employee_id      = params[:employee_id]
    leave_request.leave_type_id    = params[:leave_type_id]
    leave_request.allocated_quota  = params[:allocated_quota].to_f
    leave_request.used_quota       = params[:used_quota].to_f
    leave_request.remaining_quota  = params[:remaining_quota].to_f
    leave_request.request_count    = params[:request_count].to_f
    leave_request.sandwich_count   = params[:sandwich_count].to_f
    leave_request.min_apply_date   = params[:min_apply_date].to_date
    leave_request.start_date       = params[:start_date].to_date
    leave_request.end_date         = params[:end_date].to_date
    leave_request.reason           = params[:reason]
    leave_request.leave_category   = params[:leave_category]
    request_sender_name = RequestFlow.request_flow_username(employee, "Leave Request")
    leave_request.request_sender_name = request_sender_name
    leave_request.request_status    = "Waiting For Approval"  
    if leave_type.is_composite == true
      leave_request.is_composite   = true
    else
      leave_request.is_composite   = false
    end
    if not current_user.employee.nil?
      if current_user.employee.id == employee.id
        leave_request.apply_status     = "Employee"
      else
        leave_request.apply_status     = "#{current_user.first_name} #{current_user.last_name}"
      end
    else
      leave_request.apply_status       = "#{current_user.first_name} #{current_user.last_name}"
    end  
    leave_request.is_cancelled     = false
    if leave_request.save
      render json:{}, status: :created
    else
      render json: {errors: leave_request.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def revert_request
    leave_request = LeaveRequest.find(params[:id])
    leave_request.request_status = "Revert"
    leave_request.save
    render json:{}, status: 200
  end

  def show
    render status:200, template: 'api/v1/web/leave_management/leave_requests/show.json.jbuilder'
  end

	private

	def set_leave_request
    @leave_request = LeaveRequest.find(params[:id])
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

  def filter_employee_conditions(conditions)
    if params[:location_id].present?
      conditions[:location_id] = params[:location_id].to_i
    end
    if params[:branch_id].present?
      conditions[:branch_id] = params[:location_id].to_i
      @employees =  params[:branch_id].to_i
    end
    if params[:department_id].present?
      conditions[:department_id] = params[:department_id].to_i
    end
    if params[:line_manager_id].present?
      conditions[:line_manager_id] = params[:line_manager_id].to_i
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
