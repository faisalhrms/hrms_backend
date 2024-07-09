class AddColumnInAppraisal < ActiveRecord::Migration[7.1]
  def change
    add_column  :appraisals,  :title, :string
    add_column  :appraisals,  :description, :string
  end
end
