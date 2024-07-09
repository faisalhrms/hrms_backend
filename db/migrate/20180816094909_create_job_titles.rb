class CreateJobTitles < ActiveRecord::Migration[7.1]
  def change
    create_table :job_titles do |t|
    	t.integer 	:company_id
    	t.string 		:name
    	t.boolean		:is_active, :default => true
    	t.text			:description
      t.timestamps
    end
    add_index :job_titles, :company_id
  end
end
