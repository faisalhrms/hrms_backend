class AddConfirmationDateInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :confirmation_date, :datetime
  end
end
