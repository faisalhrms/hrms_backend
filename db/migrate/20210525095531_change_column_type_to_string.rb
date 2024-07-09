class ChangeColumnTypeToString < ActiveRecord::Migration[7.1]
  def change
    remove_column :restrict_leaves, :user_id
  end
end
