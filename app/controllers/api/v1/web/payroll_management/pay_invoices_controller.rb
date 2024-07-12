class Api::V1::Web::PayrollManagement::PayInvoicesController < ApplicationController

  before_action :set_pay_invoice, :only => [:show, :update_tax_adjustment]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

	def current_pay_invoices
    @pay_invoices = PayInvoice.where(:company_id => params[:company_id], :status => true, :pay_month => params[:pay_month].to_date.strftime("%B %Y")).includes(:employee)
    filter_invoice_data_on_request
    render status:200, template: 'api/v1/web/payroll_management/pay_invoices/index'
  end

  def my_salary_slip_list
    if not current_user.employee.nil?
      @pay_invoices = PayInvoice.where(:employee_id => current_user.employee.id, :status => true, :is_locked => true).order('id DESC')
      render status:200, template: 'api/v1/web/payroll_management/pay_invoices/index'    
    else
      @pay_invoices = []
      render status:200, template: 'api/v1/web/payroll_management/pay_invoices/index'    
    end    
  end

  def subordinate_pay_invoices
    subordinate_employee_ids = []
    if not current_user.employee.nil?
      if current_user.is_location_head == true
        subordinate_employee_ids = Employee.where(:location_id => current_user.employee.location_id, :is_active => true).collect(&:id)
      elsif current_user.is_branch_head == true
        subordinate_employee_ids = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true).collect(&:id)
      elsif current_user.is_department_head == true
        subordinate_employee_ids = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true).collect(&:id)
      elsif current_user.all_company_department == true
        subordinate_employee_ids = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true).collect(&:id)
      elsif current_user.is_sub_department_head == true
        subordinate_employee_ids = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true).collect(&:id)
      elsif current_user.employee.is_line_manager == true
        employee_ids = Employee.where(:line_manager_id => current_user.employee.id, :is_active => true).collect(&:id)
        employee_ids << current_user.employee.id
        subordinate_employee_ids = Employee.where(:id => employee_ids, :is_active => true).collect(&:id)
      else
        subordinate_employee_ids = []
      end
    else
      subordinate_employee_ids = []
    end
    if current_user.multi_branch_allowed == true
      @employees = Employee.where(:id => subordinate_employee_ids)
      @employees = Employee.multiple_branch_data(@employees, current_user)
      subordinate_employee_ids = @employees.collect(&:id)
    end
    if subordinate_employee_ids.count > 0
      @pay_invoices = PayInvoice.where(:employee_id => subordinate_employee_ids, :company_id => params[:company_id], :status => true, :pay_month => params[:pay_month].to_date.strftime("%B %Y"), :is_locked => true)
      filter_invoice_data_on_request
      render status:200, template: 'api/v1/web/payroll_management/pay_invoices/index'
    else
      @pay_invoices = []
      render status:200, template: 'api/v1/web/payroll_management/pay_invoices/index'
    end
  end

  def download_slip
    @show_salary    = User.show_salary(current_user)
  	@pay_invoice = PayInvoice.find(params[:id])
		@employee = @pay_invoice.employee
    file_name = ENV.fetch("APP_URL").include?('millshrmsbe.dfl.com.pk') ? "salary_slip" : "invoice"
    file_name = 'srl_invoice' if srl_instance? or dtl_instance?
    check_directory("#{Rails.public_path}/pdf")
    pdf = WickedPdf.new.pdf_from_string(
      render_to_string("api/v1/web/reports/payroll_reports/#{file_name}.pdf.erb"),
      footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
      :margin => {
        :top      => '0.1in',
        :bottom   => '0.1in',
        :left     => '0.1in',
        :right    => '0.1in'
      },
      dpi: 320,
    )

    file_name = "#{file_name}_#{@employee.employee_code}"
    url_path = save_pdf_file(pdf, file_name)
    render json: {message: "Pdf Created", path: url_path}
	end

  def regenerate
    pay_invoice   = PayInvoice.find(params[:id])
    pay_execution = pay_invoice.pay_execution
    employee      = Employee.find(pay_invoice.employee_id)
    PayInvoice.regenerate_slip(employee, pay_invoice, pay_execution)
    render json: {}, status: 204
  end

  def locked_pay_invoice
    pay_invoice   = PayInvoice.find(params[:id])
    pay_invoice.is_locked = true
    pay_invoice.save
    render json: {}, status: 204
  end

  def show
    render status:200, template: 'api/v1/web/payroll_management/pay_invoices/show'
  end

  def update_tax_adjustment
    @pay_invoice.monthly_tax = params[:monthly_tax].to_f.round
    @pay_invoice.save
    employee_taxable_income = @pay_invoice.employee_taxable_income
    if not employee_taxable_income.nil?
      employee_taxable_income.monthly_tax_amount = params[:monthly_tax].to_f.round
      employee_taxable_income.save
    end
    render json: {}, status: 204
  end

  private

  def filter_invoice_data_on_request
    unless params[:location_id].blank?
      @pay_invoices = @pay_invoices.where(:location_id => params[:location_id].to_i)
    end
    unless params[:branch_id].blank?
      @pay_invoices = @pay_invoices.where(:branch_id => params[:branch_id].to_i)
    end
    unless params[:department_id].blank?
      @pay_invoices = @pay_invoices.where(:department_id => params[:department_id].to_i)
    end
    unless params[:designation_id].blank?
      @pay_invoices = @pay_invoices.where(:designation_id => params[:designation_id].to_i)
    end
    unless params[:job_title_id].blank?
      @pay_invoices = @pay_invoices.where(:job_title_id => params[:job_title_id].to_i)
    end
    unless params[:grade_id].blank?
      @pay_invoices = @pay_invoices.where(:grade_id => params[:grade_id].to_i)
    end
    unless params[:salary_unit_id].blank?
      @pay_invoices = @pay_invoices.where(:salary_unit_id => params[:salary_unit_id].to_i)
    end
    unless params[:cost_center_id].blank?
      @pay_invoices = @pay_invoices.where(:cost_center_id => params[:cost_center_id].to_i)
    end
    if params[:employment_status] == ''
      @pay_invoices = PayInvoice.on_roll_employees(@pay_invoices, true)
      @pay_invoices = PayInvoice.struck_off_employees(@pay_invoices, false)
    elsif params[:employment_status] == 'resigned'
      @pay_invoices = PayInvoice.on_roll_employees(@pay_invoices, false)
    elsif params[:employment_status] == 'struck_off'
      @pay_invoices = PayInvoice.struck_off_employees(@pay_invoices, true)
    end
    if params[:taxable] == "taxable"
      @pay_invoices = PayInvoice.taxable_employees(@pay_invoices)
    elsif params[:taxable] == "non_taxable"
      @pay_invoices = PayInvoice.non_taxable_employees(@pay_invoices)
    end
  end

  private

  def check_directory(dir_path)
    unless File.directory?(dir_path)
      Dir.mkdir(dir_path)
    end
  end

  def set_pay_invoice
    @pay_invoice = PayInvoice.find(params[:id])
  end

end
