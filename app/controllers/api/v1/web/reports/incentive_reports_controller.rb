class Api::V1::Web::Reports::IncentiveReportsController < ApplicationController

	def sale_incentive_report
		@show_salary 		= User.show_salary(current_user)
		incentive_month  = params[:selected_month].to_date
		@sale_incentives = EmployeeSaleIncentive.where(:company_id => params[:company_id], :location_id => params[:location_id], :branch_id => params[:branch_id], :incentive_date => incentive_month).order('employee_code ASC')
		branch = Branch.find(params[:branch_id])
		#################### Hierarchical Permission ####################
		if current_user.is_admin == true
			@sale_incentives = EmployeeSaleIncentive.where(:company_id => params[:company_id], :location_id => params[:location_id], :branch_id => params[:branch_id], :incentive_date => incentive_month).order('employee_code ASC')
		elsif current_user.is_company_head == true
			@sale_incentives = EmployeeSaleIncentive.where(:company_id => params[:company_id], :location_id => params[:location_id], :branch_id => params[:branch_id], :incentive_date => incentive_month).order('employee_code ASC')
		elsif current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id).order('id DESC')
	    @employees = Employee.multiple_branch_data(@employees, current_user)
      @sale_incentives = EmployeeSaleIncentive.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id).order('id DESC')
      @employees = Employee.multiple_branch_data(@employees, current_user)
      @sale_incentives = EmployeeSaleIncentive.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id).order('id DESC')
      @employees = Employee.multiple_branch_data(@employees, current_user)
      @sale_incentives = EmployeeSaleIncentive.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id).order('id DESC')
      @employees = Employee.multiple_branch_data(@employees, current_user)
      @sale_incentives = EmployeeSaleIncentive.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id).order('id DESC')
      @employees = Employee.multiple_branch_data(@employees, current_user)
      @sale_incentives = EmployeeSaleIncentive.where(:employee_id => @employees.collect(&:id).uniq)
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
	      sub_ordinates_ids = []
	      employee_ids = []
	      employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
	      employee_ids = employee_ids.flatten.uniq
	      employee_ids << current_user.employee.id
	      @employees = Employee.where(:id => employee_ids.uniq).order('id DESC')
	      @employees = Employee.multiple_branch_data(@employees, current_user)
	      @sale_incentives = EmployeeSaleIncentive.where(:employee_id => @employees.collect(&:id).uniq)
	    elsif current_user.multi_branch_allowed == true
		  	@employees = Employee.multiple_branch_data([], current_user)
	    	@sale_incentives = EmployeeSaleIncentive.where(:employee_id => @employees.collect(&:id).uniq)
		  end
		elsif current_user.multi_branch_allowed == true
			@employees = Employee.multiple_branch_data([], current_user)
	    @sale_incentives = EmployeeSaleIncentive.where(:employee_id => @employees.collect(&:id).uniq)
    end
    #################### Hierarchical Permission ####################

		sale_entry = SaleEntry.find_by(:company_id => params[:company_id], :location_id => params[:location_id], :branch_id => params[:branch_id], :sale_month => incentive_month)
		incentive_policy = IncentivePolicy.find_by(:company_id => params[:company_id], :is_active => true)
		if sale_entry.nil?
			incentive_percentage 				= 0
			total_incentive 						= 0
			sale_value 									= 0
			target_value								= 0
			target_achieved							= 0
			loss_value 									= 0
			profit_value 								= 0
			incentive_percentage_value 	= 0
		else
			if incentive_policy.nil?
				sale_value 									= sale_entry.sale_value.to_f
				target_value 								= sale_entry.target_value.to_f
				target_achieved							= 0
				loss_value 									= sale_entry.loss_value.to_f
				profit_value 								= sale_entry.profit_value.to_f
				incentive_percentage 				= 1
				incentive_percentage_value 	= ((sale_value * incentive_percentage).to_f/100.0).round
				total_incentive 						= (incentive_percentage_value.to_f - loss_value.to_f).round
				total_incentive 						= (total_incentive.to_f + profit_value.to_f).round
			else
				sale_value 									= sale_entry.sale_value.to_f
				target_value 								= sale_entry.target_value.to_f
				if target_value > 0
					percentage  							= (sale_entry.sale_value.to_f/sale_entry.target_value.to_f) * 100
					target_achieved 					= percentage
					incentive_percentage 			= incentive_policy.incentive_slabs.where("min_target_sale_percentage <= ? AND max_target_sale_percentage >= ?", percentage, percentage).sum(&:sale_incentive_percentage)
				else
					incentive_percentage 			= 1
					target_achieved 					= 0
				end
				loss_value 									= sale_entry.loss_value.to_f
				profit_value 								= sale_entry.profit_value.to_f
				incentive_percentage_value 	= ((sale_value * incentive_percentage).to_f/100.0).round
				total_incentive 						= (incentive_percentage_value.to_f - loss_value.to_f).round
				total_incentive 						= (total_incentive.to_f + profit_value.to_f).round
			end
		end
		if params[:report_type].to_i == 1
    	render status:200, template: 'api/v1/web/reports/incentive_reports/sale_incentive_report.json.jbuilder'
    elsif params[:report_type].to_i == 3

    	time = Time.now
			check_directory("#{Rails.public_path}/excel")
			book = Axlsx::Package.new
    	book.workbook.add_worksheet(:name => "Incentive Report") do |sheet|

	      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
	      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
	      date_style = sheet.styles.add_style(:sz=>11,:format_code=>"mmmm dd, yyyy")

	      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style    
	      sheet.add_row ['']
	      sheet.add_row ['']
	      sheet.add_row ['']
	      sheet.add_row ['']

	      cell_style_with_border = sheet.styles.add_style(:sz => 10, :border => Axlsx::STYLE_THIN_BORDER, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma')
	      cell_style_with_border_bottom = sheet.styles.add_style(:sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :border => {:style => :thin, :color => "000000",:edges => [:bottom]})
	      cell_style_bold = sheet.styles.add_style(:sz => 10, :b => true, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma')
	      cell_style_bold_with_border = sheet.styles.add_style(:sz => 10, :alignment => { :horizontal => :center }, b: true, :border=> {:style => :thin, :color => "000000"}, :font_name => 'Tahoma')
	      col_style = sheet.styles.add_style :format_code => '###,##', :num_fmt => 3, :sz => 10, :alignment => { :horizontal=> :center, :wrap_text => true }, :font_name => 'Tahoma'
	      col_style_with_bold = sheet.styles.add_style :format_code => '###,##', :num_fmt => 3, :sz => 10, :alignment => { :horizontal=> :center, :wrap_text => true }, :font_name => 'Tahoma'
	      normal_col_style = sheet.styles.add_style :format_code => '###,##', :num_fmt => 3, :sz => 10, :alignment => { :horizontal=> :center, :wrap_text => true }, :font_name => 'Tahoma'
	      normal_col_style_big = sheet.styles.add_style :format_code => '###,##', :num_fmt => 3, :sz => 12, :alignment => { :horizontal=> :center, :wrap_text => true }, :font_name => 'Tahoma'
	      sheet.column_widths nil,nil,nil,30,50,30,30,nil,nil,nil,nil,nil,30,30,30

				count = 0
				rows_count = 10
				branch_ids = @sale_incentives.collect(&:branch_id).uniq

				Branch.where(:id => branch_ids).order('name ASC').each do |branch|
					sheet.add_row ['']
					sheet.add_row ['']

					sheet.add_row ['SR NO.'.upcase,'Emp. ID'.upcase, 'NAME'.upcase,'GRADE'.upcase,'Branch'.upcase, 'DESIGNATION'.upcase, 'MONTH DAYS'.upcase,'GROSS SALARY'.upcase, 'PER DAY SALARY '.upcase,'PRESENT DAY '.upcase,'PRESENT DAYS SALARY'.upcase,'PROPIONATE'.upcase,'60% Incentive (Old Method)'.upcase,'30% Incentive (Old Method)'.upcase,'10% Incentive (Old Method)'.upcase,'Total Incentive'.upcase,'INCENTIVE AMOUNT'.upcase],:style => header_style
					total_gross_salary = 0
					total_present_day_salary = 0
					total_proionate_ratio = 0
					incentive_sixty = 0
					incentive_thirty = 0
					incentive_ten = 0
					total_incentives = 0
					total_incentive_amount = 0
					incentive_sixty_percent = 0
					incentive_thirty_percent = 0
					incentive_ten_percent = 0
					distribution = 0
					@sale_incentives.where(:branch_id => branch.id).order('employee_id ASC').each do |sale_incentive|
						SaleEntry.where(:company_id => params[:company_id], :location_id => params[:location_id], :branch_id => branch.id, :sale_month => incentive_month).each do |incentive|
						employee = Employee.find(sale_incentive.employee_id)
						count += 1
						rows_count += 1
						current_row_value = []
						current_row_style = []
						current_row_type = []
						current_row_value << count
						current_row_style << cell_style
						current_row_type << :integer
						current_row_value << employee.employee_code.to_i
						current_row_style << cell_style
						current_row_type << :integer
						current_row_value << employee.full_name
						current_row_style << cell_style
						current_row_type << :string
						current_row_value << employee.grade_name
						current_row_style << cell_style
						current_row_type << :string
						current_row_value << employee.branch_name
						current_row_style << cell_style
						current_row_type << :string
						current_row_value << employee.designation_name
						current_row_style << cell_style
						current_row_type << :string
						current_row_value << sale_incentive.month_days.round(2)
						current_row_style << cell_style
						current_row_type << :float
						if @show_salary == true
							current_row_value << sale_incentive.gross_salary.round(2)
							current_row_style << cell_style
							current_row_type << :float
							current_row_value << sale_incentive.per_day_salary.round(2)
							current_row_style << cell_style
							current_row_type << :float
							current_row_value << sale_incentive.present_days.round(2)
							current_row_style << cell_style
							current_row_type << :float
							current_row_value << sale_incentive.present_day_salary.round(2)
							current_row_style << cell_style
							current_row_type << :float
							current_row_value << sale_incentive.propionate.round(2)
							current_row_style << cell_style
							current_row_type << :float
							current_row_value << sale_incentive.incentive_payable.round(2)
							current_row_style << cell_style
							current_row_type << :float
							if sale_incentive.incentive_thirty.nil?
								sale_incentive.incentive_thirty = 0.0
							end
							current_row_value << sale_incentive.incentive_thirty.round(2)
							current_row_style << cell_style
							current_row_type << :float
							if sale_incentive.incentive_ten.nil?
								sale_incentive.incentive_ten = 0.0
							end
							current_row_value << sale_incentive.incentive_ten.round(2)
							current_row_style << cell_style
							current_row_type << :float
							total_incentive = ( sale_incentive.incentive_payable.round(2) ) + ( sale_incentive.incentive_thirty.round(2) ) + ( sale_incentive.incentive_ten.round(2) )
							current_row_value << total_incentive
							current_row_style << cell_style
							current_row_type << :float
							current_row_value << sale_incentive.incentive_amount.round(2)
							current_row_style << cell_style
							current_row_type << :float

							total_gross_salary = total_gross_salary + sale_incentive.gross_salary.round(2)
							total_present_day_salary = total_present_day_salary + sale_incentive.present_day_salary.round(2)
							total_proionate_ratio = total_proionate_ratio + sale_incentive.propionate.round(2)
							incentive_sixty = incentive_sixty + sale_incentive.incentive_payable.round(2)
							incentive_thirty = incentive_thirty + sale_incentive.incentive_thirty.round(2)
							incentive_ten = incentive_ten + sale_incentive.incentive_ten.round(2)
							incentive_sixty_percent = ((incentive.incentive_payable.to_f * 60) / 100.0)
							incentive_thirty_percent = ((incentive.incentive_payable.to_f * 30) / 100.0)
							incentive_ten_percent = ((incentive.incentive_payable.to_f * 10) / 100.0)
							distribution = incentive_sixty_percent + incentive_thirty_percent + incentive_ten_percent

							total_incentives = total_incentives + total_incentive
							total_incentive_amount = total_incentive_amount + sale_incentive.incentive_amount.round(2)
						else
							current_row_value << "-"
							current_row_style << cell_style
							current_row_type << :string
							current_row_value << "-"
							current_row_style << cell_style
							current_row_type << :string
							current_row_value << "-"
							current_row_style << cell_style
							current_row_type << :string
							current_row_value << "-"
							current_row_style << cell_style
							current_row_type << :string
							current_row_value << "-"
							current_row_style << cell_style
							current_row_type << :string
							current_row_value << "-"
							current_row_style << cell_style
							current_row_type << :string
						end
						sheet.add_row current_row_value, :style => cell_style_with_border, :types => current_row_type
					end
						end
					sheet.add_row [nil,nil,nil,nil,'Total Value : '.upcase,nil,nil,total_gross_salary,nil,nil,total_present_day_salary,total_proionate_ratio,incentive_sixty,incentive_thirty,incentive_ten,total_incentives,total_incentive_amount],:style => cell_style_bold_with_border

					sheet.add_row
					sheet.add_row ['']
					sheet.add_row ['', '', '', 'Incentive 60%', incentive_sixty_percent.round(2)],																		:style => [cell_style, cell_style, cell_style, cell_style_bold_with_border, cell_style_bold_with_border],	:types => [:string, :string, :string, :string, :float]
					sheet.add_row ['', '', '', 'Incentive 30%', incentive_thirty_percent.round(2)],													:style => [cell_style, cell_style, cell_style, cell_style_bold_with_border, cell_style_bold_with_border],	:types => [:string, :string, :string, :string, :float]
					sheet.add_row ['', '', '', 'Incentive 10%', incentive_ten_percent.round(2)],												    :style => [cell_style, cell_style, cell_style, cell_style_bold_with_border, cell_style_bold_with_border],	:types => [:string, :string, :string, :string, :float]
					sheet.add_row ['', '', '', 'Net Disbursement', distribution.round(2) ],																:style => [cell_style, cell_style, cell_style, cell_style_bold_with_border, cell_style_bold_with_border],	:types => [:string, :string, :string, :string, :float]
				end
			end

			file_name = "sale_incentive_report"
			url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    end
	end

	private

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
