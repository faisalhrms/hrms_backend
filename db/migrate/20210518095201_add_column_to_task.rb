class AddColumnToTask < ActiveRecord::Migration[7.1]
  def change
    add_column  :tasks, :sr_number, :integer
  end
end
