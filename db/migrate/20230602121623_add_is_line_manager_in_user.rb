class AddIsLineManagerInUser < ActiveRecord::Migration[7.1]
  def change
    add_column  :users, :is_line_manager,  :boolean, default: false
  end
end
