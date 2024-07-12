class Api::V1::Web::IncentiveManagement::SaleEntriesController < ApplicationController

	before_action :set_sale_entry, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @sale_entries = SaleEntry.all.order('id DESC')
    else
      @sale_entries = SaleEntry.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/incentive_management/sale_entries/index'
  end

  def filter_data
    @sale_entries = SaleEntry.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/incentive_management/sale_entries/index'
  end

  def create
    @sale_entry       = SaleEntry.new sale_entry_params
    @sale_entry.sale_month 					= params[:sale_month].to_date
		@sale_entry.formated_month 			= params[:sale_month].to_date.strftime("%m/%Y")
    if @sale_entry.save
      render json:{}, status: :created
    else
      render json: {errors: @sale_entry.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/incentive_management/sale_entries/show'
  end

  def update
  	@sale_entry.sale_month 					= params[:sale_month].to_date
		@sale_entry.formated_month 			= params[:sale_month].to_date.strftime("%m/%Y")
    if @sale_entry.update(sale_entry_params)
      render json: {}, status: 204
    else
      render json: {errors: @sale_entry.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def download_sample_csv_file
    time = Time.now
    file_name = "sample_import_#{time.to_i}.csv"
    save_path = "#{Rails.public_path}/excel/#{file_name}"
    CSV.open("#{save_path}", "wb") do |csv|
      csv << ["location", "branch", "sale_month","loss_value","incentive_payable"]
      csv << ["Retail Stores", "Satellite Town - RWP","December 2021","2300", "100000"]
      csv << ["Retail Stores", "Misaq Ul Mall - FSD","December 2021","2300", "100000"]
      csv << ["Retail Stores", "Gulshan KDA - KHI","December 2021","2300", "100000"]
      csv << ["Retail Stores", "Gulsitan E Johar - KHI","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "FOL - LHR","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Sahiwal","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Kareem Block - LHR","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Mirpur","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Saddar - RWP","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "NCA Wah","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Amanah Mall - LHR","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Galleria - FSD","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Avenue Mall - LHR","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Swat","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Peshawar","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Vm Team Ho","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Elan Office","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Mandi Bahauddin","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Abbottabad","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Lucky One - KHI","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Iqbal Town - LHR","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Multan","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Gujranwala","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Sialkot","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Hyderabad","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Sheikhupura","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Bahawalpur","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "WTC - RWP","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Packages - LHR","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Jaranwala - FSD","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Xinhua","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Gujrat","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Gulberg - LHR","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "DHA - LHR","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Emporium Mall - LHR","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Centaurus Mall - ISB","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Dolmen Mall Clifton - KHI","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Dolmen Mall Tariq Road - KHI","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Kehkashan - KHI","December 2021","2300" , "100000"]
      csv << ["Retail Stores", "Gulshan KDA - KHI","December 2021","2300" ,"100000"]
     end
    render json: {message: "CSV Created", path: "/excel/#{file_name}"}, status: 200
  end

  def bulk_import_sale
    response_messages = []
    valid_data = true
    file = params[:file]
      if file.present?
        sheet_data = SmarterCSV.process(file.tempfile)
        sheet_data.each_with_index do |data|
          remarks = []
          location = Location.find_by(:name => data[:location])
          if location.nil?
            valid_data = false
            remarks << "Location not found"
          end
          branch = Branch.find_by(:name => data[:branch])
          if branch.nil?
            valid_data = false
            remarks << "Branch not found"
          end
          if valid_data == true
              sale_entry = SaleEntry.new
              sale_entry.company_id = current_user.company_id
              sale_entry.location_id = location.id
              sale_entry.branch_id = branch.id
              sale_entry.sale_month = data[:sale_month].to_date.strftime("%B %Y")
              sale_entry.formated_month	= data[:sale_month].to_date.strftime("%m/%Y")
              sale_entry.name = data[:branch]
              sale_entry.loss_value = data[:loss_value]
              sale_entry.incentive_payable = data[:incentive_payable]
              sale_entry.save
            else
              valid_data = false
              remarks << "Sale Entry not found Check Your CSV File"
            end

          temp_obj = {
            branch_name: data[:branch],
            remarks: remarks.join(',')
          }
          response_messages << temp_obj
          end
        end
      render json:{:response_messages => response_messages}, status: 200
    end

  def incentive_sample_csv_file
    time = Time.now
    file_name = "sample_import_#{time.to_i}.csv"
    save_path = "#{Rails.public_path}/excel/#{file_name}"
    CSV.open("#{save_path}", "wb") do |csv|
      csv << ["employee_code","date","incentive_thirty","incentive_ten"]
      csv << ["4107","01 Nov 2021","955","500"]
      csv << ["3195","01 Nov 2021","955","500"]
      csv << ["881","01 Nov 2021","955","500"]


    end
      render json: {message: "CSV Created", path: "/excel/#{file_name}"}, status: 200
    end

  def bulk_import_employee_incentive
    response_messages = []
    valid_data = true
    file = params[:file]
    if file.present?
      sheet_data = SmarterCSV.process(file.tempfile)
      sheet_data.each_with_index do |data|
        remarks = []
        employee = Employee.find_by(:employee_code => data[:employee_code], :company_id => current_user.company_id)
        if employee.nil?
          valid_data = false
          remarks << "Employee not found"
        end
        if valid_data == true
          sale_entry = 		EmployeeSaleIncentive.where(:company_id => current_user.company_id,:employee_id => employee.id ,:incentive_date => data[:date].to_date.strftime("%d-%b-%Y"))
          sale_entry.update_all(:incentive_thirty => data[:incentive_thirty])
          sale_entry.update_all(:incentive_ten => data[:incentive_ten])
        else
          valid_data = false
          remarks << "Sale Entry not found Check Your CSV File"
        end

        temp_obj = {
          employee_code: data[:employee_code],
          remarks: remarks.join(',')
        }
        response_messages << temp_obj
      end
    end
    render json:{:response_messages => response_messages}, status: 200
  end



  def destroy
  	if @sale_entry.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @sale_entry.errors.full_messages}, status: :unprocessable_entity
  	end
  end

  def check_directory(dir_path)
    unless File.directory?(dir_path)
      Dir.mkdir(dir_path)
    end
  end


	private

	def sale_entry_params
		params.permit(:company_id, :location_id, :branch_id, :name, :sale_value,:incentive_payable, :profit_value, :loss_value, :target_value)
	end

  def set_sale_entry
    @sale_entry = SaleEntry.find(params[:id])
  end

end
