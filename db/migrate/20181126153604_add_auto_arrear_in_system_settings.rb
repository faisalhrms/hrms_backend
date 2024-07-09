class AddAutoArrearInSystemSettings < ActiveRecord::Migration[7.1]
  def change
  	add_column :system_settings, :auto_arrear, 	:boolean, :default => false
  end
end
