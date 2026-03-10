class Api::V1::Web::Reports::OfficialDutyReportsController < ApplicationController

	def od_register

		is_active = true
    if params[:is_active] == "Active"
      is_active = true
    else
      is_active = false
    end
    
    @company = Company.find (params[:company_id])
    date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}   
    @official_duties = OfficialDuty.where(:company_id => params[:company_id], :created_at => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day).order('id ASC')
    @employees = Employee.where(:company_id => params[:company_id], :is_active => is_active, :excluded_from_reports => false).order('id DESC')
    @location_name = ""
    @branch_name = ""
    @department_name = ""
    @grade_name = ""
    @salary_unit_name = ""

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
      @official_duties = @official_duties.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
      @official_duties = @official_duties.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
      @official_duties = @official_duties.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
      @official_duties = @official_duties.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
      @official_duties = @official_duties.where(:employee_id => @employees.collect(&:id).uniq)
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
        @official_duties = @official_duties.where(:employee_id => @employees.collect(&:id).uniq)
      else
        @employees = Employee.where(:id => current_user.employee.id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
        @official_duties = @official_duties.where(:employee_id => @employees.collect(&:id).uniq) 
      end
    end
    #################### Hierarchical Permission ####################

    if not params[:location_id].blank?
      @location_name = Location.find(params[:location_id]).name
      @employees = Employee.location_related_employee(@employees, params[:location_id].to_i)
      @official_duties = @official_duties.where(:employee_id => @employees.collect(&:id).uniq)
    end
    if not params[:branch_id].blank?
      @branch_name = Branch.find(params[:branch_id]).name
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
      @official_duties = @official_duties.where(:employee_id => @employees.collect(&:id).uniq)
    end
    if not params[:department_id].blank?
      @department_name = Department.find(params[:department_id]).name
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
      @official_duties = @official_duties.where(:employee_id => @employees.collect(&:id).uniq)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
      @official_duties = @official_duties.where(:employee_id => @employees.collect(&:id).uniq)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
      @official_duties = @official_duties.where(:employee_id => @employees.collect(&:id).uniq)
    end
    if not params[:grade_id].blank?
      @grade_name = Grade.find(params[:grade_id]).name
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].to_i)
      @official_duties = @official_duties.where(:employee_id => @employees.collect(&:id).uniq)
    end
    if not params[:salary_unit_id].blank?
      @salary_unit_name = SalaryUnit.find(params[:salary_unit_id]).name
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
      @official_duties = @official_duties.where(:employee_id => @employees.collect(&:id).uniq)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
      @official_duties = @official_duties.where(:employee_id => @employees.collect(&:id).uniq)
    end

    if @official_duties.count > 0
      if params[:report_type].to_i == 1
        render status:200, template: 'api/v1/web/reports/official_duty_reports/od_register'
      elsif params[:report_type].to_i == 2
        time = Time.now
        url_path = ""
        check_directory("#{Rails.public_path}/pdf")
        pdf = WickedPdf.new.pdf_from_string(
          render_to_string("api/v1/web/reports/official_duty_reports/od_register", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
          footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
          :margin => {
            :top      => '0.1in',
            :bottom   => '0.1in',
            :left     => '0.1in',
            :right    => '0.1in'
          },
          dpi: 300,
          orientation: 'Landscape'
        )
        file_name = "od_register"
        url_path = save_pdf_file(pdf, file_name)
        render json: {message: "Pdf Created", path: url_path}
      elsif params[:report_type].to_i == 3
        time = Time.now
        book = Axlsx::Package.new
        check_directory("#{Rails.public_path}/excel")
        wb = book.workbook
        sheet = wb.add_worksheet(name: 'OD Register')
        book.use_autowidth = false
        sheet.sheet_view do |view|
          view.show_outline_symbols = true
        end
        book.use_autowidth = true

        header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
        bold_column_format = wb.styles.add_style(:bg_color => "e5e7e4", :fg_color=> "000000", :sz => 14, :height => 20, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
        old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
        even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
        row_count = 0
        sheet.add_row ["Sr #", "Emp Code", "NAME", "Grade", "Designation", "Department", "Job Title", "Apply Date", "From Date", "To Date", "No of ODS", "Status", "Official Duty Mode", "Location", "Branch"], :style => header_style

        count = 0

        @official_duties.each do |official_duty|
          count = count + 1
          row_format = old_row_format 
          
          current_row_value = []
          current_row_style = []
          current_row_type = []

          current_row_value << count
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << official_duty.employee_code.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << official_duty.employee_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << official_duty.grade_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << official_duty.designation_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << official_duty.department_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << official_duty.job_title_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(official_duty.created_at)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(official_duty.start_date)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(official_duty.end_date)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << official_duty.request_count
          current_row_style << row_format
          current_row_type << :float

          current_row_value << official_duty.request_status
          current_row_style << row_format
          current_row_type << :string

          current_row_value << official_duty.normalized_official_duty_mode
          current_row_style << row_format
          current_row_type << :string

          current_row_value << official_duty.location_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << official_duty.branch_name
          current_row_style << row_format
          current_row_type << :string

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
          row_count = row_count + 1
        end

        file_name = "od_register"
        url_path = save_excel_file(book, file_name)
        render json: {message: "Excel Created", path: url_path}
      end
     else
      render json: {errors: "No Record Found"}, status: :unprocessable_entity
    end
	end

	private

  def check_directory(dir_path)
    unless File.directory?(dir_path)
      Dir.mkdir(dir_path)
    end
  end

end
