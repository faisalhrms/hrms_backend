class AddFieldsInEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :spouse_name, 	:string
    add_column :employees, :whatsapp_number, 	:string
    add_column :employees, :linkedln_url, 	:string
    add_column :employees, :marriage_date, 	:datetime
  end
end
