class AddNtNnumbeToCompany < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :ntn_number, :text
  end
end
