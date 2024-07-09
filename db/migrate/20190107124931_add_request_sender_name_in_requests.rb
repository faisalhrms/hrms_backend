class AddRequestSenderNameInRequests < ActiveRecord::Migration[7.1]
  def change
  	add_column :leave_requests, 				:request_sender_name, :string, :default => ""
  	add_column :official_duties, 				:request_sender_name, :string, :default => ""
  	add_column :relaxation_requests, 		:request_sender_name, :string, :default => ""
  end
end
