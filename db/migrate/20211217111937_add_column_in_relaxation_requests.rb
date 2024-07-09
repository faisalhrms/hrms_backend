class AddColumnInRelaxationRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :relaxation_requests, :criteria, 	:float, :default => 0.0
    add_column :relaxation_requests, :relaxation_start_date, 	:datetime
    add_column :relaxation_requests, :relaxation_end_date, 	:datetime
  end
end
