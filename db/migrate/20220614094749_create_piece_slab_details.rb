class CreatePieceSlabDetails < ActiveRecord::Migration[7.1]
  def change
    create_table :piece_slab_details do |t|
      t.integer 	:piece_slab_id
      t.float 		:lower_limit, 		:default => 0.0
      t.float 		:upper_limit, 		:default => 0.0
      t.float 		:fixed_amount, 		:default => 0.0
      t.timestamps
    end
    add_index :piece_slab_details, :piece_slab_id
  end
end
