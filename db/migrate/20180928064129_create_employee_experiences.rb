class CreateEmployeeExperiences < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_experiences do |t|
    	t.integer 		:employee_id
    	t.string 			:organization
			t.string 			:job_title
			t.string 			:left_reason
			t.float 			:salary, :default => 0.0
			t.datetime 		:start_date
			t.datetime 		:end_date
			t.string   :avatar_file_name
			t.string   :avatar_content_type
			t.integer  :avatar_file_size
			t.datetime :avatar_updated_at
			t.timestamps
    end
    add_index :employee_experiences, :employee_id
  end
end
