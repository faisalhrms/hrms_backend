class CreateEmployeeCertifications < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_certifications do |t|
			t.integer 			:employee_id
			t.string 				:certification_authority
			t.string 				:name
			t.datetime 			:start_date
			t.datetime 			:end_date
			t.float 				:percentage, :default => 0.0
			t.string 				:certification_type
			t.string   :avatar_file_name
			t.string   :avatar_content_type
			t.integer  :avatar_file_size
			t.datetime :avatar_updated_at
			t.timestamps
    end
    add_index :employee_certifications, :employee_id
  end
end
