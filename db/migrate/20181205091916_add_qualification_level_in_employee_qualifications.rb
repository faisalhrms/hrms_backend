class AddQualificationLevelInEmployeeQualifications < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_qualifications, :qualification_level, :string
  end
end
