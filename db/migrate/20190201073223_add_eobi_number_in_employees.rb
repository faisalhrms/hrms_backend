class AddEobiNumberInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :eobi_number, :string, :default => ""
  end
end
