class CreateOverStrengthRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :over_strength_requests do |t|
    	t.integer  :company_id
	    t.integer  :employee_id
	    t.integer  :department_id
	    t.float    :request_count,       default: 0.0
	    t.datetime :start_date
	    t.datetime :end_date
	    t.string   :request_status
	    t.string   :apply_status
	    t.boolean  :is_cancelled,        default: false
	    t.text     :reason
	    t.string   :request_sender_name, default: ""
      t.timestamps
    end
    add_index :over_strength_requests, :company_id
    add_index :over_strength_requests, :employee_id
    add_index :over_strength_requests, :department_id
  end
end
