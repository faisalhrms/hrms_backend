class LeaveAllocation < ApplicationRecord

	###############################
	####### Relation Ship #########
	###############################
	belongs_to 	:company
	belongs_to 	:location
	belongs_to 	:employee
	belongs_to 	:leave_type
	belongs_to 	:leave_year
	has_many		:leave_transaction_histories, :dependent => :destroy
	###############################
	####### Relation Ship #########
	###############################

	########## Validation ############
	validate 	 :presence_of_leave_year

	scope :get_by_company, -> (company_id){where(company_id: company_id)}
	scope :active, -> {where(is_active: true)}

	########## Checking Presence of Leave Year ##########
	def presence_of_leave_year
		########## Check Presence of Already Leave allocated or not ##########
		verify_leave_type_presence = false
		if LeaveAllocation.where(:company_id => self.company_id, :location_id => self.location_id, :is_active => true, :leave_type_id => self.leave_type_id, :employee_id => self.employee_id).count > 0
			verify_leave_type_presence = true
		end
		if verify_leave_type_presence == true
			self.errors.add(:base, "Leave Type already assoicated with employee can't assoicate it again. if you want to assoicate it again de-allocate the old one")
		else
			########## Leave Year Verification ##########
			leave_years = LeaveYear.where(:company_id => self.company_id, :is_active => true)
			if leave_years.count == 0
				self.errors.add(:base, "Leave Year is Missing")
			elsif leave_years.count > 1
				self.errors.add(:base, "Active Leave Year more than 1")
			else
				if leave_years.count == 1
					leave_year = leave_years.first
					########## Leave Year Date Range Verification ##########
					if leave_year.start_date <= Time.now.to_date and leave_year.end_date >= Time.now.to_date
						self.allocate_leave_quota
					else
						self.errors.add(:base, "Leave Year Start and End Date is not related to current year")		
					end
				else
					self.errors.add(:base, "Active Leave Year more than 1")	
				end
			end
		end
	end

	########## Allocation of Leave Quota ##########
	def allocate_leave_quota
		########## Leave Year ##########
		leave_years = LeaveYear.where(:company_id => self.company_id, :is_active => true)
		########## Leave Type ##########
		leave_type = LeaveType.find(self.leave_type_id)
		########## Employee ##########
		employee = Employee.find(self.employee_id)
		gender_allowed = false
		if leave_type.gender == "All"
			gender_allowed = true
		elsif leave_type.gender == employee.gender
			gender_allowed = true
		end
		########## Leave Type Active ##########
		grade_condition = true
		if leave_type.grade_ids.try(:split, ',').try(:map, &:to_i)
			grade_condition = leave_type.grade_ids.try(:split, ',').try(:map, &:to_i).include? employee.grade_id
		end
		if leave_type.is_active and grade_condition
			########## Gender Validation ##########
			if gender_allowed
				########## Leave Year Count ##########
				if leave_years.count == 1
					########## Leave Type Presence ##########
					if not leave_type.nil?
						########## Current Leave Year ##########
						leave_year 						= leave_years.first
						joining_date 					= employee.joining_date
						confirmation_date 		= employee.confirmation_date
						leave_year_start_date = leave_year.start_date
						leave_year_end_date		= leave_year.end_date
						########## Verification Employee Joining Date with Current Active Leave Year ##########
						if joining_date.to_date < leave_year_start_date.to_date
							joining_date = leave_year_start_date
						end
						########## Skipped Joining Month ##########
						joining_next_month_date 		= (employee.joining_date + 1.month).beginning_of_month
						if joining_next_month_date.to_date < leave_year_start_date.to_date
							joining_next_month_date = leave_year_start_date
						end
						joining_till_allocation_month = Time.now.to_date.end_of_month.day
						joining_till_allocation_month = (TimeDifference.between(joining_next_month_date,Time.now.end_of_month.to_date).in_months).round
						if joining_till_allocation_month > 12
							joining_till_allocation_month = 12
						end
						########## No of Days from Employee Joining, Leave Calender Year ##########
						skipped_leave_year_days 		= TimeDifference.between(joining_next_month_date.to_date,leave_year_end_date.to_date).in_days + 1
						leave_year_days 						= TimeDifference.between(leave_year_start_date.to_date,leave_year_end_date.to_date).in_days + 1
						leave_year_month 						= TimeDifference.between(leave_year_start_date.to_date,leave_year_end_date.to_date).in_months.round
						employee_current_year_days 	= TimeDifference.between(joining_date.to_date,leave_year_end_date.to_date).in_days + 1
						employee_current_year_month = TimeDifference.between(joining_date.to_date,leave_year_end_date.to_date).in_months
						current_month_days 					= Time.now.to_date.end_of_month.day
						employee_current_month_days = TimeDifference.between(joining_date.to_date,Time.now.end_of_month.to_date).in_days + 1
						if employee_current_month_days > current_month_days
							employee_current_month_days = current_month_days
						end
						tenure_quota = leave_type.accumulative_count
						########## Allocate Back Date Quota to Employee ##########
						if leave_type.backdate_quota == true && LeaveAllocation.where(:company_id => self.company_id, :employee_id => employee.id, :leave_type_id => leave_type.id).count == 0
							employee_current_year_days 	= TimeDifference.between(employee.joining_date.to_date,leave_year_end_date.to_date).in_days + 1
							employee_current_year_month = TimeDifference.between(employee.joining_date.to_date,leave_year_end_date.to_date).in_months
						end
						########## Special Leave ##########
						special_leave_verification_allowed = true
						if leave_type.special_leave
							special_leave_verification_allowed = speical_leave_verification(leave_type, employee)
						end
						########## Special Leave ##########
						if special_leave_verification_allowed
							########## Leave Eligiblility ##########
							if leave_type.eligible == "DOJ"
								no_of_days_in_company						= TimeDifference.between(joining_date.to_date,Time.now.to_date).in_days + 1
								actual_of_days_in_company				= TimeDifference.between(employee.joining_date.to_date,Time.now.to_date).in_days + 1
								actual_of_months_in_company			= TimeDifference.between(employee.joining_date.to_date,Time.now.to_date).in_months.round
								calculation_value = leave_type.verify_experience_type(actual_of_days_in_company, actual_of_months_in_company)
								########## Verfiy Employee Expereince ##########
								if calculation_value >= leave_type.min_experience_to_availed_leave
									########## Leave Prorated ##########
									if leave_type.pro_rated
										########## Leave Tenure ##########
										if leave_type.tenure == "Annually"
											leave_year_days = TimeDifference.between(leave_year_start_date.to_date,leave_year_end_date.to_date).in_days + 1
											prorated_quota 	= (tenure_quota/leave_year_days.to_f)*employee_current_year_days.to_f
											self.allocate_quota_to_employee(prorated_quota, self.leave_type_id, self.employee_id, leave_year.id)
										elsif ['Monthly', '3 Month', '6 Month'].include? (leave_type.tenure)
											multiply_factor = leave_type.tenure.split(' ').first.to_f > 0 ? leave_type.tenure.split(' ').first.to_f : 1.0
											prorated_quota = (tenure_quota/leave_year_month.to_f)*multiply_factor
											prorated_quota = (prorated_quota.to_f/current_month_days.to_f)*employee_current_month_days.to_f
											self.allocate_quota_to_employee(prorated_quota, self.leave_type_id, self.employee_id, leave_year.id)
										end
									else
										if leave_type.tenure == "Annually"
											prorated_quota = tenure_quota
											self.allocate_quota_to_employee(prorated_quota, self.leave_type_id, self.employee_id, leave_year.id)
										elsif ['Monthly', '3 Month', '6 Month'].include? (leave_type.tenure)
											multiply_factor = leave_type.tenure.split(' ').first.to_f > 0 ? leave_type.tenure.split(' ').first.to_f : 1.0
											prorated_quota = (tenure_quota/leave_year_month.to_f) * multiply_factor
											self.allocate_quota_to_employee(prorated_quota, self.leave_type_id, self.employee_id, leave_year.id)
										end
									end
								else
									self.errors.add(:base, "Employee have less experience than Leave Type. Employee Experience (in #{leave_type.experience_type}): #{no_of_days_in_company}, No of Experience required in Policy (in #{leave_type.experience_type}): #{leave_type.min_experience_to_availed_leave}")
								end	
							elsif leave_type.eligible == "DOC"
								########## Employee Probation Verification ##########
								if employee.on_probation == false
									########## Employee Confirmation Date Presence ##########
									if not confirmation_date.nil?
										if leave_type.backdate_quota == true && LeaveAllocation.where(:company_id => self.company_id, :employee_id => employee.id, :leave_type_id => leave_type.id).count == 0
											employee_current_year_days 	= TimeDifference.between(employee.joining_date.to_date,leave_year_end_date.to_date).in_days + 1
											employee_current_year_month = TimeDifference.between(employee.joining_date.to_date,leave_year_end_date.to_date).in_months
										else
											employee_current_year_days 	= TimeDifference.between(confirmation_date.to_date,leave_year_end_date.to_date).in_days + 1
											employee_current_year_month = TimeDifference.between(confirmation_date.to_date,leave_year_end_date.to_date).in_months	
										end
										no_of_days_in_company					= TimeDifference.between(confirmation_date.to_date,Time.now.to_date).in_days + 1
										no_of_month_in_company				= TimeDifference.between(confirmation_date.to_date,Time.now.to_date).in_months.round
										calculation_value = leave_type.verify_experience_type(no_of_days_in_company, no_of_month_in_company)
										########## Verfiy Employee Expereince ##########
										if calculation_value >= leave_type.min_experience_to_availed_leave
											########## Leave Prorated ##########
											if leave_type.pro_rated
												########## Leave Tenure ##########
												if leave_type.tenure == "Annually"
													if leave_type.skipped_joining_month == false
														if leave_type.backdate_quota == true && LeaveAllocation.where(:company_id => self.company_id, :employee_id => employee.id, :leave_type_id => leave_type.id).count == 0
															prorated_quota = (tenure_quota/leave_year_days.to_f)*employee_current_year_days.to_f
															self.allocate_quota_to_employee(prorated_quota, self.leave_type_id, self.employee_id, leave_year.id)
														else
															if employee_current_year_days > leave_year_days
																prorated_quota = (tenure_quota/leave_year_days.to_f)*leave_year_days.to_f
																self.allocate_quota_to_employee(prorated_quota, self.leave_type_id, self.employee_id, leave_year.id)	
															else
																prorated_quota = (tenure_quota/leave_year_days.to_f)*employee_current_year_days.to_f
																self.allocate_quota_to_employee(prorated_quota, self.leave_type_id, self.employee_id, leave_year.id)	
															end
														end
													else
														prorated_quota = (tenure_quota/skipped_leave_year_days.to_f)*employee_current_year_days.to_f
														self.allocate_quota_to_employee(prorated_quota, self.leave_type_id, self.employee_id, leave_year.id)
													end
												elsif ['Monthly', '3 Month', '6 Month'].include? (leave_type.tenure)
													multiply_factor = leave_type.tenure.split(' ').first.to_f > 0 ? leave_type.tenure.split(' ').first.to_f : 1.0
													if leave_type.skipped_joining_month == false
														if leave_type.backdate_quota == true && LeaveAllocation.where(:company_id => self.company_id, :employee_id => employee.id, :leave_type_id => leave_type.id).count == 0
															prorated_quota = (tenure_quota/leave_year_month.to_f)*multiply_factor
															total_days_till_confirmation = TimeDifference.between(employee.joining_date.to_date,Time.now.end_of_month.to_date).in_days + 1
															prorated_quota = (prorated_quota.to_f/current_month_days.to_f)*total_days_till_confirmation.to_f
														else
															prorated_quota = (tenure_quota/leave_year_month.to_f)*multiply_factor
															prorated_quota = (prorated_quota.to_f/current_month_days.to_f)*employee_current_month_days.to_f
														end
														self.allocate_quota_to_employee(prorated_quota, self.leave_type_id, self.employee_id, leave_year.id)
													else
														prorated_quota = (tenure_quota/leave_year_month.to_f)*multiply_factor
														prorated_quota = (prorated_quota.to_f*joining_till_allocation_month.to_f)
														self.allocate_quota_to_employee(prorated_quota, self.leave_type_id, self.employee_id, leave_year.id)
													end
												end
											else
												########## Leave Tenure ##########
												if leave_type.tenure == "Annually"
													prorated_quota = tenure_quota
													self.allocate_quota_to_employee(prorated_quota, self.leave_type_id, self.employee_id, leave_year.id)
												elsif ['Monthly', '3 Month', '6 Month'].include? (leave_type.tenure)
													multiply_factor = leave_type.tenure.split(' ').first.to_f > 0 ? leave_type.tenure.split(' ').first.to_f : 1.0
													prorated_quota = (tenure_quota/leave_year_month.to_f)*multiply_factor
													self.allocate_quota_to_employee(prorated_quota, self.leave_type_id, self.employee_id, leave_year.id)
												end
											end
										else
											self.errors.add(:base, "Employee have less experience than Leave Type. Employee Experience (in #{leave_type.experience_type}): #{no_of_days_in_company}, No of Experience required in Policy (in #{leave_type.experience_type}): #{leave_type.min_experience_to_availed_leave}")
										end	
									else
										self.errors.add(:base, "Employee Confirmation Date is missing")
									end
								else
									self.errors.add(:base, "Leave Quota not allocated beacuse leave Type eligibility is on Confrimation and Employee is on Probation")
								end
							end
						else
							self.errors.add(:base, "As per policy you are not eligibile to availed this #{leave_type.name}")		
						end
					end
				else
					self.errors.add(:base, "Active Leave Year more than 1")
				end
			else
				self.errors.add(:base, "Employee and Leave Type Gender not matches")
			end
		else
			if leave_type.is_active
				self.errors.add(:base, "Employee grade is not in leave type.")
			else
				self.errors.add(:base, "Leave Type is not active")
			end
		end
	end

	########## Allocation of Leave to Employee ##########
	def allocate_quota_to_employee(quota, leave_type_id, employee_id, leave_year_id)
		employee 		= Employee.find(employee_id)
		leave_type 	= LeaveType.find(leave_type_id)
		leave_year 	= LeaveYear.find(leave_year_id)
		self.allocated_quota 										= quota.round(2).to_f
		self.remaining_quota 										= quota.round(2).to_f
		self.leave_year_id											= leave_year_id
		self.leave_year_start_date 							= leave_year.start_date
		self.leave_year_end_date								= leave_year.end_date
		self.is_active 													= true
		####### Leave Transaction Entry #########
		LeaveTransactionHistory.create_leave_transaction(employee.company_id, employee.id, leave_type.id, nil, self.allocated_quota, self.remaining_quota, self.used_quota, self.remaining_quota, "Earned", "Leave Earned", self.leave_year_start_date, self.leave_year_end_date, self.id)
	end

	########## Deducted Leave Quota ##########
	def self.deducted_leave_qouta(allocated_leave, deducted_quota, employee, leave_type, leave_request, remarks)
		allocated_leave.remaining_quota = allocated_leave.remaining_quota - deducted_quota
		allocated_leave.used_quota 			= allocated_leave.used_quota + deducted_quota
		allocated_leave.save(:validate => false)
		LeaveTransactionHistory.create_leave_transaction(employee.company_id, employee.id, leave_type.id, leave_request.id, allocated_leave.allocated_quota, allocated_leave.remaining_quota, allocated_leave.used_quota, deducted_quota, "Deduction", remarks, allocated_leave.leave_year_start_date, allocated_leave.leave_year_end_date, allocated_leave.id)
	end

	########## Revert Leave Quota ##########
	def self.revert_leave_qouta(allocated_leave, deducted_quota, employee, leave_type, leave_request, remarks)
		allocated_leave.remaining_quota = allocated_leave.remaining_quota + deducted_quota
		allocated_leave.used_quota 			= allocated_leave.used_quota - deducted_quota
		allocated_leave.save(:validate => false)
		####### Leave Transaction Entry #########
		LeaveTransactionHistory.create_leave_transaction(employee.company_id, employee.id, leave_type.id, leave_request.id, allocated_leave.allocated_quota, allocated_leave.remaining_quota, allocated_leave.used_quota, deducted_quota, "Reversion", remarks, allocated_leave.leave_year_start_date, allocated_leave.leave_year_end_date, allocated_leave.id)
	end

	########## Special Leave Verification ##########
	def speical_leave_verification(leave_type, employee)
		special_leave = false
		if leave_type.special_leave
			leave_allocations = LeaveAllocation.where(:company_id => self.company_id, :location_id => self.location_id, :leave_type_id => self.leave_type_id, :employee_id => self.employee_id)
			if leave_allocations.count > 0
				leave_requests = LeaveRequest.where(:company_id => self.company_id, :leave_type_id => self.leave_type_id, :employee_id => self.employee_id)
				leave_allocation = leave_allocations.last
				remaining_quota = leave_allocation.remaining_quota
				if remaining_quota.to_f == 0
					if leave_requests.count > 0
						leave_request = leave_requests.last
						no_of_years_days = leave_type.special_leave_allocation_year
						leave_eligibily_days = TimeDifference.between(leave_request.start_date.to_date,Time.now.to_date).in_days + 1
						if leave_eligibily_days >= no_of_years_days
							special_leave = true
						end
					end
				end
			else
				special_leave = true
			end
		else
			special_leave = false
		end
		special_leave
	end

	#############################################################################
	#############################################################################
	#############################################################################
	#############################################################################
	################## Monthly Leave Allocation Process Start ###################
	#############################################################################
	#############################################################################
	#############################################################################
	#############################################################################

	# LeaveAllocation.manual_monthly_leave_allocation_process
	def self.manual_monthly_leave_allocation_process
		current_time = Time.now
		if current_time.to_date.month != 1
			########## Leave Year ##########
			LeaveYear.where(:is_active => true).each do |leave_year|
				########## Leave Year Date Range Verification ##########
				if leave_year.start_date <= current_time.to_date and leave_year.end_date >= current_time.to_date
					LeaveType.where(:company_id => leave_year.company_id, :is_active => true, :auto_allocation => true, :tenure => ['Monthly', '3 Month', '6 Month'], :is_composite => false, :special_leave => false, :earned_quota => false, :is_leave_without_pay => false).each do |leave_type|
						LeaveAllocation.where(:company_id => leave_year.company_id, :location_id => leave_type.location_id, :is_active => true, :leave_type_id => leave_type.id).includes(:employee).each do |leave_allocation|
							grade_condition = true
							if leave_type.grade_ids.try(:split, ',').try(:map, &:to_i)
								grade_condition = leave_type.grade_ids.try(:split, ',').try(:map, &:to_i).include? leave_allocation.employee.try(:grade_id)
							end
							leave_allocation.add_leave_in_employee_leave_balance(leave_year, leave_type) if grade_condition
						end
					end
				end
			end
		end
	end

	def add_leave_in_employee_leave_balance(leave_year, leave_type)
		current_time = Time.now
		employee = Employee.find(self.employee_id)
		prev_trans_histories = LeaveTransactionHistory.where("date_part('YEAR', transaction_date) = ?", current_time.to_date.year).where(:transaction_type => ["Earned", 'Manual Adjustement'], :company_id => employee.company_id, :employee_id => employee.id, :leave_type_id => leave_type.id, :leave_allocation_id => self.id)
		if prev_trans_histories.count > 0
			leave_end_date = case(leave_type.tenure)
											 when 'Monthly'
												 1.month
											 when '3 Month'
												 3.month
											 when '6 Month'
												 6.month
											 when 'Annually'
												 1.year
											 end
			prev_trans_histories = prev_trans_histories.where(transaction_date: Time.now.beginning_of_month..(prev_trans_histories.last.created_at + leave_end_date).to_date)
		end
		grade_condition = true
		if leave_type.grade_ids.try(:split, ',').try(:map, &:to_i)
			grade_condition = leave_type.grade_ids.try(:split, ',').try(:map, &:to_i).include? employee.grade_id
		end
		if prev_trans_histories.count == 0 and grade_condition
			joining_date 					= employee.joining_date
			confirmation_date 		= employee.confirmation_date
			leave_year_start_date = leave_year.start_date
			leave_year_end_date		= leave_year.end_date
			########## Verification Employee Joining Date with Current Active Leave Year ##########
			if joining_date.to_date < leave_year_start_date.to_date
				joining_date = leave_year_start_date
			end
			########## No of Days from Employee Joining, Leave Calender Year ##########
			leave_year_days 						= TimeDifference.between(leave_year_start_date.to_date,leave_year_end_date.to_date).in_days + 1
			employee_current_year_days 	= TimeDifference.between(joining_date.to_date,leave_year_end_date.to_date).in_days + 1
			employee_current_year_month = TimeDifference.between(joining_date.to_date,leave_year_end_date.to_date).in_months
			tenure_quota = leave_type.accumulative_count
			########## Allocate Back Date Quota to Employee ##########
			if leave_type.backdate_quota == true && LeaveAllocation.where(:company_id => self.company_id, :employee_id => employee.id, :leave_type_id => leave_type.id).count == 0
				employee_current_year_days 	= TimeDifference.between(employee.joining_date.to_date,leave_year_end_date.to_date).in_days + 1
				employee_current_year_month = TimeDifference.between(employee.joining_date.to_date,leave_year_end_date.to_date).in_months
			end
			if leave_type.eligible == "DOJ"
				no_of_days_in_company						= TimeDifference.between(joining_date.to_date,Time.now.to_date).in_days + 1
				actual_of_days_in_company				= TimeDifference.between(employee.joining_date.to_date,Time.now.to_date).in_days + 1
				actual_of_months_in_company			= TimeDifference.between(employee.joining_date.to_date,Time.now.to_date).in_months.round
				calculation_value = leave_type.verify_experience_type(actual_of_days_in_company, actual_of_months_in_company)
				########## Verfiy Employee Expereince ##########
				if calculation_value >= leave_type.min_experience_to_availed_leave
					########## Leave Prorated ##########
					if leave_type.pro_rated
						########## Leave Tenure ##########
						if leave_type.tenure == "Annually"
							prorated_quota = (tenure_quota/leave_year_days.to_f)*employee_current_year_days.to_f
							self.add_earned_quota_to_employee(prorated_quota, self.leave_type_id, self.employee_id, leave_year.id)
						elsif ['Monthly', '3 Month', '6 Month'].include? (leave_type.tenure)
							multiply_factor = leave_type.tenure.split(' ').first.to_f > 0 ? leave_type.tenure.split(' ').first.to_f : 1.0
							prorated_quota = (tenure_quota/leave_year_days.to_f)*employee_current_year_days.to_f
							prorated_quota = (prorated_quota.to_f/employee_current_year_month.to_f) * multiply_factor
							self.add_earned_quota_to_employee(prorated_quota, self.leave_type_id, self.employee_id, leave_year.id)
						end
					else
						if leave_type.tenure == "Annually"
							prorated_quota = tenure_quota
							self.add_earned_quota_to_employee(prorated_quota, self.leave_type_id, self.employee_id, leave_year.id)
						elsif ['Monthly', '3 Month', '6 Month'].include? (leave_type.tenure)
							multiply_factor = leave_type.tenure.split(' ').first.to_f > 0 ? leave_type.tenure.split(' ').first.to_f : 1.0
							prorated_quota = (tenure_quota/employee_current_year_days.to_f) * multiply_factor
							self.add_earned_quota_to_employee(prorated_quota, self.leave_type_id, self.employee_id, leave_year.id)
						end
					end
				end
			elsif leave_type.eligible == "DOC"
				########## Employee Probation Verification ##########
				if employee.on_probation == false
					########## Employee Confirmation Date Presence ##########
					if not confirmation_date.nil?
						employee_current_year_days 	= TimeDifference.between(confirmation_date.to_date,leave_year_end_date.to_date).in_days + 1
						employee_current_year_month = TimeDifference.between(confirmation_date.to_date,leave_year_end_date.to_date).in_months
						no_of_days_in_company				= TimeDifference.between(confirmation_date.to_date,Time.now.to_date).in_days + 1
						no_of_month_in_company			= TimeDifference.between(confirmation_date.to_date,Time.now.to_date).in_months.round
						calculation_value = leave_type.verify_experience_type(no_of_days_in_company, no_of_month_in_company)
						########## Verfiy Employee Expereince ##########
						if calculation_value >= leave_type.min_experience_to_availed_leave
							########## Leave Prorated ##########
							if leave_type.pro_rated
								########## Leave Tenure ##########
								if leave_type.tenure == "Annually"
									prorated_quota = (tenure_quota/leave_year_days.to_f)*employee_current_year_days.to_f
									self.add_earned_quota_to_employee(prorated_quota, self.leave_type_id, self.employee_id, leave_year.id)
								elsif ['Monthly', '3 Month', '6 Month'].include? (leave_type.tenure)
									multiply_factor = leave_type.tenure.split(' ').first.to_f > 0 ? leave_type.tenure.split(' ').first.to_f : 1.0
									prorated_quota = (tenure_quota/leave_year_days.to_f)*employee_current_year_days.to_f
									prorated_quota = (prorated_quota.to_f/employee_current_year_month.to_f) * multiply_factor
									self.add_earned_quota_to_employee(prorated_quota, self.leave_type_id, self.employee_id, leave_year.id)
								end
							else
								########## Leave Tenure ##########
								if leave_type.tenure == "Annually"
									prorated_quota = tenure_quota
									self.add_earned_quota_to_employee(prorated_quota, self.leave_type_id, self.employee_id, leave_year.id)
								elsif ['Monthly', '3 Month', '6 Month'].include? (leave_type.tenure)
									multiply_factor = leave_type.tenure.split(' ').first.to_f > 0 ? leave_type.tenure.split(' ').first.to_f : 1.0
									prorated_quota = (tenure_quota/employee_current_year_days.to_f) * multiply_factor
									self.add_earned_quota_to_employee(prorated_quota, self.leave_type_id, self.employee_id, leave_year.id)
								end
							end
						end
					end
				end
			end
		end
	end

	def add_earned_quota_to_employee(quota, leave_type_id, employee_id, leave_year_id, remarks = 'Leave Earned')
		employee 		= Employee.find(employee_id)
		leave_type 	= LeaveType.find(leave_type_id)
		quota = quota.round(2)
		if leave_type.earned_quota
			if self.remaining_quota.to_f < leave_type.earned_quota_max_limit.to_f
				quota_verification = self.remaining_quota + quota
				if quota_verification < leave_type.earned_quota_max_limit.to_f
					self.allocated_quota = self.allocated_quota + quota
					self.remaining_quota = self.remaining_quota + quota
					LeaveTransactionHistory.create_leave_transaction(employee.company_id, employee.id, leave_type.id, nil, self.allocated_quota, self.remaining_quota, self.used_quota, quota, "Earned", remarks, self.leave_year_start_date, self.leave_year_end_date, self.id)
					self.save(:validate => false)
				else
					quota_needed_to_be_added 	= (leave_type.earned_quota_max_limit.to_f - self.remaining_quota.to_f).round(2)
					self.allocated_quota 			= self.allocated_quota + quota_needed_to_be_added.round(2)
					self.remaining_quota 			= self.remaining_quota + quota_needed_to_be_added.round(2)
					LeaveTransactionHistory.create_leave_transaction(employee.company_id, employee.id, leave_type.id, nil, self.allocated_quota, self.remaining_quota, self.used_quota, quota_needed_to_be_added.round(2), "Earned", remarks, self.leave_year_start_date, self.leave_year_end_date, self.id)
					self.save(:validate => false)
				end
			end
		else
			self.allocated_quota = self.allocated_quota.to_f + quota
			self.remaining_quota = self.remaining_quota.to_f + quota
			LeaveTransactionHistory.create_leave_transaction(employee.company_id, employee.id, leave_type.id, nil, self.allocated_quota, self.remaining_quota, self.used_quota, quota, "Earned", remarks, self.leave_year_start_date, self.leave_year_end_date, self.id)
			self.save(:validate => false)
		end
	end

	def add_carry_quota_to_employee(quota, leave_type_id, employee_id, leave_year_id, remarks = 'Leave Earned')
		employee 		= Employee.find(employee_id)
		leave_type 	= LeaveType.find(leave_type_id)
		quota = quota.round(2)
		if self.remaining_quota.to_f < leave_type.carry_forward_max_limit.to_f
			quota_verification = self.remaining_quota + quota
			if quota_verification < leave_type.carry_forward_max_limit.to_f
				self.allocated_quota = self.allocated_quota + quota
				self.remaining_quota = self.remaining_quota + quota
				LeaveTransactionHistory.create_leave_transaction(employee.company_id, employee.id, leave_type.id, nil, self.allocated_quota, self.remaining_quota, self.used_quota, quota, "Earned", remarks, self.leave_year_start_date, self.leave_year_end_date, self.id)
				self.save(:validate => false)
			else
				quota_needed_to_be_added 	= (leave_type.carry_forward_max_limit.to_f - self.remaining_quota.to_f).round(2)
				self.allocated_quota 			= self.allocated_quota + quota_needed_to_be_added.round(2)
				self.remaining_quota 			= self.remaining_quota + quota_needed_to_be_added.round(2)
				LeaveTransactionHistory.create_leave_transaction(employee.company_id, employee.id, leave_type.id, nil, self.allocated_quota, self.remaining_quota, self.used_quota, quota_needed_to_be_added.round(2), "Earned", remarks, self.leave_year_start_date, self.leave_year_end_date, self.id)
				self.save(:validate => false)
			end
		end
	end

	#############################################################################
	#############################################################################
	#############################################################################
	#############################################################################
	################### Monthly Leave Allocation Process End ####################
	#############################################################################
	#############################################################################
	#############################################################################
	#############################################################################

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

	def leave_type_name
    leave_type.try(:name) || '-'
	end

	def company_name
    company.try(:name) || '-'
	end

	def location_name
		if self.location.nil?
  		return "-"
  	else
  		return self.location.name
  	end
	end

	def branch_name
		if self.employee.nil?
  		return "-"
  	else
  		return self.employee.branch_name
  	end
	end

	def department_name
		if self.employee.nil?
  		return "-"
  	else
  		return self.employee.department_name
  	end
	end

	def job_title_name
		if self.employee.nil?
  		return "-"
  	else
  		return self.employee.job_title_name
  	end
	end
		
	def grade_name
		if self.employee.nil?
  		return "-"
  	else
  		return self.employee.grade_name
  	end
	end
		
  def designation_name
  	if self.employee.nil?
  		return "-"
  	else
  		return self.employee.designation_name
  	end
  end

  def leave_year_name
  	if self.leave_year.nil?
  		return "-"
  	else
  		return self.leave_year.name
  	end
  end

	def self.location_related_leave_allocation(leave_allocation_list, location_id)
		leave_allocations = leave_allocation_list.where(:location_id => location_id)
		return leave_allocations
	end

	def self.leave_type_related_leave_allocation(leave_allocation_list, leave_type_id)
		leave_allocations = leave_allocation_list.where(:leave_type_id => leave_type_id)
		return leave_allocations
	end

	def self.encashable_quota(employee)
		total_encashable_quota = 0
  	LeaveType.where(:encashment => true, :is_active => true).each do |leave_type|
			grade_condition = true
			if leave_type.grade_ids.try(:split, ',').try(:map, &:to_i)
				grade_condition = leave_type.grade_ids.try(:split, ',').try(:map, &:to_i).include? employee.grade_id
			end
			total_encashable_quota = LeaveAllocation.single_encashment_quota(employee, leave_type) if grade_condition
    end
		total_encashable_quota
	end

	#############################################################################
	#############################################################################
	#############################################################################
	#############################################################################
	################### Annual Leave Allocation Process Start ###################
	#############################################################################
	#############################################################################
	#############################################################################
	#############################################################################
	
	# LeaveAllocation.head_office_annual_leave_allocation
	def self.head_office_annual_leave_allocation
		Employee.where(:company_id => 1, :is_active => true).each do |employee|
			if not employee.joining_date.nil?
				day_difference = TimeDifference.between(employee.joining_date.to_date, Time.now.to_date).in_days
				leave_type = LeaveType.find_by(:name => "Annual Leave", :location_id => employee.location_id, :tenure => "Annually")
				if not leave_type.nil?
					if day_difference == 365
						leave_allocation = LeaveAllocation.new
						leave_allocation.company_id = employee.company_id
						leave_allocation.employee_id = employee.id
						leave_allocation.leave_type_id = leave_type.id
						leave_allocation.location_id = employee.location_id
						if leave_allocation.save
						  leave_transaction = LeaveTransactionHistory.find_by(:employee_id => leave_allocation.employee_id, :leave_type_id => leave_allocation.leave_type_id, :leave_allocation_id => nil)
						  leave_transaction.leave_allocation_id = leave_allocation.id
						  leave_transaction.save
						end
					end
				end
			end
		end
	end

	#############################################################################
	#############################################################################
	#############################################################################
	#############################################################################
	#################### Annual Leave Allocation Process End ####################
	#############################################################################
	#############################################################################
	#############################################################################
	#############################################################################

	def self.single_encashment_quota(employee, leave_type)
		total_encashable_quota = 0
  	remaining_quota = LeaveAllocation.where(:employee_id => employee.id, :leave_type_id => leave_type.id, :is_active => true).sum(&:remaining_quota)
  	if remaining_quota > 0
  		if remaining_quota >= leave_type.encashment_min_limit and remaining_quota <= leave_type.encashment_max_limit
  			total_encashable_quota = remaining_quota
  		elsif remaining_quota >= leave_type.encashment_max_limit
  			total_encashable_quota = leave_type.encashment_max_limit
  		elsif remaining_quota >= leave_type.encashment_min_limit
  			total_encashable_quota = leave_type.encashment_min_limit
  		end
  	end
  	return total_encashable_quota
	end

	def self.encashable_quota_non_probation(employee)
		total_encashable_quota = 0
		if employee.on_probation == false
			if employee.employee_type_name != "Contractual"
				LeaveType.where(:encashment => true, :is_active => true).each do |leave_type|
					grade_condition = true
					if leave_type.grade_ids.try(:split, ',').try(:map, &:to_i)
						grade_condition = leave_type.grade_ids.try(:split, ',').try(:map, &:to_i).include? employee.grade_id
					end
					total_encashable_quota = total_encashable_quota + LeaveAllocation.single_encashment_quota_non_probation(employee, leave_type) if grade_condition
		    end
			end
		end
		total_encashable_quota
	end

	def self.single_encashment_quota_non_probation(employee, leave_type)
		total_encashable_quota = LeaveAllocation.where(:employee_id => employee.id, :leave_type_id => leave_type.id, :is_active => true).where.not(remaining_quota: nil).sum(&:remaining_quota)
  	return total_encashable_quota
	end

	def composite_allocated_quota
		merge_leave_type_ids = self.leave_type.composite_leave_types.where(:status => "Allowed").collect(&:merge_leave_type_id)
		allocated_quota = LeaveAllocation.where(:employee_id => self.employee_id, :leave_type_id => merge_leave_type_ids, :is_active => true).sum(:allocated_quota)
		return allocated_quota
	end

	def composite_used_quota
		merge_leave_type_ids = self.leave_type.composite_leave_types.where(:status => "Allowed").collect(&:merge_leave_type_id)
		used_quota = LeaveAllocation.where(:employee_id => self.employee_id, :leave_type_id => merge_leave_type_ids, :is_active => true).sum(:used_quota)
		return used_quota
	end
		
	def composite_remaining_quota
		merge_leave_type_ids = self.leave_type.composite_leave_types.where(:status => "Allowed").collect(&:merge_leave_type_id)
		remaining_quota = LeaveAllocation.where(:employee_id => self.employee_id, :leave_type_id => merge_leave_type_ids, :is_active => true).sum(:remaining_quota)
		return remaining_quota
	end

	def composite_in_process_quota
		merge_leave_type_ids = self.leave_type.composite_leave_types.where(:status => "Allowed").collect(&:merge_leave_type_id)
		return LeaveRequest.where(employee_id: self.employee_id, is_cancelled: false, request_status: "Waiting For Approval", :leave_type_id => merge_leave_type_ids).sum(:request_count)
	end

	def in_process_quota
		return LeaveRequest.where(employee_id: self.employee_id, is_cancelled: false, request_status: "Waiting For Approval", :leave_type_id => self.leave_type_id).sum(:request_count)
	end

end
