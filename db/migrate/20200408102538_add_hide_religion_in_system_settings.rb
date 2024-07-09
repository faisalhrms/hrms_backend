class AddHideReligionInSystemSettings < ActiveRecord::Migration[7.1]
  def change
  	add_column :system_settings, :hide_religion, 			:boolean, 			:default => false
		add_column :system_settings, :hide_religion_sect, :boolean, 			:default => false
  end
end
