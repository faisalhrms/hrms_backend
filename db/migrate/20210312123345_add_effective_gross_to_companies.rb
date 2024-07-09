class AddEffectiveGrossToCompanies < ActiveRecord::Migration[7.1]
  def change
    add_column :companies, :effective_gross, :boolean
  end
end
