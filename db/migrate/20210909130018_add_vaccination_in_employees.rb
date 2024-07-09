class AddVaccinationInEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :vaccinee_file_name, :string
    add_column :employees, :vaccinee_content_type, :string
    add_column :employees, :vaccinee_file_size, :integer
    add_column :employees, :vaccinee_updated_at, :datetime
    add_column :employees, :vaccinated, 	:boolean, :default => false
  end
end
