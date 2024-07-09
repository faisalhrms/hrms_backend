class AddSoftwareSkillsInEmployees < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :skills_software,     	:string
    add_column :employees, :skills_level,     	:string
    add_column :employees, :criminal_record,     	:string
  end
end
