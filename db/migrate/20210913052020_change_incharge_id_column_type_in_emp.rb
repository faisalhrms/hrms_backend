class ChangeInchargeIdColumnTypeInEmp < ActiveRecord::Migration[7.1]
  def change
    change_column :employees, :incharge_id, :string
  end
end
