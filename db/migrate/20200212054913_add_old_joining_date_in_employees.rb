class AddOldJoiningDateInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :old_joining_date, :datetime
  end
end
