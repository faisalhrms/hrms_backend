class AddCnicExpiryDateInEmployeeProfile < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :cnic_expiry_date, :datetime
  end
end
