class PayInvoiceDetail < ApplicationRecord

	belongs_to	:pay_item, 	foreign_key: :item_id, :class_name => "PayItem"
	belongs_to	:pay_invoice

	scope :insurance_premium_gli, -> {where(:item_name => "Insurance Premium GLI").sum(:amount).round(2)}
	scope :canteen_deduction, -> {where(:item_name => "Canteen Deduction").sum(:amount).round(2)}
	scope :provident_fund, -> {where(:item_name => "Provident Fund").sum(:amount).round(2)}
	scope :loan, -> {where(:item_name => "Loan").sum(:amount).round(2)}
	scope :advance, -> {where(:item_name => "Advance").sum(:amount).round(2)}
	scope :electric_bill, -> {where(:item_name => "Electric Bills-1").sum(:amount).round(2)}
	scope :eobi, -> {where(:item_name => "EOBI").sum(:amount).round(2)}
	scope :mess_deduction, -> {where(:item_name => "Mess Deduction").sum(:amount).round(2)}
	scope :misc_deduction, -> {where(:item_name => "Miscellaneous Deduction").sum(:amount).round(2)}

	scope :get_by_item_name, -> (item_name){where(item_name: item_name).sum(:amount).round}


	def item_name_in_urdu
		if self.pay_item.nil?
			return "-"
		else
			self.pay_item.name_in_urdu
		end
	end

end
