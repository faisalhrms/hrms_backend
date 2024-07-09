class CreateFiscalYears < ActiveRecord::Migration[7.1]
  def change
    create_table :fiscal_years do |t|
    	t.integer  :company_id
	    t.string   :name
	    t.boolean  :is_active,   default: false
	    t.datetime :start_date
	    t.datetime :end_date
	    t.text     :description
      t.timestamps
    end
    add_index :fiscal_years, :company_id
  end
end
