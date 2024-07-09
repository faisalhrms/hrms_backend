class CreateRestrictLeaves < ActiveRecord::Migration[7.1]
  def change
    create_table :restrict_leaves do |t|
      t.integer :leave_days
      t.integer :approval_days
      t.boolean :is_active, default: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
