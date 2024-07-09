class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :goal
      t.string :weight
      t.string :due_date

      t.timestamps
    end
  end
end
