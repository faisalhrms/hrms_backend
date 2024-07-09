class CreateOfficialDuties < ActiveRecord::Migration[7.1]
  def change
    create_table :official_duties do |t|
    	t.integer			:company_id
    	t.integer			:employee_id
    	t.float 			:request_count, 		:default => 0.0
			t.datetime 		:start_date
			t.datetime 		:end_date
			t.datetime 		:start_time
			t.datetime 		:end_time
      t.string      :request_status
      t.string      :apply_status
      t.boolean     :is_cancelled,      :default => false
      t.timestamps
    end
    add_index :official_duties, :company_id
    add_index :official_duties, :employee_id
  end
end
