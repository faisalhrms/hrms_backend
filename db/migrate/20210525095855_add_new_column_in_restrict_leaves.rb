class AddNewColumnInRestrictLeaves < ActiveRecord::Migration[7.1]
  def change
    add_column  :restrict_leaves, :user_id, :string
  end
end
