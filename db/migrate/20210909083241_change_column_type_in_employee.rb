class ChangeColumnTypeInEmployee < ActiveRecord::Migration[7.1]
  def change
    remove_column :employees, :group_id,  :integer
    add_column  :employees, :group_id,  :string
  end
end
