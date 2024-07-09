class CreateAppraisalComments < ActiveRecord::Migration[7.1]
  def change
    create_table :appraisal_comments do |t|
      t.integer :type
      t.integer :employee_id
      t.integer :fiscal_year_id
      t.string  :employee_comments
      t.string  :functional
      t.string  :leadership
      t.string  :career_aspiration
      t.string  :line_manager_approval, :default => "Pending"
      t.string  :status,  :default => "Pending"

      t.timestamps
    end
  end
end
