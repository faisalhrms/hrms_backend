class CreateAppraisals < ActiveRecord::Migration[7.1]
  def change
    create_table :appraisals do |t|
      t.integer :objective_id
      t.integer :task_id
      t.integer :competency_id
      t.integer :employee_id

      t.timestamps
    end
  end
end
