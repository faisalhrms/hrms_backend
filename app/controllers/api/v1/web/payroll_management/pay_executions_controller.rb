class Api::V1::Web::PayrollManagement::PayExecutionsController < ApplicationController

	before_filter :set_pay_execution, :only => [:show, :update, :destroy, :generate_payroll, :regenerate_payroll, :locked_payroll, :bulk_download_slip, :download_tax_working]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @pay_executions = PayExecution.all.order('id DESC')
    else
      @pay_executions = PayExecution.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/payroll_management/pay_executions/index.json.jbuilder'
  end

  def filter_data
    @pay_executions = PayExecution.where(:company_id => params[:company_id]).order('id DESC')
    render status:200, template: 'api/v1/web/payroll_management/pay_executions/index.json.jbuilder'
  end

  def fixed_pay_executions
    @pay_executions = PayExecution.where(:company_id => params[:company_id], :calculation_type => "Fixed").order('id DESC')
    render status:200, template: 'api/v1/web/payroll_management/pay_executions/index.json.jbuilder'
  end

  def create
    @pay_execution       = PayExecution.new pay_execution_params
    @pay_execution.attendance_cutoff_ids   = params[:attendance_cutoff_ids].map(&:to_i).join(',')
    @pay_execution.grade_ids               = params[:grade_ids].map(&:to_i).join(',')
    @pay_execution.pay_month 						   = params[:pay_month].to_date
		@pay_execution.formated_pay_month 	   = params[:pay_month].to_date.strftime("%B %Y")
    if not params[:joining_exception_month].nil?
      @pay_execution.joining_exception_month            = params[:joining_exception_month].to_date
      @pay_execution.joining_exception_formated_month   = params[:joining_exception_month].to_date.strftime("%B %Y")  
    end
    allocate_date
    if @pay_execution.save
      save_or_update_item_execution_detail
      render json:{}, status: :created
    else
      render json: {errors: @pay_execution.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/payroll_management/pay_executions/show.json.jbuilder'
  end

  def update
    @pay_execution.grade_ids              = params[:grade_ids].map(&:to_i).join(',')
    @pay_execution.attendance_cutoff_ids  = params[:attendance_cutoff_ids].map(&:to_i).join(',')
  	@pay_execution.pay_month 						  = params[:pay_month].to_date
		@pay_execution.formated_pay_month 	   = params[:pay_month].to_date.strftime("%B %Y")
    if not params[:joining_exception_month].nil?
      if not params[:joining_exception_month].blank?
        @pay_execution.joining_exception_month            = params[:joining_exception_month].to_date
        @pay_execution.joining_exception_formated_month   = params[:joining_exception_month].to_date.strftime("%B %Y")  
      end
    end
    allocate_date
    if @pay_execution.update(pay_execution_params)
      save_or_update_item_execution_detail
      render json: {}, status: 204
    else
      render json: {errors: @pay_execution.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @pay_execution.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @pay_execution.errors.full_messages}, status: :unprocessable_entity
  	end
  end

  def generate_payroll
    if not @pay_execution.grade_ids.nil?
      PayExecution.generate_payroll(@pay_execution)
      @pay_execution.is_generated = true
      @pay_execution.save
      render json: {}, status: 204
    else
      render json: {errors: "Grade Not Selected In Pay Execution"}, status: :unprocessable_entity
    end
  end

  def regenerate_payroll
    if not @pay_execution.grade_ids.nil?
      if @pay_execution.pay_invoices.count == @pay_execution.pay_invoices.where(:is_locked => false).count
        PayExecution.regenerate_payroll(@pay_execution)
        render json: {}, status: 204  
      else
        render json: {errors: "Bulk Re-generation not allowed because some pay slips are manually locked"}, status: :unprocessable_entity
      end
    else
      render json: {errors: "Grade Not Selected In Pay Execution"}, status: :unprocessable_entity
    end
  end

  def locked_payroll
    PayExecution.locked_payroll(@pay_execution)
    @pay_execution.is_locked = true
    @pay_execution.save
    employee_ids = @pay_execution.pay_invoices.collect(&:employee_id).uniq
    Employee.where(:id => employee_ids).order('id ASC').each do |employee|
      employee.back_date_eobi_impact = false
      employee.back_date_pf_impact = false
      employee.back_date_allowance_impact = false
      employee.save
    end
    render json: {}, status: 204
  end

  def bulk_download_slip
    @show_salary    = User.show_salary(current_user)
    @pay_invoices = @pay_execution.pay_invoices.includes(:employee, :department, :sub_department).where(:status => true).order('departments.name ASC, sub_departments.name ASC, employees.employee_code ASC')
    check_directory("#{Rails.public_path}/pdf")
    if params[:page_spliting] == "Three Slips on 1 Page"
      file_name = ENV.fetch("APP_URL").include?('millshrmsbe.dfl.com.pk') ? "multiple_invoice_mill" : "multiple_invoice"
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/web/reports/payroll_reports/#{file_name}.pdf.erb"),
        :margin => {
          :top      => '0.1in',
          :bottom   => '0.1in',
          :left     => '0.1in',
          :right    => '0.1in'
        },
        dpi: 320,
        orientation: 'Portrait',
        page_size:'A4'
      )
    else
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/web/reports/payroll_reports/bulk_invoice.pdf.erb"),
        footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
        :margin => {
          :top      => '0.1in',
          :bottom   => '0.1in',
          :left     => '0.1in',
          :right    => '0.1in'
        },
        dpi: 320,
        orientation: 'Portrait',
      )
    end
    file_name = "salary_slip"
    url_path = save_pdf_file(pdf, file_name)
    render json: {message: "Pdf Created", path: url_path}
  end

  def bulk_download_slip_all
    @show_salary    = User.show_salary(current_user)
    @pay_invoices = []
    pay_executions = PayExecution.all.order('id DESC')
    pay_executions.each do |pay_execution|
      @pay_invoices << pay_execution.pay_invoices.includes(:employee, :department, :sub_department).where(:status => true).order('departments.name ASC, sub_departments.name ASC, employees.employee_code ASC')
    end
    @pay_invoices = @pay_invoices.flatten.compact.uniq
    check_directory("#{Rails.public_path}/pdf")
    if params[:page_spliting] == "Three Slips on 1 Page"
      file_name = ENV.fetch("APP_URL").include?('millshrmsbe.dfl.com.pk') ? "multiple_invoice_mill" : "multiple_invoice"
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/web/reports/payroll_reports/#{file_name}.pdf.erb"),
        :margin => {
          :top      => '0.1in',
          :bottom   => '0.1in',
          :left     => '0.1in',
          :right    => '0.1in'
        },
        dpi: 320,
        orientation: 'Portrait',
        page_size:'A4'
      )
    else
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/web/reports/payroll_reports/bulk_invoice.pdf.erb"),
        footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
        :margin => {
          :top      => '0.1in',
          :bottom   => '0.1in',
          :left     => '0.1in',
          :right    => '0.1in'
        },
        dpi: 320,
        orientation: 'Portrait',
        )
    end
    file_name = "salary_slip"
    url_path = save_pdf_file(pdf, file_name)
    render json: {message: "Pdf Created", path: url_path}
  end

  def download_tax_working
    time = Time.now
    check_directory("#{Rails.public_path}/excel")
    book = Axlsx::Package.new
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'Tax Working')
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

    bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
    header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
    table_header = ["Sr #", "Emp Code", "Name", "Salary Unit", "Current Taxable Amount", "Prev Taxable Amount", "Predicated Taxable Amount", "Taxable Amount To Date", "Prev Incentive Amount", "Current Incentive Amount", "Loan Interest Amount", "Gross Salary", "Total Taxable Amount", "Tax Created", "Yearly Total Tax", "Monthly Tax Amount", "Total Paid Tax", "Remaing Tax To Be Paid", "Encashable Quota", "Predition Amount", "Predition Item Amounts", "Predition Item Ids", "Predition Item Names", "Prev Vehicle Tax", "Current Month Vehicle Tax", "Predicted Vehicle Tax", "Employeer PF Value", "Predicted PF Value", "PF Tax Value", "Employeer Eobi Value", "Annualize Predicated Taxable Amount"]

    sheet.add_row table_header, :style => header_style
    old_row_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    old1_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    even_row_format = wb.styles.add_style(:num_fmt => 3, :bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    count = 0
    @pay_execution.pay_invoices.where(:status => true).each do |pay_invoice|
      employee_taxable_income = pay_invoice.employee_taxable_income

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
      current_row_style << old1_row_format
      current_row_type << :integer

      current_row_value << pay_invoice.employee_code.to_i
      current_row_style << old1_row_format
      current_row_type << :integer

      current_row_value << pay_invoice.employee_name
      current_row_style << old1_row_format
      current_row_type << :string

      current_row_value << pay_invoice.salary_unit_name
      current_row_style << old1_row_format
      current_row_type << :string

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.current_taxable_amount.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.prev_taxable_amount.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.predicated_taxable_amount.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.taxable_amount_to_date.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.prev_incentive_amount.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.current_incentive_amount.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.loan_interest_amount.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.gross_salary.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.total_taxable_amount.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(EmployeeTaxCredit.where(:employee_id => pay_invoice.employee_id, :fiscal_year_id => pay_invoice.fiscal_year_id).sum(:tax_credit_amount).to_f.round)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.yearly_total_tax.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.monthly_tax_amount.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.total_paid_tax.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.remaing_tax_to_be_paid.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.encashable_quota.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.predition_amount.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << employee_taxable_income.predition_item_amounts
      current_row_style << old1_row_format
      # current_row_type << :string

      current_row_value << employee_taxable_income.predition_item_ids
      current_row_style << old1_row_format
      # current_row_type << :string

      current_row_value << employee_taxable_income.predition_item_names
      current_row_style << old1_row_format
      # current_row_type << :string

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.prev_vehicle_tax.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.current_month_vehicle_tax.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.predicted_vehicle_tax.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.employeer_pf_value.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.predicted_pf_value.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.pf_tax_value.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.employeer_eobi_value.to_f)
      current_row_style << row_format
      # current_row_type << :float

      current_row_value << ReportFormat.zero_to_dash(employee_taxable_income.annualize_predicated_taxable_amount.to_f)
      current_row_style << row_format
      # current_row_type << :float

      sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
    end

    file_name = "employee_taxable_income"
    url_path = save_excel_file(book, file_name)
    render json: {message: "Excel Created", path: url_path}
  end

	private

	def pay_execution_params
		params.permit(:name, :company_id, :location_id, :provident_fund_id, :eobi_id, :tax_slab_id, :fiscal_year_id, :tax_applicable, :no_of_pay_days, :per_litre_rate, :incentive_impact_on_tax, :prediction_tax_impact, :opd_impact_on_arrear, :vehicle_impact_on_tax, :vehicle_tax_percentage, :allowed_urdu, :exclude_sunday, :joining_exception_pay_days, :joining_exception, :vehicle_monthly_prorated, :allowed_extra_days)
	end

  def set_pay_execution
    @pay_execution = PayExecution.find(params[:id])
  end

  def allocate_date
    if params[:start_date].nil?
      @pay_execution.start_date = nil
    else
      @pay_execution.start_date = params[:start_date].to_date
    end
    if params[:end_date].nil?
      @pay_execution.end_date = nil
    else
      @pay_execution.end_date = params[:end_date].to_date
    end
    if params[:incentive_month].nil?
      @pay_execution.incentive_month  = nil
    else
      @pay_execution.incentive_month  = params[:incentive_month].to_date
    end
  end

  def save_or_update_item_execution_detail
    if params[:item_details].present?
      item_details = params[:item_details]
      if item_details.count > 0
        Array.new(item_details.count).each_index do |index|
          if item_details[index.to_s][:item_execution_detail_id].nil?
            item_execution_detail                     = @pay_execution.item_execution_details.build
            item_execution_detail.pay_item_id         = item_details[index.to_s][:id].to_i
            item_execution_detail.status              = item_details[index.to_s][:status]
            item_execution_detail.save
          else
            edit_item_execution_detail                = @pay_execution.item_execution_details.find item_details[index.to_s][:item_execution_detail_id]
            edit_item_execution_detail.pay_item_id    = item_details[index.to_s][:id].to_i
            edit_item_execution_detail.status         = item_details[index.to_s][:status]
            edit_item_execution_detail.save
          end
        end
      end
    end
  end

  def check_directory(dir_path)
    unless File.directory?(dir_path)
      Dir.mkdir(dir_path)
    end
  end

end
