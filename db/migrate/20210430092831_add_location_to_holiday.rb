class AddLocationToHoliday < ActiveRecord::Migration[7.1]
  def change
    add_column :holidays, :location_id, :integer
    add_column :holidays, :branch_ids, :string
  end
end
