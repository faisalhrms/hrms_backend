class AddIsFlexiInTimeSlots < ActiveRecord::Migration[7.1]
  def change
  	add_column :time_slots, :is_flexi, :boolean, :default => false
  end
end
