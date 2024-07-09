class Api::V1::Web::AttendanceManagement::AttendanceCutoffsController < ApplicationController

	before_filter :set_attendance_cutoff, :only => [:show, :update, :destroy, :execute_attendance_cut_off, :download_attendance_cutoff, :cut_off_employee_list, :cut_off_adjustment_list]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @attendance_cutoffs = AttendanceCutoff.all.order('id DESC')
    else
      @attendance_cutoffs = AttendanceCutoff.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/attendance_management/attendance_cutoffs/index.json.jbuilder'
  end

  def filter_data
    @attendance_cutoffs = AttendanceCutoff.where(:company_id => params[:company_id], :is_executed => true).order('id DESC')
    render status:200, template: 'api/v1/web/attendance_management/attendance_cutoffs/index.json.jbuilder'
  end

  def locaiton_filter_data
    @attendance_cutoffs = AttendanceCutoff.where(:company_id => current_user.company_id, :is_executed => true).order('id DESC')
    render status:200, template: 'api/v1/web/attendance_management/attendance_cutoffs/index.json.jbuilder'
  end

  def check_cutoff_month
    pay_month = params['pay_month'].to_date.strftime('%B %Y')
    cutoff_month = AttendanceCutoff.find(params['cutoff_ids'].try(:split, ',')).map{|a| [a.start_date.strftime('%B %Y'), a.end_date.strftime('%B %Y')]}
    unless cutoff_month.flatten.include? pay_month
      render json:{message: "You selected pay month #{pay_month}, but selected cutoff range is #{cutoff_month.flatten.join(', ')}"}, status: 200
    else
      render json:{}, status: 200
    end
  end

  def branch_filter_data
    @attendance_cutoffs = AttendanceCutoff.where(:branch_id => params[:branch_id], :is_executed => true).order('id DESC')
    render status:200, template: 'api/v1/web/attendance_management/attendance_cutoffs/index.json.jbuilder'
  end

  def salary_unit_filter_data
    @attendance_cutoffs = AttendanceCutoff.where(:salary_unit_id => params[:salary_unit_id], :is_executed => true).order('id DESC')
    render status:200, template: 'api/v1/web/attendance_management/attendance_cutoffs/index.json.jbuilder'
  end

  def create
    @attendance_cutoff       = AttendanceCutoff.new attendance_cutoff_params
    update_attendance_cutoff_dates
    if @attendance_cutoff.save
      render json:{}, status: :created
    else
      render json: {errors: @attendance_cutoff.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def bulk_save
    location = Location.find(params[:location_id].to_i)
    Branch.where(:location_id => params[:location_id].to_i).order('id ASC').each do |branch|
      attendance_cutoff = AttendanceCutoff.new
      attendance_cutoff.company_id = params[:company_id]
      attendance_cutoff.location_id = location.id
      attendance_cutoff.branch_id = branch.id
      attendance_cutoff.name = "#{branch.name} #{params[:name]}"
      attendance_cutoff.description = params[:description]
      attendance_cutoff.salary_unit_id = nil
      attendance_cutoff.salary_unit_wise = false
      if params[:start_date].nil?
        attendance_cutoff.start_date = nil
      else
        attendance_cutoff.start_date = params[:start_date].to_date
      end
      if params[:end_date].nil?
        attendance_cutoff.end_date = nil
      else
        attendance_cutoff.end_date = params[:end_date].to_date
      end
      attendance_cutoff.save
    end
    render json:{}, status: :created
  end

  def show
    render status:200, template: 'api/v1/web/attendance_management/attendance_cutoffs/show.json.jbuilder'
  end

  def update
    update_attendance_cutoff_dates
    if @attendance_cutoff.update(attendance_cutoff_params)
      render json: {}, status: 204
    else
      render json: {errors: @attendance_cutoff.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @attendance_cutoff.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @attendance_cutoff.errors.full_messages}, status: :unprocessable_entity
  	end
  end

  def execute_attendance_cut_off
    FinalizeAttendance.finalize_attendance(@attendance_cutoff, @attendance_cutoff.start_date.to_date, @attendance_cutoff.end_date.to_date)
    @attendance_cutoff.is_executed = true
    @attendance_cutoff.save
    render json: {}, status: 201
  end

  def bulk_execute_attendance_cut_off
    if params[:attendance_cutoff_ids].nil?
      render json: {errors: "Please Select Attendance Cutoff"}, status: :unprocessable_entity
    else
      attendance_cutoff_ids = params[:attendance_cutoff_ids].map(&:to_i)
      AttendanceCutoff.where(:id => attendance_cutoff_ids, :is_executed => false).order('id ASC').each do |attendance_cutoff|
        FinalizeAttendance.finalize_attendance(attendance_cutoff, attendance_cutoff.start_date.to_date, attendance_cutoff.end_date.to_date)
        attendance_cutoff.is_executed = true
        attendance_cutoff.save
      end
      render json: {}, status: 204  
    end
  end

  def cut_off_employee_list
    employee_ids = @attendance_cutoff.finalize_attendances.collect(&:employee_id).uniq
    @employees = Employee.where(:id => employee_ids, :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/employee_management/employees/filter_data.json.jbuilder'
  end

  def cut_off_adjustment_list
    @finalize_attendances = @attendance_cutoff.finalize_attendances.where(:employee_id => params[:employee_id])
    render status:200, template: 'api/v1/web/attendance_management/attendance_cutoffs/cut_off_adjustment_list.json.jbuilder'
  end

  def save_cut_off_adjustment
    if params[:finalize_attendances].present?
      finalize_attendances = params[:finalize_attendances]
      if finalize_attendances.count > 0
        Array.new(finalize_attendances.count).each_index do |index|
          adjust_attendance = FinalizeAttendance.find(finalize_attendances[index.to_s][:finalize_attendance_id])
          adjust_attendance.arrear_days      = finalize_attendances[index.to_s][:arrear_days].to_f
          adjust_attendance.pay_deduction    = finalize_attendances[index.to_s][:pay_deduction].to_f
          adjust_attendance.over_time_hours  = finalize_attendances[index.to_s][:over_time_hours].to_f
          adjust_attendance.off_day_payment  = finalize_attendances[index.to_s][:off_day_payment].to_f
          adjust_attendance.encashable_quota = finalize_attendances[index.to_s][:encashable_quota].to_f
          adjust_attendance.save
        end
      end
    end
    render json:{}, status: :created
  end

  def download_attendance_cutoff
    book = Axlsx::Package.new
    check_directory("#{Rails.public_path}/excel")
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'Cutoff')
    book.use_autowidth = false
    sheet.sheet_view do |view|
      view.show_outline_symbols = true
    end
    book.use_autowidth = true
    bold_column_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
    sheet.add_row ["Sr #", "Emp Code", "Name", "Arrears", "Over Time", "Off Day", "Deduction", "Encashable Quota"], :style => bold_column_format
    old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "106CC4", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, b: true)
    even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "641E16", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, b: true)
    count = 0
    employee_ids = @attendance_cutoff.finalize_attendances.collect(&:employee_id).uniq
    employee_ids.each do |employee_id|
      employee = Employee.find(employee_id)
      if employee.is_active == true
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

        current_row_value << employee.employee_code.to_i
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.full_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << @attendance_cutoff.finalize_attendances.where(:employee_id => employee.id).sum(:arrear_days)
        current_row_style << row_format
        current_row_type << :float

        current_row_value << @attendance_cutoff.finalize_attendances.where(:employee_id => employee.id).sum(:over_time_hours)
        current_row_style << row_format
        current_row_type << :float

        current_row_value << @attendance_cutoff.finalize_attendances.where(:employee_id => employee.id).sum(:off_day_payment)
        current_row_style << row_format
        current_row_type << :float

        current_row_value << @attendance_cutoff.finalize_attendances.where(:employee_id => employee.id).sum(:pay_deduction)
        current_row_style << row_format
        current_row_type << :float

        current_row_value << @attendance_cutoff.finalize_attendances.where(:employee_id => employee.id).sum(:encashable_quota)
        current_row_style << row_format
        current_row_type << :float

        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
    end
    file_name = "cutoff_report"
    url_path = save_excel_file(book, file_name)
    render json: {message: "Excel Created", path: url_path}
  end

  def bulk_download_attendance_cutoff
    if params[:attendance_cutoff_ids].nil?
      render json: {errors: "Please Select Attendance Cutoff"}, status: :unprocessable_entity
    else
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Cutoff')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      bold_column_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
      sheet.add_row ["Sr #", "Emp Code", "Name", "Arrears", "Over Time", "Off Day", "Deduction", "Encashable Quota"], :style => bold_column_format
      old_row_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "106CC4", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, b: true)
      even_row_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "641E16", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, b: true)
      count = 0
      attendance_cutoff_ids = params[:attendance_cutoff_ids].map(&:to_i)
      AttendanceCutoff.where(:id => attendance_cutoff_ids, :is_executed => true).order('id ASC').each do |attendance_cutoff|
        employee_ids = attendance_cutoff.finalize_attendances.collect(&:employee_id).uniq
        employee_ids.each do |employee_id|
          employee = Employee.find(employee_id)
          if employee.is_active == true
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

            current_row_value << employee.employee_code.to_i
            current_row_style << row_format
            current_row_type << :integer

            current_row_value << employee.full_name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << attendance_cutoff.finalize_attendances.where(:employee_id => employee.id).sum(:arrear_days)
            current_row_style << row_format
            current_row_type << :float

            current_row_value << attendance_cutoff.finalize_attendances.where(:employee_id => employee.id).sum(:over_time_hours)
            current_row_style << row_format
            current_row_type << :float

            current_row_value << attendance_cutoff.finalize_attendances.where(:employee_id => employee.id).sum(:off_day_payment)
            current_row_style << row_format
            current_row_type << :float

            current_row_value << attendance_cutoff.finalize_attendances.where(:employee_id => employee.id).sum(:pay_deduction)
            current_row_style << row_format
            current_row_type << :float

            current_row_value << attendance_cutoff.finalize_attendances.where(:employee_id => employee.id).sum(:encashable_quota)
            current_row_style << row_format
            current_row_type << :float

            sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
          end
        end
      end
      file_name = "bulk_cutoff_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    end
  end

	private

	def attendance_cutoff_params
		params.permit(:company_id, :location_id, :branch_id, :name, :description, :salary_unit_id, :salary_unit_wise)
	end

  def set_attendance_cutoff
    @attendance_cutoff = AttendanceCutoff.find(params[:id])
  end

  def update_attendance_cutoff_dates
    if params[:start_date].nil?
      @attendance_cutoff.start_date = nil
    else
      @attendance_cutoff.start_date = params[:start_date].to_date
    end
    if params[:end_date].nil?
      @attendance_cutoff.end_date = nil
    else
      @attendance_cutoff.end_date = params[:end_date].to_date
    end
  end

  def check_directory(dir_path)
    unless File.directory?(dir_path)
      Dir.mkdir(dir_path)
    end
  end

end
