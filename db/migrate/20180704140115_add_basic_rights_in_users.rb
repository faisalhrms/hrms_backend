class AddBasicRightsInUsers < ActiveRecord::Migration[7.1]
  def change
  	add_column :users, :is_admin, 					:boolean, :default => true
  	add_column :users, :custom_right, 			:boolean, :default => false
  end
end


