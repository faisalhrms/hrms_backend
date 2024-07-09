class AddFieldsInExperiences < ActiveRecord::Migration[7.1]
  def change
    add_column :employee_experiences, :department, 	:string
    add_column :employee_experiences, :other_benefits,:string
  end
end
