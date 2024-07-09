class AddFuelCardNumberInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :fuel_card_number, :text, :default => ""
  end
end
