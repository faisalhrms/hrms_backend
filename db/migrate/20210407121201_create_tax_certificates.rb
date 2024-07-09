class CreateTaxCertificates < ActiveRecord::Migration[7.1]
  def change
    create_table :tax_certificates do |t|
      t.string :sr_number
      t.string :date_of_issue
      t.integer :employee_id
      t.integer :fiscal_year_id

      t.timestamps
    end
  end
end
