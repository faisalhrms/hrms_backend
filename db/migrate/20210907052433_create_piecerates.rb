class CreatePiecerates < ActiveRecord::Migration[7.1]
  def change
    create_table :piecerates do |t|
      t.string 	:name
      t.integer :piecerate_type_id
      t.string  :machine

      t.timestamps
    end
  end
end
