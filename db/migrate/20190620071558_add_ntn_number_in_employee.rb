class AddNtnNumberInEmployee < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :ntn_number, :string
  end
end
