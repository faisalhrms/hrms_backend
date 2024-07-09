class CreatePieceSlabs < ActiveRecord::Migration[7.1]
  def change
    create_table :piece_slabs do |t|
      t.integer 	:company_id
      t.integer 	:location_id
      t.boolean   :is_active,   default: false
      t.string 		:name
      t.timestamps
    end
    add_index :piece_slabs, :company_id
    add_index :piece_slabs, :location_id
  end
end
