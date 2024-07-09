class CreatePiecerateTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :piecerate_types do |t|
      t.string 	:name
      t.boolean	:is_active, :default => true
      t.text		:description
      t.timestamps
    end
  end
end
