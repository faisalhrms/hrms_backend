class CreateObjectiveSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :objective_settings do |t|
      t.string 		:starting_weight
      t.string 		:ending_weight
      t.integer 	:employee_id
      t.string   	:task_ids
      t.string   	:sub_task_ids
      t.timestamps
    end
    add_index :objective_settings, :employee_id
  end
end
