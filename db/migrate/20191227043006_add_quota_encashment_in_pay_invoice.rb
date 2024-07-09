class AddQuotaEncashmentInPayInvoice < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_invoices, :quota_encashment, :float, :default => 0.0
  end
end
