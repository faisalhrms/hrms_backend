class AddHodIdInEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column  :employees, :hod_id,  :integer
  end
end
