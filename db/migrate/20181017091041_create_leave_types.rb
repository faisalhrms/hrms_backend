class CreateLeaveTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :leave_types do |t|
			t.integer 	:company_id
			t.string 		:name
			t.string 		:short_name
			t.string 		:gender
			t.string 		:tenure
			t.string 		:eligible
			t.string 		:encashment_applicable
			t.string 		:limit_request_tenure
			t.boolean 	:is_active, 													:default => false
			t.boolean 	:is_deductible, 											:default => false
			t.boolean 	:sandwich, 														:default => false
			t.boolean 	:splitable, 													:default => false
			t.boolean 	:can_apply_in_probation, 							:default => false
			t.boolean 	:pro_rated, 													:default => false
			t.boolean 	:can_apply_for_remaining_leave, 			:default => false
			t.boolean 	:back_date_apply, 										:default => false
			t.boolean 	:encashment, 													:default => false
			t.boolean 	:carry_forward, 											:default => false
			t.boolean 	:limit_request_in_tenure, 						:default => false
			t.float 		:accumulative_count, 									:default => 0.0
			t.float 		:min_day_for_apply_leave, 						:default => 0.0
			t.float 		:min_experience_to_availed_leave, 		:default => 0.0
			t.float 		:limit_request_count, 								:default => 0.0
			t.float 		:back_date_limit, 										:default => 0.0
			t.float 		:encashment_min_limit, 								:default => 0.0
			t.float 		:encashment_max_limit, 								:default => 0.0
			t.float 		:carry_forward_min_limit, 						:default => 0.0
			t.float 		:carry_forward_max_limit, 						:default => 0.0
			t.text 			:description
      t.timestamps
    end
    add_index :leave_types, :company_id
  end
end
