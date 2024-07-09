class ChangeTypeToText < ActiveRecord::Migration[7.1]
  def change
    change_column :objective_settings,  :sub_task_ids,  :text
    change_column  :objective_settings, :task_ids, :text
  end
end
