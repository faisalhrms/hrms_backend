class CreateGeneralTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :general_types do |t|
      t.string :name
      t.integer :company_id
      t.text :description
      t.string :type_name

      t.timestamps
    end
  end
end
