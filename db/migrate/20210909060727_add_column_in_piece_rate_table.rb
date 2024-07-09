class AddColumnInPieceRateTable < ActiveRecord::Migration[7.1]
  def change
    add_column  :piecerates,  :floor_id,  :integer
    remove_column :piecerates,  :machine
    add_column  :piecerates,  :total_machines,  :integer
  end
end
