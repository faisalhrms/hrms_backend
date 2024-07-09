class AddTotolWorkingHoursInTimeSlots < ActiveRecord::Migration[7.1]
  def change
  	add_column :time_slots, :total_working_minutes, :float, :default => 0.0
  end
end
