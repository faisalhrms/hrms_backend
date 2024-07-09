class AddEncashableQuotaInPayInvoices < ActiveRecord::Migration[7.1]
  def change
  	add_column :pay_invoices, :encashable_quota, :float, :default => 0.0
  end
end
