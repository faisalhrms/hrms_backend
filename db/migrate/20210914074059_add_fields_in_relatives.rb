class AddFieldsInRelatives < ActiveRecord::Migration[7.1]
  def change
    add_column :employee_relatives, :martial_status, 	:string
    add_column :employee_relatives, :deceased,      	:boolean ,default: false
    add_column :employee_relatives, :covid_vaccination, :boolean ,default: false

  end
end
