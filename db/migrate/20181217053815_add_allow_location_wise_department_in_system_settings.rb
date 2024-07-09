class AddAllowLocationWiseDepartmentInSystemSettings < ActiveRecord::Migration[7.1]
  def change
  	add_column :system_settings, :location_wise_department, :boolean, :default => false
  end
end
