class AddIpAddressInUserActivities < ActiveRecord::Migration[7.1]
  def change
  	add_column :user_activities, 		:ip_address, 	:string
		add_column :user_activities, 		:role_name, 	:string
  end
end
