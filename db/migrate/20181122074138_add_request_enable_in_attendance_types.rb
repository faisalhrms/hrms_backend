class AddRequestEnableInAttendanceTypes < ActiveRecord::Migration[7.1]
  def change
  	add_column :attendance_types, :request_enable, :boolean, :default => false
  end
end
