class CreateEmployeeQualifications < ActiveRecord::Migration[7.1]
	def change
		create_table :employee_qualifications do |t|
			t.integer  :employee_id
			t.string   :institute_name
			t.string   :program_name
			t.string   :specialization_name
			t.string   :status
			t.datetime :start_date
			t.datetime :end_date
			t.string   :status_text
			t.float    :gpa_or_percentage, default: 0.0
			t.string   :avatar_file_name
			t.string   :avatar_content_type
			t.integer  :avatar_file_size
			t.datetime :avatar_updated_at

			t.timestamps
		end
		add_index :employee_qualifications, :employee_id
	end
end
