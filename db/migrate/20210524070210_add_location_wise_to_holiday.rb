class AddLocationWiseToHoliday < ActiveRecord::Migration[7.1]
  def change
    add_column :holidays, :location_wise, :boolean, default: false
  end
end
