class LeaveTransactionHistory < ApplicationRecord

	####### Relation Ship #########

	belongs_to :company
	belongs_to :employee
	belongs_to :leave_type
	belongs_to :leave_request
	belongs_to :leave_allocation

	####### Leave Transaction Entry #########
	def self.create_leave_transaction(company_id, employee_id, leave_type_id, leave_request_id, allocated_quota, remaining_quota, used_quota, quota_transaction, transaction_type, remarks, leave_year_start_date, leave_year_end_date, leave_allocation_id)
		leave_transaction = LeaveTransactionHistory.new
		leave_transaction.company_id 							= company_id
		leave_transaction.employee_id 						= employee_id
		leave_transaction.leave_type_id 					= leave_type_id
		leave_transaction.leave_request_id 				= leave_request_id
		leave_transaction.leave_allocation_id 		= leave_allocation_id
		leave_transaction.allocated_quota 				= allocated_quota
		leave_transaction.remaining_quota 				= remaining_quota
		leave_transaction.used_quota 							= used_quota
		leave_transaction.quota_transaction 			= quota_transaction
		leave_transaction.transaction_type 				= transaction_type
		leave_transaction.remarks 								= remarks
		leave_transaction.transaction_date 				= Time.now.to_date
		leave_transaction.leave_year_start_date 	= leave_year_start_date
		leave_transaction.leave_year_end_date 		= leave_year_end_date
		leave_transaction.save
	end

	def self.leave_availed_quota(leave_histories, leave_allocations, start_date, end_date)
		availed = leave_histories.where(:transaction_type => "Deduction").sum(:quota_transaction) - leave_histories.where(:transaction_type => "Reversion").sum(:quota_transaction)
		leave_histories = LeaveTransactionHistory.includes(:leave_request).where(:leave_allocation_id => leave_allocations.collect(&:id)).where('leave_requests.start_date >= ? AND leave_requests.start_date <= ? AND leave_requests.end_date > ?', start_date, end_date, end_date).references(:leave_request)
		if leave_histories.empty?
			leave_histories = LeaveTransactionHistory.includes(:leave_request).where(:leave_allocation_id => leave_allocations.collect(&:id)).where('leave_requests.start_date < ? AND leave_requests.end_date >= ? AND leave_requests.end_date <= ?', start_date, start_date, end_date).references(:leave_request)
			unless leave_histories.empty?
				total_quota = leave_histories.where(:transaction_type => "Deduction").sum(:quota_transaction) - leave_histories.where(:transaction_type => "Reversion").sum(:quota_transaction)
				leave_histories.each do |history|
					total_leave_requests = history.leave_request.request_count
					date_range = (start_date.to_date..history.leave_request.end_date.to_date).to_a.map{|x| x.to_date}
					per_day_quota = (total_quota) / total_leave_requests
					month_days = EmployeeAttendance.where(:employee_id => history.employee_id, :attendance_date => date_range, is_rest_day: false, is_public_holiday: false).count
					availed += (per_day_quota * month_days)
				end
			end
		else
			total_quota = leave_histories.where(:transaction_type => "Deduction").sum(:quota_transaction) - leave_histories.where(:transaction_type => "Reversion").sum(:quota_transaction)
			leave_histories.each do |history|
				total_leave_requests = history.leave_request.request_count
				date_range = (history.leave_request.start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
				per_day_quota = (total_quota) / total_leave_requests
				month_days = EmployeeAttendance.where(:employee_id => history.employee_id, :attendance_date => date_range, is_rest_day: false, is_public_holiday: false).count
				availed += (per_day_quota * month_days)
			end
		end
		availed
	end

	def leave_type_name
		if self.leave_type.nil?
			return "-"
		else
			self.leave_type.name
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
