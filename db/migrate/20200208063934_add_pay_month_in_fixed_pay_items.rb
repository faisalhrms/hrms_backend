class AddPayMonthInFixedPayItems < ActiveRecord::Migration[7.1]
  def change
  	add_column :fixed_pay_items, :item_type, 					:string, 		:default => "Recurring"
  	add_column :fixed_pay_items, :pay_month, 					:datetime
  	add_column :fixed_pay_items, :formated_pay_month, :string
  end
end
