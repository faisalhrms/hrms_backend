class AddLateExemptedInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, 					:late_exempted,			:boolean, :default => false
  end
end
