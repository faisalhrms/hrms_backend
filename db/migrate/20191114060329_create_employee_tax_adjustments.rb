class CreateEmployeeTaxAdjustments < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_tax_adjustments do |t|
    	t.integer 	:employee_id
      t.integer   :company_id
      t.datetime  :tax_adjustment_month
      t.string    :tax_adjustment_formatted_month
    	t.float 		:amount,       :default => 0.0
      t.boolean   :is_active,    :default => false
    	t.text 			:reason
      t.timestamps
    end
    add_index :employee_tax_adjustments, :company_id
    add_index :employee_tax_adjustments, :employee_id
  end
end
