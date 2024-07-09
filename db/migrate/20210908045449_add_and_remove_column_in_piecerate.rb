class AddAndRemoveColumnInPiecerate < ActiveRecord::Migration[7.1]
  def change
    add_column  :piecerates,  :piecerate_type_name, :string
    remove_column :piecerates,  :piecerate_type_id
  end
end
