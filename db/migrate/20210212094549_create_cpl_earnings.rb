class CreateCplEarnings < ActiveRecord::Migration[7.1]
  def change
    create_table :cpl_earnings do |t|
      t.references :employee, foreign_key: true
      t.references :employee_attendance, foreign_key: true
      t.integer :status, :default => 0
      t.string :approval_name, :default => '-'
      t.text :reason
      t.timestamps
    end
  end
end
