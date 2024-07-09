class AddNewColumnInRestrictLeave < ActiveRecord::Migration[7.1]
  def change
    add_column :restrict_leaves, :user_ids, :text
  end
end