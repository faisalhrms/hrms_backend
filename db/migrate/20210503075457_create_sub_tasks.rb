class CreateSubTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :sub_tasks do |t|
      t.integer 	:task_id
      t.string 		:kpi

      t.timestamps
    end
    add_index :sub_tasks, :task_id
  end
end
