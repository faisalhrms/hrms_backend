class Api::V1::Web::PayrollManagement::EmployeeLoansController < ApplicationController

	before_filter :set_employee_loan, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @employee_loans = EmployeeLoan.all.order('id DESC')
    else
      @employee_loans = EmployeeLoan.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/payroll_management/employee_loans/index.json.jbuilder'
  end

  def filter_data
    @employee_loans = EmployeeLoan.where(:company_id => params[:company_id]).order('id DESC')
    render status:200, template: 'api/v1/web/payroll_management/employee_loans/index.json.jbuilder'
  end

  def get_pay_back_date
    if not (params[:loan_start_date].nil? or params[:loan_start_date].blank?)
      no_of_installment = params[:no_of_installment].to_i - 1
      pay_back_date = params[:loan_start_date].to_date + no_of_installment.month
      render status:200, :json => {:pay_back_date => pay_back_date}
    else
      render status:200, :json => {:pay_back_date => ""}
    end
  end

  def create
    @employee_loan = EmployeeLoan.new(employee_loan_params)
    @employee_loan.loan_start_date = params[:loan_start_date].to_date
    @employee_loan.pay_back_date = params[:pay_back_date].to_date
    if @employee_loan.save
	    if params[:employee_loan_details].present?
	      employee_loan_details = params[:employee_loan_details]
	      if employee_loan_details.count > 0
	        Array.new(employee_loan_details.count).each_index do |index|
	          new_employee_loan_detail = @employee_loan.employee_loan_details.build
	          new_employee_loan_detail.installment_date 						= employee_loan_details[index.to_s][:installment_date].to_date
	          new_employee_loan_detail.formated_month 							= employee_loan_details[index.to_s][:installment_date].to_date.strftime("%B %Y")
	          new_employee_loan_detail.opening_balance 							= employee_loan_details[index.to_s][:opening_balance]
	          new_employee_loan_detail.installment_amount 					= employee_loan_details[index.to_s][:installment_amount]
	          new_employee_loan_detail.closing_balance 							= employee_loan_details[index.to_s][:closing_balance]
	          new_employee_loan_detail.principle_installment_amount = employee_loan_details[index.to_s][:principle_installment_amount]
	          new_employee_loan_detail.loan_interest_amount 				= employee_loan_details[index.to_s][:loan_interest_amount]
	          new_employee_loan_detail.status 											= employee_loan_details[index.to_s][:status]
	          new_employee_loan_detail.remarks 											= employee_loan_details[index.to_s][:remarks]
	          new_employee_loan_detail.save
	        end
	      end
	    end
	    render json:{}, status: :created
	  else
	  	render json: {errors: @employee_loan.errors.full_messages}, status: :unprocessable_entity
	  end
  end

  def employee_loan_detail
    render status:200, template: 'api/v1/web/payroll_management/employee_loans/employee_loan_detail.json.jbuilder'
  end

  def show
    render status:200, template: 'api/v1/web/payroll_management/employee_loans/show.json.jbuilder'
  end

  def update
    if params[:employee_loan_details].present?
      employee_loan_details = params[:employee_loan_details]
      if employee_loan_details.count > 0
        Array.new(employee_loan_details.count).each_index do |index|
          update_employee_loan_detail = @employee_loan.employee_loan_details.find(employee_loan_details[index.to_s][:employee_loan_detail_id].to_i)
          update_employee_loan_detail.installment_date 		= employee_loan_details[index.to_s][:installment_date].to_date
          update_employee_loan_detail.formated_month 			= employee_loan_details[index.to_s][:installment_date].to_date.strftime("%B %Y")
          update_employee_loan_detail.opening_balance 		= employee_loan_details[index.to_s][:opening_balance]
          update_employee_loan_detail.installment_amount 	= employee_loan_details[index.to_s][:installment_amount]
          update_employee_loan_detail.closing_balance 		= employee_loan_details[index.to_s][:closing_balance]
          update_employee_loan_detail.status 							= employee_loan_details[index.to_s][:status]
          if employee_loan_details[index.to_s][:status] == "Paid"
            update_employee_loan_detail.is_cleared = true
          elsif employee_loan_details[index.to_s][:status] == "Exempted"
            update_employee_loan_detail.is_cleared = true
          end
          update_employee_loan_detail.remarks = employee_loan_details[index.to_s][:remarks]
          update_employee_loan_detail.save
        end
      end
    end
    render json:{}, status: :created
  end

  def destroy
  	if @employee_loan.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @employee_loan.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def employee_loan_params
    params.permit(:gross_salary, :company_id, :employee_id, :loan_type, :loan_amount, :no_of_installment, :monthly_installment, :is_taxable, :principle_loan_amount, :annual_interest_rate)
  end

  def set_employee_loan
    @employee_loan = EmployeeLoan.find(params[:id])
  end


end
