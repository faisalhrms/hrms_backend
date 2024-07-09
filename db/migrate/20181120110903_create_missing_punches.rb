class CreateMissingPunches < ActiveRecord::Migration[7.1]
  def change
    create_table :missing_punches do |t|
    	t.integer 	:company_id
    	t.integer 	:attendance_deduction_id
    	t.integer 	:fallback_id
			t.string 		:name
			t.string 		:code
			t.boolean		:is_active, :default => true
			t.text 			:description
      t.timestamps
    end
    add_index :missing_punches, :company_id
    add_index :missing_punches, :attendance_deduction_id
    add_index :missing_punches, :fallback_id
  end
end
