class AddNotificationToRestrictLeave < ActiveRecord::Migration[7.1]
  def change
    add_column :restrict_leaves, :notification, :integer
    add_column :restrict_leaves, :receiver_email, :string
  end
end
