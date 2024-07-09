class AddPayDeductionOnMissingInInSystemSettings < ActiveRecord::Migration[7.1]
  def change
  	add_column :system_settings, :pay_deduction_on_missing_in, 	:boolean, :default => false
  	add_column :system_settings, :other_remarks_on_time_card, 	:boolean, :default => false
  end
end
