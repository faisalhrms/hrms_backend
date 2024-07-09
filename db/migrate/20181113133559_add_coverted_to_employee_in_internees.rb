class AddCovertedToEmployeeInInternees < ActiveRecord::Migration[7.1]
  def change
  	add_column :internees, 				:is_converted, :boolean, :default => false
  	add_column :temporary_staffs, :is_converted, :boolean, :default => false
  end
end
