class AddManagementInGrades < ActiveRecord::Migration[7.1]
  def change
    add_column :grades, :management_type, :string
    add_column :grades, :management_tier, :string
  end
end
