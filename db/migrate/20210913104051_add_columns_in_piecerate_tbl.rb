class AddColumnsInPiecerateTbl < ActiveRecord::Migration[7.1]
  def change
    add_column  :piecerates,  :line_id, :integer
    add_column  :piecerates,  :category_id, :integer
  end
end
