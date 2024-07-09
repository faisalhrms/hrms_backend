class RestrictLeave < ApplicationRecord
  belongs_to :user
  validates_uniqueness_of :is_active
  validate :notification_day_validation

  class << self
    def allowed_leave_days
      RestrictLeave.find_by_is_active(true).try(:leave_days)
    end

    def allowed_approval_days
      RestrictLeave.find_by_is_active(true).try(:approval_days)
    end

    def admin
      user_ids = RestrictLeave.find_by_is_active(true).try(:user_ids).parameterize.split('-')
      User.where(id: user_ids)
    end

    def notification_day
      RestrictLeave.find_by_is_active(true).try(:notification)
    end
  end

  def notification_day_validation
    if notification.to_i >= approval_days.to_i
      self.errors.add(:base, 'Notification day should not be greater than approval days')
    end
  end
end
