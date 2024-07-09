class AddPassportLicenceColumnInEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :passport_number, 	:string
    add_column :employees, :passport_expiry, 	:datetime
    add_column :employees, :license_number, 	:string
    add_column :employees, :license_expiry, 	:datetime
  end
end
