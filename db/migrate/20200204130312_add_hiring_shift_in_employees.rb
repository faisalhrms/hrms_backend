class AddHiringShiftInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :hiring_shift, :string, :default => ""
  end
end
