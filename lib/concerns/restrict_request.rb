require 'active_support/concern'
module RestrictRequest
  extend ActiveSupport::Concern

  included do
    validate :restrict_back_dates
    scope :get_by_employee, -> (employee_id){where(employee_id: employee_id)}

    def restrict_back_dates
      allowed_days = RestrictLeave.allowed_leave_days
      if allowed_days and !RestrictLeave.admin.include?(User.current) and start_date.to_date < allowed_days.days.ago.to_date
        self.errors.add(:base, "You can only apply/cancel #{self.class.name.split(/(?=[A-Z])/).join(' ')} for last #{allowed_days} days.")
      end
    end
  end

  def add_impact_to_approval_request(current_user)
    approval_request = self.approval_request
    approval_request.approval_request_status  = 'Approved'
    approval_request.is_approved = true
    if approval_request.save
      method_name = self.class.name == OfficialDuty.name ? 'official_duty' : 'leave'
      approval_request.send("add_impact_in_#{method_name}_request", current_user)
      true
    else
      false
    end
  end
end
