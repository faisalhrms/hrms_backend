class CreateReligionSects < ActiveRecord::Migration[7.1]
  def change
    create_table :religion_sects do |t|
    	t.string 		:name
      t.timestamps
    end
  end
end
