class Api::V1::Web::PayrollManagement::EmployeeTaxDetailsController < ApplicationController

	before_filter :set_employee, :only => [:show, :update]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def show
  	@fiscal_year = FiscalYear.find_by(:company_id => @employee.company_id, :is_active => true)
  	@pay_invoices = PayInvoice.where(:employee_id => @employee.id, :status => true, :fiscal_year_id => @fiscal_year.id).order('id ASC')
    render status:200, template: 'api/v1/web/payroll_management/employee_tax_details/show.json.jbuilder'
  end

  def update
  	if params[:employee_taxable_incomes].present?
      employee_taxable_incomes = params[:employee_taxable_incomes]
      if employee_taxable_incomes.count > 0
        Array.new(employee_taxable_incomes.count).each_index do |index|
          employee_taxable_income = EmployeeTaxableIncome.find(employee_taxable_incomes[index.to_s][:employee_taxable_income_id])
          employee_taxable_income.taxable_amount_to_date 	  = employee_taxable_incomes[index.to_s][:taxable_amount_to_date].to_f
          employee_taxable_income.current_month_vehicle_tax = employee_taxable_incomes[index.to_s][:current_month_vehicle_tax].to_f
          employee_taxable_income.employeer_pf_value 			  = employee_taxable_incomes[index.to_s][:employeer_pf_value].to_f
          employee_taxable_income.monthly_tax_amount        = employee_taxable_incomes[index.to_s][:monthly_tax_amount].to_f
          employee_taxable_income.cpr_date                  = employee_taxable_incomes[index.to_s][:cpr_date]
          employee_taxable_income.cpr_number                = employee_taxable_incomes[index.to_s][:cpr_number]
          employee_taxable_income.save
          pay_invoice             = employee_taxable_income.pay_invoice
          pay_invoice.monthly_tax = employee_taxable_income.monthly_tax_amount
          pay_invoice.save
        end
      end
    end
    render json: {}, status: 204
  end

  def download_sample_csv_file
    time = Time.now
    file_name = "sample_import_#{time.to_i}.csv"
    save_path = "#{Rails.public_path}/excel/#{file_name}"
    CSV.open("#{save_path}", "wb") do |csv|
      csv << ["employee_code", "pay_month", "cpr_date", "cpr_number"]
      csv << ["400839", "July 2021", "03/08/2021", "IT2021080301011037612"]
      csv << ["801163", "July 2021", "03/08/2021", "IT2021080301011037612"]
      csv << ["275044", "July 2021", "03/08/2021", "IT2021080301011037612"]
      csv << ["801161", "July 2021", "03/08/2021", "IT2021080301011037612"]
    end
    render json: {message: "CSV Created", path: "/excel/#{file_name}"}, status: 200
  end

  def bulk_import_employee_cpr
    response_messages = []
    file = params[:file]
    employee_data = SmarterCSV.process(file.tempfile)
    fiscal_year = FiscalYear.active
    employee_data.each_with_index do |employee_detail,index|
      remarks = []
      employee = Employee.where(employee_code: employee_detail[:employee_code]).active.last
      if employee.present?
        pay_invoice = employee.pay_invoices.where(status: true, fiscal_year_id: fiscal_year.id, pay_month: employee_detail[:pay_month]).last
        if pay_invoice.present?
          if pay_invoice.employee_taxable_income.present?
            employee_taxable_income = pay_invoice.employee_taxable_income
            employee_taxable_income.cpr_date = employee_detail[:cpr_date]
            employee_taxable_income.cpr_number = employee_detail[:cpr_number].to_s
            if employee_taxable_income.save
              remarks << "Employee CPR saved"
            else
              remarks << employee_taxable_income.errors.full_messages.join(',')
            end
          end
        else
          remarks << "Employee Income Tax not deducted"
        end
      else
        remarks << "Employee not active"
      end
      temp_obj = {
        employee_code: employee_detail[:employee_code],
        remarks: remarks.join(',')
      }
      response_messages << temp_obj
    end
    render json:{:response_messages => response_messages}, status: 200
  end


	private

  def set_employee
    @employee = Employee.find(params[:id])
  end
  
end
