class AddExcludedFromReportInEmployees < ActiveRecord::Migration[7.1]
  def change
  	add_column :employees, :excluded_from_reports, :boolean, :default => false
  end
end
