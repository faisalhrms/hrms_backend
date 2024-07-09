class AddIsInchargeColumnInEmployee < ActiveRecord::Migration[7.1]
  def change
    add_column  :employees, :is_incharge, :boolean, :default => false
  end
end
