class RemoveColumnType < ActiveRecord::Migration[7.1]
  def change
    remove_column :appraisal_comments,  :type
  end
end
