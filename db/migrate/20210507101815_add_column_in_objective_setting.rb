class AddColumnInObjectiveSetting < ActiveRecord::Migration[7.1]
  def change
    add_column  :objective_settings,  :employee_name, :string
  end
end
