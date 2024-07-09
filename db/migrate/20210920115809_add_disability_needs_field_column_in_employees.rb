class AddDisabilityNeedsFieldColumnInEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :disability_needs, 	:string
  end
end
