class DropPiecerateTypeTable < ActiveRecord::Migration[7.1]
  def change
    drop_table  :piecerate_types
  end
end
