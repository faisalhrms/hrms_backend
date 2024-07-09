class Holiday < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :company_id }
	validates :code, :uniqueness => { scope: :company_id }

	####### Relation Ship #########
	belongs_to :company
	belongs_to :religion


	def self.calculate_holidays(start_date, end_date, employee)
		holiday_count = 0
		date_range = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
		date_range.each do |single_date|
			holidays = Holiday.where(:is_active => true, :specific_religion => false, :company_id => employee.company_id)
			holidays.each do |holiday|
        if single_date >= holiday.start_date.to_date and single_date <= holiday.end_date.to_date
          holiday_count = holiday_count + 1 if check_location_wise(holiday, employee)
        end
      end
		end
		if employee.religion_id
			date_range.each do |single_date|
				holidays = Holiday.where(:is_active => true, :specific_religion => true, :religion_id => employee.religion_id, :company_id => employee.company_id)
				holidays.each do |holiday|
	        if single_date >= holiday.start_date.to_date and single_date <= holiday.end_date.to_date
	          holiday_count = holiday_count + 1 if check_location_wise(holiday, employee)
	        end
	      end
			end
		end
		return holiday_count
	end

	def self.verify_public_holiday(employee_attendance, holiday_date)
		employee = employee_attendance.employee
		public_holiday = false
		holidays = Holiday.where(:is_active => true, :specific_religion => false)
		holidays.each do |holiday|
      if holiday_date >= holiday.start_date.to_date and holiday_date <= holiday.end_date.to_date
        public_holiday = check_location_wise(holiday, employee_attendance)
      end
    end

		if employee.religion_id.present?
			religion_holidays = Holiday.where(:is_active => true, :specific_religion => true, :religion_id => employee.religion_id)
			religion_holidays.each do |holiday|
        if holiday_date >= holiday.start_date.to_date and holiday_date <= holiday.end_date.to_date  and holiday.religion_id == employee.religion_id
					public_holiday = check_location_wise(holiday, employee_attendance)
				end
      end
		end
		public_holiday
	end

	def self.verify_public_holiday_for_overtime(employee_attendance, holiday_date, holiday_ids)
		employee = employee_attendance.employee
		public_holiday = false
		holidays = Holiday.where(:id => holiday_ids.split(',').map(&:to_i), :is_active => true, :specific_religion => false)
		holidays.each do |holiday|
			if holiday_date >= holiday.start_date.to_date and holiday_date <= holiday.end_date.to_date
				public_holiday = check_location_wise(holiday, employee_attendance)
			end
    end

		if employee.religion_id
			religion_holidays = Holiday.where(:id => holiday_ids.split(',').map(&:to_i), :is_active => true, :specific_religion => true, :religion_id => employee.religion_id)
			religion_holidays.each do |holiday|
        if holiday_date >= holiday.start_date.to_date and holiday_date <= holiday.end_date.to_date
					public_holiday = check_location_wise(holiday, employee_attendance)
				end
      end
		end
		public_holiday
	end

	def self.check_location_wise(holiday, employee_attendance)
		if holiday.location_wise
			if holiday.location_id == employee_attendance.location_id
				holiday.branch_ids.try(:split, ',').try(:map, &:to_i) and holiday.branch_ids.try(:split, ',').try(:map, &:to_i).include?(employee_attendance.branch_id)
			else
				false
			end
		else
			true
		end
	end
end
