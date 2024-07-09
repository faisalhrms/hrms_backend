class Api::V1::Web::LeaveManagement::LeaveAllocationsController < ApplicationController

	before_filter :set_leave_allocation, :only => [:show, :adjust_leave_balance, :deactivate_leave, :activate_leave, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @leave_allocations = LeaveAllocation.includes(:leave_type, :employee).order('id DESC')
    @leave_allocations =  @leave_allocation.get_by_company(current_user.company_id) unless current_user.is_admin
    @in_process_leave = false
    system_setting = SystemSetting.find_by(:company_id => current_user.company_id)
    if not system_setting.nil?
      @in_process_leave = system_setting.in_process_leave_allowed
    end
    render status:200, template: 'api/v1/web/leave_management/leave_allocations/index.json.jbuilder'
  end

  def leave_allocation_list
    if params[:leave_status].present?
      if params[:leave_status].to_s == "active"
        is_active = true
      else
        is_active = false
      end
    end
    @leave_allocations = LeaveAllocation.includes(:leave_type, :employee).order('id DESC')
    if params[:leave_status].present?
      @leave_allocations = @leave_allocations.where(:is_active => is_active)
    end
    @leave_allocations = @leave_allocations.get_by_company(params[:company_id]) unless current_user.is_admin
    filter_leave_allocation_data_on_request
    @in_process_leave = false
    system_setting = SystemSetting.find_by(:company_id => params[:company_id])
    if not system_setting.nil?
      @in_process_leave = system_setting.in_process_leave_allowed
    end
    if params[:leave_year_id].present?
      @leave_allocations = @leave_allocations.where(:leave_year_id => params[:leave_year_id])
    end
    render status:200, template: 'api/v1/web/leave_management/leave_allocations/index.json.jbuilder'
  end

  def bulk_export
    if params[:leave_status].present?
      if params[:leave_status].to_s == "active"
        is_active = true
      else
        is_active = false
      end
    end
    if current_user.is_admin == true
      if params[:leave_status].present?
        @leave_allocations = LeaveAllocation.where(:is_active => is_active).order('id DESC')
      else
        @leave_allocations = LeaveAllocation.all.order('id DESC')
      end
      filter_leave_allocation_data_on_request
    else
      if params[:leave_status].present?
        @leave_allocations = LeaveAllocation.where(:company_id => params[:company_id], :is_active => is_active).order('id DESC')
      else
        @leave_allocations = LeaveAllocation.where(:company_id => params[:company_id]).order('id DESC')
      end
      filter_leave_allocation_data_on_request
    end
    @in_process_leave = false
    system_setting = SystemSetting.find_by(:company_id => params[:company_id])
    if not system_setting.nil?
      @in_process_leave = system_setting.in_process_leave_allowed
    end
    
    time = Time.now
    book = Axlsx::Package.new
    check_directory("#{Rails.public_path}/excel")
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'Leave Allocation')
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
    sheet.add_row ["Sr #", "ID", "Employee Code", "Employee Name", "Employee Status", "Leave Type", "Leave Quota", "In Process Quota", "Used Quota", "Remaining Quota", "Status"], :style => header_style

    old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    count = 0

    if params[:employee_status].present?
      if params[:employee_status].to_s == "active"
        employee_status = true
      else
        employee_status = false
      end
    else
      employee_status = [true, false]
    end
    @leave_allocations.each do |leave_allocation|
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

      if params[:employee_status].present?
        if leave_allocation.employee.is_active.to_s == employee_status.to_s

          current_row_value << count
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << leave_allocation.id.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << leave_allocation.employee.employee_code.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << leave_allocation.employee.full_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text_as_active(leave_allocation.employee.is_active)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << leave_allocation.leave_type_name
          current_row_style << row_format
          current_row_type << :string

          if @in_process_leave == true
            if leave_allocation.leave_type.is_composite == false
              in_process_quota = leave_allocation.in_process_quota
              current_row_value << leave_allocation.allocated_quota
              current_row_style << row_format
              current_row_type << :float

              current_row_value << in_process_quota
              current_row_style << row_format
              current_row_type << :float

              current_row_value << (leave_allocation.used_quota - in_process_quota)
              current_row_style << row_format
              current_row_type << :float

              current_row_value << leave_allocation.remaining_quota
              current_row_style << row_format
              current_row_type << :float
            else
              in_process_quota = leave_allocation.composite_in_process_quota
              current_row_value << leave_allocation.composite_allocated_quota
              current_row_style << row_format
              current_row_type << :float

              current_row_value << in_process_quota
              current_row_style << row_format
              current_row_type << :float

              current_row_value << (leave_allocation.composite_used_quota - in_process_quota)
              current_row_style << row_format
              current_row_type << :float

              current_row_value << leave_allocation.composite_remaining_quota
              current_row_style << row_format
              current_row_type << :float
            end
          else
            if leave_allocation.leave_type.is_composite == false
              current_row_value << leave_allocation.allocated_quota
              current_row_style << row_format
              current_row_type << :float

              current_row_value << "-"
              current_row_style << row_format
              current_row_type << :string

              current_row_value << leave_allocation.used_quota
              current_row_style << row_format
              current_row_type << :float

              current_row_value << leave_allocation.remaining_quota
              current_row_style << row_format
              current_row_type << :float
            else
              current_row_value << leave_allocation.composite_allocated_quota
              current_row_style << row_format
              current_row_type << :float

              current_row_value << "-"
              current_row_style << row_format
              current_row_type << :string

              current_row_value << leave_allocation.composite_used_quota
              current_row_style << row_format
              current_row_type << :float

              current_row_value << leave_allocation.composite_remaining_quota
              current_row_style << row_format
              current_row_type << :float
            end
          end

          current_row_value << ReportFormat.boolean_in_text_as_active(leave_allocation.is_active)
          current_row_style << row_format
          current_row_type << :string

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
        end
      else
        current_row_value << count
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << leave_allocation.id.to_i
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << leave_allocation.employee.employee_code.to_i
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << leave_allocation.employee.full_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.boolean_in_text_as_active(leave_allocation.employee.is_active)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << leave_allocation.leave_type_name
        current_row_style << row_format
        current_row_type << :string

        if @in_process_leave == true
          if leave_allocation.leave_type.is_composite == false
            in_process_quota = leave_allocation.in_process_quota
            current_row_value << leave_allocation.allocated_quota
            current_row_style << row_format
            current_row_type << :float

            current_row_value << in_process_quota
            current_row_style << row_format
            current_row_type << :float

            current_row_value << (leave_allocation.used_quota - in_process_quota)
            current_row_style << row_format
            current_row_type << :float

            current_row_value << leave_allocation.remaining_quota
            current_row_style << row_format
            current_row_type << :float
          else
            in_process_quota = leave_allocation.composite_in_process_quota
            current_row_value << leave_allocation.composite_allocated_quota
            current_row_style << row_format
            current_row_type << :float

            current_row_value << in_process_quota
            current_row_style << row_format
            current_row_type << :float

            current_row_value << (leave_allocation.composite_used_quota - in_process_quota)
            current_row_style << row_format
            current_row_type << :float

            current_row_value << leave_allocation.composite_remaining_quota
            current_row_style << row_format
            current_row_type << :float
          end
        else
          if leave_allocation.leave_type.is_composite == false
            current_row_value << leave_allocation.allocated_quota
            current_row_style << row_format
            current_row_type << :float

            current_row_value << "-"
            current_row_style << row_format
            current_row_type << :string

            current_row_value << leave_allocation.used_quota
            current_row_style << row_format
            current_row_type << :float

            current_row_value << leave_allocation.remaining_quota
            current_row_style << row_format
            current_row_type << :float
          else
            current_row_value << leave_allocation.composite_allocated_quota
            current_row_style << row_format
            current_row_type << :float

            current_row_value << "-"
            current_row_style << row_format
            current_row_type << :string

            current_row_value << leave_allocation.composite_used_quota
            current_row_style << row_format
            current_row_type << :float

            current_row_value << leave_allocation.composite_remaining_quota
            current_row_style << row_format
            current_row_type << :float
          end
        end

        current_row_value << ReportFormat.boolean_in_text_as_active(leave_allocation.is_active)
        current_row_style << row_format
        current_row_type << :string

        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
    end
      
    file_name = "leave_allocation"
    url_path = save_excel_file(book, file_name)
    render json: {message: "Excel Created", path: url_path}
  end

  def employee_leave_ledger
    if not current_user.employee.nil?
      @leave_allocations = LeaveAllocation.where(:employee_id => current_user.employee.id).order('id DESC')
    else
      @leave_allocations = []
    end
    @in_process_leave = false
    system_setting = SystemSetting.find_by(:company_id => current_user.company_id)
    if not system_setting.nil?
      @in_process_leave = system_setting.in_process_leave_allowed
    end
    render status:200, template: 'api/v1/web/leave_management/leave_allocations/index.json.jbuilder'
  end

  def filter_data
    @leave_allocations = LeaveAllocation.where(:company_id => params[:company_id]).order('id DESC')
    @in_process_leave = false
    system_setting = SystemSetting.find_by(:company_id => params[:company_id])
    if not system_setting.nil?
      @in_process_leave = system_setting.in_process_leave_allowed
    end
    render status:200, template: 'api/v1/web/leave_management/leave_allocations/index.json.jbuilder'
  end

  def create
    @leave_allocation = LeaveAllocation.new leave_allocation_params
    if @leave_allocation.save
      leave_transaction = LeaveTransactionHistory.find_by(:employee_id => @leave_allocation.employee_id, :leave_type_id => @leave_allocation.leave_type_id, :leave_allocation_id => nil)
      leave_transaction.leave_allocation_id = @leave_allocation.id
      leave_transaction.save
      render json:{}, status: :created
    else
      render json: {errors: @leave_allocation.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    @in_process_leave = false
    system_setting = SystemSetting.find_by(:company_id => current_user.company_id)
    if not system_setting.nil?
      @in_process_leave = system_setting.in_process_leave_allowed
    end
    render status:200, template: 'api/v1/web/leave_management/leave_allocations/show.json.jbuilder'
  end

  def adjust_leave_balance
    @leave_allocation.allocated_quota   = params[:allocated_quota].to_f
    @leave_allocation.used_quota        = params[:used_quota].to_f
    @leave_allocation.remaining_quota   = @leave_allocation.allocated_quota - @leave_allocation.used_quota
    @leave_allocation.save(:validate => false)
    LeaveTransactionHistory.create_leave_transaction(@leave_allocation.company_id, @leave_allocation.employee_id, @leave_allocation.leave_type_id, nil, @leave_allocation.allocated_quota, @leave_allocation.remaining_quota, @leave_allocation.used_quota, 0.0, "Manual Adjustement", "Manual Adjustement By #{current_user.first_name} #{current_user.last_name}", @leave_allocation.leave_year_start_date, @leave_allocation.leave_year_end_date, @leave_allocation.id)
  end

  def deactivate_leave
    if LeaveRequest.where(:request_status => "Waiting For Approval", :employee_id => @leave_allocation.employee_id, :leave_type_id => @leave_allocation.leave_type_id).count == 0
      @leave_allocation.is_active = false
      @leave_allocation.save(:validate => false)
      render json:{}, status: 200
    else
      render json: {errors: "Leave can't be deactivated because total no of #{LeaveRequest.where(:request_status => "Waiting For Approval", :employee_id => @leave_allocation.employee_id, :leave_type_id => @leave_allocation.leave_type_id).count} leave requests in Waiting for Approval Status"}, status: :unprocessable_entity
    end
  end

  def activate_leave
    if LeaveRequest.where(:request_status => "Waiting For Approval", :employee_id => @leave_allocation.employee_id, :leave_type_id => @leave_allocation.leave_type_id).count == 0
      @leave_allocation.is_active = true
      @leave_allocation.save(:validate => false)
      render json:{}, status: 200
    else
      render json: {errors: "Leave can't be activated because total no of #{LeaveRequest.where(:request_status => "Waiting For Approval", :employee_id => @leave_allocation.employee_id, :leave_type_id => @leave_allocation.leave_type_id).count} leave requests in Waiting for Approval Status"}, status: :unprocessable_entity
    end
  end

  def save_bulk_leave_allocation
    response_messages = []
    bulk_leave_allocation = params[:bulk_leave_allocation]
    employee_list = params[:employee_list]
    leave_type = LeaveType.find(bulk_leave_allocation[:leave_type_id])
    inactive_leave_year = LeaveYear.find_by_id(bulk_leave_allocation[:inactive_leave_year_id])
    if bulk_leave_allocation.present?
      if employee_list.present?
        Array.new(employee_list.count).each_index do |index|
          @leave_allocation = LeaveAllocation.new    
          @leave_allocation.company_id    = bulk_leave_allocation[:company_id]
          @leave_allocation.employee_id   = employee_list[index.to_s][:id]
          @leave_allocation.leave_type_id = bulk_leave_allocation[:leave_type_id]
          @leave_allocation.location_id   = bulk_leave_allocation[:location_id]
          if @leave_allocation.save
            leave_transaction = LeaveTransactionHistory.find_by(:employee_id => @leave_allocation.employee_id, :leave_type_id => @leave_allocation.leave_type_id, :leave_allocation_id => nil)
            if not leave_transaction.nil?
              leave_transaction.leave_allocation_id = @leave_allocation.id
              leave_transaction.save
            end
            employee = Employee.find(employee_list[index.to_s][:id])
            carry_forward_msg = ''
            if inactive_leave_year and leave_type.carry_forward
              carry_leave = employee.leave_allocations.where(leave_type_id: leave_type, leave_year_start_date: inactive_leave_year.start_date,
                                                                                    leave_year_end_date: inactive_leave_year.end_date).last
              if(carry_leave and carry_leave.remaining_quota > 0)
                @leave_allocation.add_carry_quota_to_employee(carry_leave.remaining_quota, leave_type.id, employee_list[index.to_s][:id], inactive_leave_year.id, 'Carry Forward Balance')
                carry_forward_msg = ". #{carry_leave.remaining_quota} leaves carry forwarded"
              end
            end
            temp_obj = {
              employee_name: employee_list[index.to_s][:full_name],
              remarks: "Leave Allocated#{carry_forward_msg}"
            }
            response_messages << temp_obj
          else
            temp_obj = {
              employee_name: employee_list[index.to_s][:full_name],
              remarks: @leave_allocation.errors.full_messages.join(',')
            }
            response_messages << temp_obj
          end
        end
        render json:{:response_messages => response_messages}, status: 200
      else
        render json: {errors: "Employee Not Found"}, status: :unprocessable_entity
      end
    else
      render json: {errors: "Leave Allocation Parameters Missing"}, status: :unprocessable_entity
    end
  end

  def deactivate_allocated_leaves
    employees = Employee.where(:is_active => true, :company_id => params[:company_id].to_i, :location_id => params[:location_id].to_i)
    if params[:branch_id].to_i != 0
      employees = employees.where(:branch_id => params[:branch_id].to_i)
    end
    if params[:department_id].to_i != 0
      employees = employees.where(:department_id => params[:department_id].to_i)
    end
    if params[:grade_id].to_i != 0
      employees = employees.where(:grade_id => params[:grade_id].to_i)
    end
    employee_ids = employees.collect(&:id)
    LeaveAllocation.where(:employee_id => employee_ids, :is_active => true, :leave_type_id => params[:leave_type_id]).update_all(is_active: false)
    render json:{}, status: 200
  end

  def activate_allocated_leaves
    employees = Employee.where(:is_active => true, :company_id => params[:company_id].to_i, :location_id => params[:location_id].to_i)
    if params[:branch_id].to_i != 0
      employees = employees.where(:branch_id => params[:branch_id].to_i)
    end
    if params[:department_id].to_i != 0
      employees = employees.where(:department_id => params[:department_id].to_i)
    end
    if params[:grade_id].to_i != 0
      employees = employees.where(:grade_id => params[:grade_id].to_i)
    end
    employee_ids = employees.collect(&:id)
    active_leave_year = LeaveYear.find_by_is_active(true)
    LeaveAllocation.where(leave_year_id: active_leave_year.id, :employee_id => employee_ids, :is_active => false, :leave_type_id => params[:leave_type_id]).each do |leave_allocation|
      leave_allocation.is_active = true
      leave_allocation.save(:validate => false)
    end
    render json:{}, status: 200
  end

  def allocated_monthly_leave
    LeaveAllocation.manual_monthly_leave_allocation_process
    render json:{}, status: 200
  end

  def destroy
    if @leave_allocation.is_active
      render json: {errors: 'Unable to delete active leave allocation'}, status: :unprocessable_entity
    else
      @leave_allocation.destroy
      render json:{}, status: 200
    end
  end

	private

	def leave_allocation_params
		params.permit(:company_id, :employee_id, :leave_type_id, :location_id)
	end

  def set_leave_allocation
    @leave_allocation = LeaveAllocation.find(params[:id])
  end

  def filter_leave_allocation_data_on_request
    if not params[:location_id].blank?
      @leave_allocations = LeaveAllocation.location_related_leave_allocation(@leave_allocations, params[:location_id].to_i)
    end
    if not params[:leave_type_id].blank?
      @leave_allocations = LeaveAllocation.leave_type_related_leave_allocation(@leave_allocations, params[:leave_type_id].to_i)
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
