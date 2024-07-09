class RemoveHiringShiftFromEmployee < ActiveRecord::Migration[7.1]
  def change
    remove_column :employees, :hiring_shift
  end
end
