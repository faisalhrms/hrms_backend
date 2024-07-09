class EmployeeSaleIncentive < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:location
	belongs_to 	:branch
	belongs_to 	:employee

	def company_name
  	if self.company.nil?
  		return "-"
  	else
  		return self.company.name
  	end
  end

  def location_name
  	if self.location.nil?
  		return "-"
  	else
  		return self.location.name
  	end
  end

	def branch_name
		if self.branch.nil?
  		return "-"
  	else
  		return self.branch.name
  	end
	end

	def self.process_sale_incentive(employee_attendances, start_date, end_date, incentive_month, company_id, location_id, branch_id)
		Branch.where(id: branch_id).each do |branch|
		employee_ids = employee_attendances.where(:branch_id => branch.id).collect(&:employee_id).uniq
		total_present_day_salary = 0
		employee_ids.each do |employee_id|
			employee = Employee.find(employee_id)
			if employee.incentive_allowed == true
				gross_salary = employee.gross_salary
				sale_incentive = EmployeeSaleIncentive.find_by(:employee_id => employee.id, :company_id => company_id, :location_id => location_id, :branch_id => branch.id, :incentive_date => incentive_month)
				if sale_incentive.nil?
					sale_incentive = EmployeeSaleIncentive.new
				end
				present_days = employee_attendances.where(:employee_id => employee.id, :incentive_verified => true).count
				
				sale_incentive.company_id 		= company_id
				sale_incentive.location_id 		= location_id
				sale_incentive.branch_id 			= branch.id
				sale_incentive.employee_id 		= employee.id
				sale_incentive.employee_code 	= employee.employee_code
				sale_incentive.employee_name 	= employee.full_name

				month_days = 0.0
				if (incentive_month.present? and (not incentive_month.nil?))
					month_days = Time.days_in_month(incentive_month.month,incentive_month.year) 
				end
				sale_incentive.incentive_date = incentive_month
				sale_incentive.month_days 		= month_days
				sale_incentive.present_days 	= present_days
				sale_incentive.gross_salary 	= gross_salary
				sale_incentive.per_day_salary = 
				sale_incentive.per_day_salary = (sale_incentive.gross_salary.to_f)/(sale_incentive.month_days)
				sale_incentive.present_day_salary = (sale_incentive.per_day_salary * sale_incentive.present_days);
				total_present_day_salary = total_present_day_salary + sale_incentive.present_day_salary
				sale_incentive.save
			end
		end

		sale_entry = SaleEntry.find_by(:company_id => company_id, :location_id => location_id, :branch_id => branch.id, :sale_month => incentive_month)
		incentive_policy = IncentivePolicy.find_by(:company_id => company_id, :is_active => true)
		if sale_entry.nil?
			incentive_percentage 	= 0
			total_incentive 			= 0
			sale_value 						= 0
			target_value					= 0
			loss_value 						= 0
			profit_value 					= 0
		else
			if incentive_policy.nil?
				sale_value 						= sale_entry.sale_value.to_f
				target_value 					= sale_entry.target_value.to_f
				loss_value 						= sale_entry.loss_value.to_f
				profit_value 					= sale_entry.profit_value.to_f
				incentive_percentage 	= 1
				total_incentive 			= ((sale_value * incentive_percentage).to_f/100.0).round
				total_incentive 			= (total_incentive.to_f - loss_value.to_f).round
				total_incentive 			= (total_incentive.to_f + profit_value.to_f).round
			else
				sale_value 						= sale_entry.sale_value.to_f
				target_value 					= sale_entry.target_value.to_f
				if target_value > 0
					percentage  					= (sale_entry.sale_value.to_f/sale_entry.target_value.to_f) * 100
					incentive_percentage 	= incentive_policy.incentive_slabs.where("min_target_sale_percentage <= ? AND max_target_sale_percentage >= ?", percentage, percentage).sum(&:sale_incentive_percentage)
				else
					incentive_percentage 	= 1
				end
				loss_value 						= sale_entry.loss_value.to_f
				profit_value 					= sale_entry.profit_value.to_f
				total_incentive 			= ((sale_value * incentive_percentage).to_f/100.0).round
				total_incentive 			= (total_incentive.to_f - loss_value.to_f).round
				total_incentive 			= (total_incentive.to_f + profit_value.to_f).round
			end
		end

		EmployeeSaleIncentive.where(:company_id => company_id, :location_id => location_id, :branch_id => branch.id, :incentive_date => incentive_month).each do |sale_incentive|
			# sale = SaleEntry.find_by(:company_id => company_id, :location_id => location_id, :branch_id => branch_id, :sale_month => incentive_month)
			sale_incentive.propionate 						= ((sale_incentive.present_day_salary.to_f / total_present_day_salary.to_f) * 100.0).to_f
			sale_incentive.incentive_amount 			= ((sale_incentive.propionate.to_f * total_incentive.to_f).to_f / 100.0).to_f.round(2)

			incentiv = ((sale_entry.incentive_payable * 60) / 100.0)
			sale_incentive.incentive_payable 			= ((incentiv * sale_incentive.propionate.to_f).to_f / 100.0).to_f.round(2)

			sale_incentive.sale_value 						= sale_value
			sale_incentive.target_value 					= target_value
			sale_incentive.loss_value 						= loss_value
			sale_incentive.profit_value 					= profit_value
			sale_incentive.total_incentive 				= total_incentive
			sale_incentive.incentive_percentage 	= incentive_percentage
			sale_incentive.save
		end			
	end
	end
	end
