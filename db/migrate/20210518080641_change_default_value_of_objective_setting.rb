class ChangeDefaultValueOfObjectiveSetting < ActiveRecord::Migration[7.1]
  def change
    change_column :objective_settings,  :comments, :string, default: "Nill"
    change_column :objective_settings, :status, :string, default: "Pending"
  end
end
