class CreateObjectiveComments < ActiveRecord::Migration[7.1]
  def change
    create_table :objective_comments do |t|
      t.references :user, foreign_key: true
      t.text :body
      t.references :objective_setting, foreign_key: true
      t.timestamps
    end
  end
end
