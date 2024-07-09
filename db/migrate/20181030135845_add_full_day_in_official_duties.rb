class AddFullDayInOfficialDuties < ActiveRecord::Migration[7.1]
  def change
  	add_column :official_duties, :is_full_day, :boolean, :default => false
  end
end
