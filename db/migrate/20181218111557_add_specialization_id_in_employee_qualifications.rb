class AddSpecializationIdInEmployeeQualifications < ActiveRecord::Migration[7.1]
  def change
  	add_column :employee_qualifications, :qualification_program_id, 	:integer
		add_column :employee_qualifications, :specialization_id, 					:integer
  end
end
