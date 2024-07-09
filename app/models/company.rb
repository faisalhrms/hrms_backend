class Company < ApplicationRecord
	########## Validation ############
	validates :name, :uniqueness => true
	validates :code, :uniqueness => true

	has_attached_file :avatar,
										:url => "#{ENV['APP_URL']}/system/:class/:attachment/:id/:style/:filename",
										:path => ":rails_root/public/system/:class/:attachment/:id/:style/:filename",
										:default_url => "#{ENV['APP_URL']}/system/no_image.png"

	validates_attachment_content_type :avatar, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif" ]

	####### Relation Ship #########
	has_many		:users, 													:dependent => :restrict_with_error
	has_many		:roles, 													:dependent => :restrict_with_error
	has_many		:designations, 										:dependent => :restrict_with_error
	has_many		:locations, 											:dependent => :restrict_with_error
	has_many		:branches, 												:dependent => :restrict_with_error
	has_many		:departments, 										:dependent => :restrict_with_error
	has_many		:job_titles, 											:dependent => :restrict_with_error
	has_many		:grades, 													:dependent => :restrict_with_error
	has_many		:email_templates, 								:dependent => :restrict_with_error
	has_many		:email_configrations, 						:dependent => :restrict_with_error
	has_many		:email_outbounds, 								:dependent => :restrict_with_error
	has_many		:holidays, 												:dependent => :restrict_with_error
	has_many		:documents, 											:dependent => :restrict_with_error
	has_many		:employees, 											:dependent => :restrict_with_error
	has_many		:internees, 											:dependent => :restrict_with_error
	has_many		:temporary_staffs, 								:dependent => :restrict_with_error
	has_many		:leave_types, 										:dependent => :restrict_with_error
	has_many		:leave_years, 										:dependent => :restrict_with_error
	has_many		:leave_allocations, 							:dependent => :restrict_with_error
	has_many		:request_flows, 									:dependent => :restrict_with_error
	has_many		:leave_requests, 									:dependent => :restrict_with_error
	has_many		:approval_requests, 							:dependent => :restrict_with_error
	has_many		:leave_transaction_histories, 		:dependent => :restrict_with_error
	has_many		:system_settings, 								:dependent => :restrict_with_error
	has_many		:time_slots, 											:dependent => :restrict_with_error
	has_many    :employee_rosters,    						:dependent => :restrict_with_error
	has_many    :attendance_types,    						:dependent => :restrict_with_error
	has_many    :attendance_exceptions,    				:dependent => :restrict_with_error
	has_many    :attendance_cutoffs,    					:dependent => :restrict_with_error
	has_many    :attendance_deductions,    				:dependent => :restrict_with_error
	has_many    :attendance_earnings,    					:dependent => :restrict_with_error
	has_many    :attendance_relaxations,    			:dependent => :restrict_with_error
	has_many    :attendance_overtimes,    				:dependent => :restrict_with_error
	has_many    :early_lefts,    									:dependent => :restrict_with_error
	has_many    :missing_punches,    							:dependent => :restrict_with_error
	has_many    :absent_policies,    							:dependent => :restrict_with_error
	has_many    :attendance_structures,    				:dependent => :restrict_with_error
	has_many    :attendance_devices,    					:dependent => :restrict_with_error
	has_many    :sale_entries,    								:dependent => :restrict_with_error
	has_many    :employee_sale_incentives,    		:dependent => :restrict_with_error
	has_many    :tax_slabs,    										:dependent => :restrict_with_error
	has_many    :piece_slabs,    										:dependent => :restrict_with_error
	has_many    :fiscal_years,    								:dependent => :restrict_with_error
	has_many    :eobis,    												:dependent => :restrict_with_error
	has_many    :pay_items,    										:dependent => :restrict_with_error
	has_many    :fixed_pay_items,    							:dependent => :restrict_with_error
	has_many 		:pay_executions,   								:dependent => :restrict_with_error
	has_many 		:benefit_structures,   						:dependent => :restrict_with_error
	has_many 		:incentive_policies,   						:dependent => :restrict_with_error
	has_many 		:employee_loans,   								:dependent => :restrict_with_error
	has_many 		:employee_advances,   						:dependent => :restrict_with_error
	has_many 		:employee_tax_credits,   					:dependent => :restrict_with_error
	has_many 		:employee_taxable_incomes,   			:dependent => :restrict_with_error
	has_many 		:department_allocations,   				:dependent => :restrict_with_error
	has_many 		:sms_configrations,   						:dependent => :restrict_with_error
	has_many 		:sms_templates,   								:dependent => :restrict_with_error
	has_many 		:sms_executions,   								:dependent => :restrict_with_error
	has_many 		:email_executions,   							:dependent => :restrict_with_error
	has_many 		:grade_allocations,   						:dependent => :restrict_with_error
	has_many 		:temp_staff_attendances,   				:dependent => :restrict_with_error
end
