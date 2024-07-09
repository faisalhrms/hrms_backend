class AddNationalityInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :nationality, :string
  end
end
