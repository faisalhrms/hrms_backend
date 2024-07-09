class AddFuelCompanyNameInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :fuel_company_name, :string
  end
end
