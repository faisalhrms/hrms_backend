class AddCloumnInUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :is_dtl, :boolean , default: false
    add_column :users, :is_wager, :boolean , default: false
    add_column :users, :is_piece_rate, :boolean , default: false
  end
end
