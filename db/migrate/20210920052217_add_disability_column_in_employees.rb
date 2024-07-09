class AddDisabilityColumnInEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :disability, 	:boolean ,default: false
  end
end
