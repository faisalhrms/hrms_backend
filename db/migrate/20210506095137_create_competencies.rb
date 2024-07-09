class CreateCompetencies < ActiveRecord::Migration[7.1]
  def change
    create_table :competencies do |t|
      t.string :title
      t.string :description
      t.integer :rating

      t.timestamps
    end
  end
end
