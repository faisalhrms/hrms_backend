class AddTimeSlotIdInEmployeeAttendances < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_attendances, :time_slot_id, :integer
  end
end
