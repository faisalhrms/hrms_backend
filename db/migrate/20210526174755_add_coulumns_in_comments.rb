class AddCoulumnsInComments < ActiveRecord::Migration[7.1]
  def change
    add_column  :objective_comments,  :employee_id, :integer
    add_column  :objective_comments,  :fiscal_year_id,  :integer
  end
end
