class AddSubTimeSlotIdInEmployeeAttendances < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_attendances, :sub_time_slot_id, :integer
  end
end
