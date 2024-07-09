class AddSortOrderInAttendanceTypes < ActiveRecord::Migration[7.1]
  def change
  	add_column :attendance_types, :sort_order, :integer, :default => 0
  end
end
