class AddQuotaEarnedInAttendances < ActiveRecord::Migration[7.1]
  def change
  	add_column 		:employee_attendances, :quota_earned, :boolean, :default => false
  end
end
