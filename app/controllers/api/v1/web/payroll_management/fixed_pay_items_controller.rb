class Api::V1::Web::PayrollManagement::FixedPayItemsController < ApplicationController

	before_filter :set_fixed_pay_item, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @fixed_pay_items = FixedPayItem.includes(:employee, :pay_item).order('id DESC')
    else
      @fixed_pay_items = FixedPayItem.includes(:employee, :pay_item).where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/payroll_management/fixed_pay_items/index.json.jbuilder'
  end

  def filter_data
    @fixed_pay_items = FixedPayItem.where(:company_id => params[:company_id]).order('id DESC')
    render status:200, template: 'api/v1/web/payroll_management/fixed_pay_items/index.json.jbuilder'
  end

  def create
    @fixed_pay_item       = FixedPayItem.new fixed_pay_item_params
    if params[:item_type] == "Recurring"
      @fixed_pay_item.pay_month = nil
      @fixed_pay_item.formated_pay_month = nil
    else
      if not params[:pay_month].nil?
        @fixed_pay_item.pay_month = params[:pay_month].to_date
        @fixed_pay_item.formated_pay_month = params[:pay_month].to_date.strftime("%B %Y")
      else
        @fixed_pay_item.pay_month = nil
        @fixed_pay_item.formated_pay_month = nil
      end
    end
    if @fixed_pay_item.save
      render json:{}, status: :created
    else
      render json: {errors: @fixed_pay_item.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def deactive_item
    FixedPayItem.where(:pay_item_id => params[:pay_item_id], :company_id => params[:company_id]).each do |fixed_pay_item|
      fixed_pay_item.is_active = false
      fixed_pay_item.save
    end
    render json: {}, status: 204
  end

  def bulk_deletion
    FixedPayItem.where(:pay_item_id => params[:pay_item_id], :company_id => params[:company_id]).destroy_all
    render json: {}, status: 204
  end

  def show
    render status:200, template: 'api/v1/web/payroll_management/fixed_pay_items/show.json.jbuilder'
  end

  def update
    if params[:item_type] == "Recurring"
      @fixed_pay_item.pay_month = nil
      @fixed_pay_item.formated_pay_month = nil
    else
      if not params[:pay_month].nil?
        @fixed_pay_item.pay_month = params[:pay_month].to_date
        @fixed_pay_item.formated_pay_month = params[:pay_month].to_date.strftime("%B %Y")
      else
        @fixed_pay_item.pay_month = nil
        @fixed_pay_item.formated_pay_month = nil
      end
    end
    if @fixed_pay_item.update(fixed_pay_item_params)
      render json: {}, status: 204
    else
      render json: {errors: @fixed_pay_item.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @fixed_pay_item.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @fixed_pay_item.errors.full_messages}, status: :unprocessable_entity
  	end
  end

  def download_sample_csv_file
    time = Time.now
    file_name = "sample_import_#{time.to_i}.csv"
    save_path = "#{Rails.public_path}/excel/#{file_name}"
    CSV.open("#{save_path}", "wb") do |csv|
      csv << ["pay_item_name", "employee_code", "item_amount", "pay_month", "item_type"]
      csv << ["Educational Allowance", "1020", "220", "-", "Recurring"]
      csv << ["Mobile Allowance", "1020", "220", "09/02/2019", "Once"]
      csv << ["Mobile Deduction", "1022", "250", "20/02/2019", "Once"]
      csv << ["Fuel Deduction", "1022", "250", "-", "Recurring"]
    end
    render json: {message: "CSV Created", path: "/excel/#{file_name}"}, status: 200
  end

  def bulk_import_items
  	company_id = current_user.company_id
    response_messages = []
    file = params[:file]
    item_data = SmarterCSV.process(file.tempfile)
    item_data.each_with_index do |single_item,index|
      remarks = []
      valid_data = true
      pay_item = PayItem.find_by(:name => single_item[:pay_item_name], :company_id => company_id)
      if pay_item.nil?
        valid_data = false
        remarks << "PayItem not found"
      end
      employee = Employee.find_by(:employee_code => single_item[:employee_code], :company_id => company_id)
      if employee.nil?
        valid_data = false
        remarks << "Employee not found"
      end
      if valid_data == true
        fixed_pay_item = FixedPayItem.find_by(:employee_id => employee.id, :pay_item_id => pay_item.id, :company_id => company_id)
        if fixed_pay_item.nil?
          fixed_pay_item = FixedPayItem.new
          fixed_pay_item.company_id   = company_id
          fixed_pay_item.employee_id  = employee.id
          fixed_pay_item.pay_item_id  = pay_item.id
          fixed_pay_item.item_amount  = single_item[:item_amount].to_f
          fixed_pay_item.item_type    = single_item[:item_type]
          fixed_pay_item.is_active    = true
          if single_item[:pay_month] == "-"
            fixed_pay_item.pay_month = nil
            fixed_pay_item.formated_pay_month = nil
          else
            fixed_pay_item.pay_month = single_item[:pay_month].to_date
            fixed_pay_item.formated_pay_month = single_item[:pay_month].to_date.strftime("%B %Y")
          end
          if fixed_pay_item.save
            remarks << "Fixed Pay Item saved"
          else
            remarks << fixed_pay_item.errors.full_messages.join(',')
          end
        else
          if fixed_pay_item.is_active == false
            fixed_pay_item = FixedPayItem.new
            fixed_pay_item.company_id   = company_id
            fixed_pay_item.employee_id  = employee.id
            fixed_pay_item.pay_item_id  = pay_item.id
            fixed_pay_item.item_amount  = single_item[:item_amount].to_f
            fixed_pay_item.item_type    = single_item[:item_type]
            fixed_pay_item.is_active    = true
            if single_item[:pay_month] == "-"
              fixed_pay_item.pay_month = nil
              fixed_pay_item.formated_pay_month = nil
            else
              fixed_pay_item.pay_month = single_item[:pay_month].to_date
              fixed_pay_item.formated_pay_month = single_item[:pay_month].to_date.strftime("%B %Y")
            end
            if fixed_pay_item.save
              remarks << "Exiting Employee Updated"
            else
              remarks << fixed_pay_item.errors.full_messages.join(',')
            end
          else
            fixed_pay_item = FixedPayItem.new
            fixed_pay_item.company_id   = company_id
            fixed_pay_item.employee_id  = employee.id
            fixed_pay_item.pay_item_id  = pay_item.id
            fixed_pay_item.item_amount  = single_item[:item_amount].to_f
            fixed_pay_item.item_type    = single_item[:item_type]
            fixed_pay_item.is_active    = true
            if single_item[:pay_month] == "-"
              fixed_pay_item.pay_month = nil
              fixed_pay_item.formated_pay_month = nil
            else
              fixed_pay_item.pay_month = single_item[:pay_month].to_date
              fixed_pay_item.formated_pay_month = single_item[:pay_month].to_date.strftime("%B %Y")
            end
            if fixed_pay_item.save
              remarks << "Fixed Pay Item saved"
            else
              remarks << fixed_pay_item.errors.full_messages.join(',')
            end
          end
        end
      end
      temp_obj = {
        employee_code: single_item[:employee_code],
        remarks: remarks.join(',')
      }
      response_messages << temp_obj
    end
    render json:{:response_messages => response_messages}, status: 200
  end

	private

	def fixed_pay_item_params
		params.permit(:company_id, :employee_id, :pay_item_id, :item_amount, :is_active, :item_type, :description)
	end

  def set_fixed_pay_item
    @fixed_pay_item = FixedPayItem.find(params[:id])
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
