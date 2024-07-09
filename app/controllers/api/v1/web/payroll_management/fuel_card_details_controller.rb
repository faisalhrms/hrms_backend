class Api::V1::Web::PayrollManagement::FuelCardDetailsController < ApplicationController

	before_filter :set_fuel_card_detail, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @fuel_card_details = FuelCardDetail.all.order('id DESC')
    else
      @fuel_card_details = FuelCardDetail.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/payroll_management/fuel_card_details/index.json.jbuilder'
  end

  def filter_data
    @fuel_card_details = FuelCardDetail.where(:company_id => params[:company_id]).order('id DESC')
    render status:200, template: 'api/v1/web/payroll_management/fuel_card_details/index.json.jbuilder'
  end

  def create
    @fuel_card_detail       = FuelCardDetail.new fuel_card_detail_params
    if @fuel_card_detail.save
      render json:{}, status: :created
    else
      render json: {errors: @fuel_card_detail.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/payroll_management/fuel_card_details/show.json.jbuilder'
  end

  def update
    if @fuel_card_detail.update(fuel_card_detail_params)
      render json: {}, status: 204
    else
      render json: {errors: @fuel_card_detail.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @fuel_card_detail.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @fuel_card_detail.errors.full_messages}, status: :unprocessable_entity
  	end
  end

  def download_sample_csv_file
    time = Time.now
    file_name = "sample_import_#{time.to_i}.csv"
    save_path = "#{Rails.public_path}/excel/#{file_name}"
    CSV.open("#{save_path}", "wb") do |csv|
    	
      csv << ["employee_code", "card_no", "card_name", "registration", "fleet_division", "quantity_consumed", "amount_consumed", "last_km", "consumption"]
      csv << ["42282", "42282", "Mutta Shahid", "LEH-19-5003", "0", "90", "1032447", "0", "100"]
      csv << ["42282", "42282", "Mutta Shahid", "LEH-19-5003", "0", "90", "1032447", "600", "100"]
      csv << ["42282", "42282", "Mutta Shahid", "LEH-19-5003", "0", "90", "1032447", "0", "100"]
      csv << ["42282", "42282", "Mutta Shahid", "LEH-19-5003", "0", "90", "1032447", "5000", "0"]
    end
    render json: {message: "CSV Created", path: "/excel/#{file_name}"}, status: 200
  end

  def bulk_import
  	company_id = current_user.company_id
    response_messages = []
    file = params[:file]
    item_data = SmarterCSV.process(file.tempfile)
    item_data.each_with_index do |single_item,index|
      remarks = []
      valid_data = true
      employee = Employee.find_by(:employee_code => single_item[:employee_code], :company_id => company_id)
      if employee.nil?
        valid_data = false
        remarks << "Employee not found"
      end
      if valid_data == true
        fuel_card_detail = FuelCardDetail.find_by(:employee_id => employee.id, :card_no => single_item[:card_no], :company_id => company_id)
        if fuel_card_detail.nil?
          fuel_card_detail = FuelCardDetail.new
          fuel_card_detail.employee_id  			= employee.id
          fuel_card_detail.company_id   			= company_id
          fuel_card_detail.card_no 						= single_item[:card_no]
          fuel_card_detail.card_name 					= single_item[:card_name]
          fuel_card_detail.registration 			= single_item[:registration]
          fuel_card_detail.fleet_division 		= single_item[:fleet_division]
          fuel_card_detail.quantity_consumed 	= single_item[:quantity_consumed]
          fuel_card_detail.amount_consumed 		= single_item[:amount_consumed]
          fuel_card_detail.last_km 						= single_item[:last_km]
          fuel_card_detail.consumption 				= single_item[:consumption]
          if fuel_card_detail.save
            remarks << "Fuel Card saved"
          else
            remarks << fuel_card_detail.errors.full_messages.join(',')
          end
        else
        	remarks << "Fuel Card Already Exist"
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

	def fuel_card_detail_params
		params.permit(:employee_id, :company_id, :card_no, :card_name, :registration, :fleet_division, :quantity_consumed, :amount_consumed, :last_km, :consumption)
	end

  def set_fuel_card_detail
    @fuel_card_detail = FuelCardDetail.find(params[:id])
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
