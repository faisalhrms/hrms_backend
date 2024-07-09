class CreateEobis < ActiveRecord::Migration[7.1]
  def change
    create_table :eobis do |t|
    	t.integer 	:company_id
			t.string 		:name
			t.boolean 	:is_active, :default => true
			t.boolean 	:employer_is_taxable, :default => true
			t.boolean 	:employee_is_taxable, :default => true
			t.float 		:employer_wage_rate, 	:default => 0.0
			t.float 		:employer_percentage, :default => 0.0
			t.float 		:employee_wage_rate, 	:default => 0.0
			t.float 		:employee_percentage, :default => 0.0
      t.timestamps
    end
    add_index :eobis, :company_id
  end
end
