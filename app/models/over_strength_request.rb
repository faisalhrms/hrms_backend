class OverStrengthRequest < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:employee
	belongs_to 	:department

	########## Validation ############
  validate 		:validate_the_apply_date

  ########## Validation of Over Strength Application ##########
	def validate_the_apply_date
		applied_status = false
		if self.request_status == "Waiting For Approval"
			if self.id.present?
				OverStrengthRequest.where.not(id:self.id).where(employee_id: self.employee_id, is_cancelled: false, request_status: ["Waiting For Approval", "Availed", "System Deducted"]).each do |single_request|
					if self.id != single_request.id
						if single_request.start_date.present? and single_request.end_date.present?
							if (single_request.start_date <= self.start_date and single_request.end_date >= self.start_date) or (single_request.end_date >= self.end_date and single_request.start_date <= self.end_date)
								applied_status = true
								self.errors.add(:base, "Over Strength Request Already Applied! from #{single_request.start_date.to_date.strftime("%d-%b-%Y")} to #{single_request.end_date.to_date.strftime("%d-%b-%Y")}")
							end
						end
					end
				end
			else
				OverStrengthRequest.where(employee_id: self.employee_id, is_cancelled: false, request_status: ["Waiting For Approval", "Availed", "System Deducted"]).each do |single_request|
					if self.id != single_request.id
						if single_request.start_date.present? and single_request.end_date.present?
							if (single_request.start_date <= self.start_date and single_request.end_date >= self.start_date) or (single_request.end_date >= self.end_date and single_request.start_date <= self.end_date)
								applied_status = true
								self.errors.add(:base, "Over Strength Request Already Applied! from #{single_request.start_date.to_date.strftime("%d-%b-%Y")} to #{single_request.end_date.to_date.strftime("%d-%b-%Y")}")
							end
						end
					end
				end
			end
		end
		logger.info "#{self.errors}"
	end

	########## Calculation of Over Strength that requested to Applied ##########
	def self.verify_over_strength_request(employee, start_date, end_date)
		message = "No issue in Over Strength Request. You are allowed to apply Over Strength Request."
		date_range = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
		request_count = date_range.count
		return request_count, message
	end

	def department_name
		if self.department.nil?
  		return "-"
  	else
  		return self.department.name
  	end
	end

	def employee_name
		if self.employee.nil?
			return "-"
		else
			self.employee.full_name
		end
	end

	def employee_code
		if self.employee.nil?
			return "-"
		else
			self.employee.employee_code
		end
	end

end
