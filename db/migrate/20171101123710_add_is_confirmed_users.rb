class AddIsConfirmedUsers < ActiveRecord::Migration[7.1]
  def change
  	add_column :users, :is_confirmed, :boolean, :default => false
  end
end
