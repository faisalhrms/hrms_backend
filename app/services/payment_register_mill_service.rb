class PaymentRegisterMillService
  def initialize(params)
   @pay_invoices = params[:pay_invoices]
  end

  def bank_sheet_excel(book)
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'Bank Sheet')
    book.use_autowidth = false
    sheet.sheet_view do |view|
      view.show_outline_symbols = true
    end
    book.use_autowidth = true

    cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
    sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']

    bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
    header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
    row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    all_total_earning = 0
    total_overtime = 0
    total_gross_pay = 0
    all_total_deduction = 0
    total_net_payable = 0
    total_salary_arrear = 0

    table_header = ["Employee ID","Employee Name", "Father Name", "Designation", "Bank Account No", "Gross Rate", "W. Days", "Basic Pay", "House Rent", "Utility Allow", "Medical", "Washing Allow", "Conveyance Allow", "Incentive", "Other Allow", "Salary Arrears", "Gross Pay", "OT Hours", "OT Amount", "Total Earning",
                    "P. Fund", "Loan", "Advance", "Income Tax", "Electric Bill", "EOBI", "Mess", "Premium", "Misc. Deduction", "Canteen Deduction", "Total Deductions", "Payment Method", "Net Payable"]
    sheet.add_row table_header, :style => header_style
    @pay_invoices.each do |pay_invoice|
      employee = pay_invoice.employee
      total_earning = 0
      gross_salary = 0
      basic_pay = 0
      salary_arrear = 0
      house_rent = 0
      utility_allowance = 0
      medical_allowance = 0
      washing_allowance = 0
      conveyance_allowance = 0
      incentive = pay_invoice.pay_invoice_details.where(:item_name => "Incentive-F").sum(:amount).round(2)
      other_allow = 0
      overtime_amount = pay_invoice.pay_invoice_details.where(:item_name => "Over Time").sum(:amount).round(2)
      pay_invoice.pay_invoice_details.where(:item_type => "Earning").order('id ASC').each do |invoice_detail|
        if invoice_detail.show_in_slip == true
          if invoice_detail.part_of_gross_salary == true and invoice_detail.part_of_other == false
            if invoice_detail.item_name == "Basic Salary"
              item = PayItem.find(invoice_detail.item_id)
              basic_pay = PayItem.actual_calculate_formula_for_slip(employee, item, pay_invoice).round(2)
            elsif invoice_detail.item_name == "House Rent"
              item = PayItem.find(invoice_detail.item_id)
              house_rent = PayItem.actual_calculate_formula_for_slip(employee, item, pay_invoice).round(2)
            elsif invoice_detail.item_name == "Utility Allowance"
              item = PayItem.find(invoice_detail.item_id)
              utility_allowance = PayItem.actual_calculate_formula_for_slip(employee, item, pay_invoice).round(2)
            elsif invoice_detail.item_name == "Medical Allowance"
              item = PayItem.find(invoice_detail.item_id)
              medical_allowance = PayItem.actual_calculate_formula_for_slip(employee, item, pay_invoice).round(2)
            elsif invoice_detail.item_name == "Washing Allowance"
              item = PayItem.find(invoice_detail.item_id)
              washing_allowance = PayItem.actual_calculate_formula_for_slip(employee, item, pay_invoice).round(2)
            elsif invoice_detail.item_name == "Conveyance Allowance"
              item = PayItem.find(invoice_detail.item_id)
              conveyance_allowance = PayItem.actual_calculate_formula_for_slip(employee, item, pay_invoice).round(2)
            else
              other_allow = invoice_detail.amount.round(2)
            end
          end
        end
      end
      salary_arrear = employee.fixed_pay_items.where(is_active: true, pay_item_id: PayItem.find_by_name("Salary Arrears").id).sum(&:item_amount)
      total_salary_arrear += salary_arrear
      gross_salary = pay_invoice.actual_salary
      total_earning = pay_invoice.total_earning

      provident_fund = pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").sum(:amount).round(2)
      loan = pay_invoice.pay_invoice_details.where(:item_name => "Loan").sum(:amount).round(2)
      advance = pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).round(2)
      income_tax = pay_invoice.monthly_tax.round(2)
      electric_bill = pay_invoice.pay_invoice_details.where(:item_name => "Electric Bills-1").sum(:amount).round(2)
      eobi = pay_invoice.pay_invoice_details.where(:item_name => "EOBI").sum(:amount).round(2)
      mess = pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).round(2)
      premium = pay_invoice.pay_invoice_details.where(:item_name => "Insurance Premium GLI").sum(:amount).round(2)
      misc_deduction = pay_invoice.pay_invoice_details.where(:item_name => "Miscellaneous Deduction").sum(:amount).round(2)
      canteen_deduction = pay_invoice.pay_invoice_details.get_by_item_name("Canteen Deduction")
      total_deduction = provident_fund + loan + advance + income_tax + electric_bill + eobi + mess + premium + misc_deduction + canteen_deduction

      current_row_value = []
      current_row_style = []
      current_row_type = []

      current_row_value << pay_invoice.employee_code.to_i
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << employee.full_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.father_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.designation_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.bank_account_number
      current_row_style << row_format
      current_row_type << :string

      current_row_value << gross_salary
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << pay_invoice.no_of_pay_days - pay_invoice.deduction_days
      current_row_style << row_format
      current_row_type << :float

      current_row_value << basic_pay
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << house_rent
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << utility_allowance
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << medical_allowance
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << washing_allowance
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << conveyance_allowance
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << incentive
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << other_allow
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << salary_arrear
      current_row_style << row_format
      current_row_type << :integer

      gross_pay = pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Utility Allowance", "Medical Allowance"]).sum(:amount).round
      gross_pay = PayRollReportData.round_gross_pay(pay_invoice, gross_pay)
      total_gross_pay += gross_pay

      current_row_value << gross_pay
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << pay_invoice.over_time_hours
      current_row_style << row_format
      current_row_type << :integer

      total_overtime += overtime_amount

      current_row_value << overtime_amount
      current_row_style << row_format
      current_row_type << :integer

      all_total_earning += total_earning

      current_row_value << total_earning
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << provident_fund
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << loan
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << advance
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << income_tax
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << electric_bill
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << eobi
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << mess
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << premium
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << misc_deduction
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << canteen_deduction
      current_row_style << row_format
      current_row_type << :integer

      all_total_deduction += total_deduction

      current_row_value << total_deduction
      current_row_style << row_format
      current_row_type << :integer

      if employee.payment_method == "Bank"
        payment_transfer = "Bank Transfer"
      elsif employee.payment_method == "Jazz Cash"
        payment_transfer = "Jazz Cash Transfer"
      elsif employee.payment_method == "Cash"
        payment_transfer = "Cash"
      else
        payment_transfer = ""
      end

      current_row_value << payment_transfer
      current_row_style << row_format
      current_row_type << :string

      total_net_payable += (total_earning - total_deduction)

      current_row_value << total_earning - total_deduction
      current_row_style << row_format
      current_row_type << :integer

      sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
    end
    grand_total = ["Grand Total","", "", "", "", "", "", "", "", "", "", "", "", "", "", total_salary_arrear, total_gross_pay, "", total_overtime, all_total_earning,
                   "", "", "", "", "", "", "", "", "", "", all_total_deduction, "", total_net_payable]
    sheet.add_row grand_total, :style => header_style
    book
  end

  def advance_deductions_excel(book)
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'Advance Deductions')
    book.use_autowidth = false
    sheet.sheet_view do |view|
      view.show_outline_symbols = true
    end
    book.use_autowidth = true

    cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
    sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']

    bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
    header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
    row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    total_advance = 0

    table_header = ["Employee ID","Employee Name", "Designation", "Advance Deduction (Rs.)"]
    sheet.add_row table_header, :style => header_style
    @pay_invoices.includes(:employee).each do |pay_invoice|
      advance = pay_invoice.pay_invoice_details.where(:item_name => "Advance").sum(:amount).round(2)
      total_advance += advance

      current_row_value = []
      current_row_style = []
      current_row_type = []

      current_row_value << pay_invoice.employee_code.to_i
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << pay_invoice.employee.full_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << pay_invoice.employee.designation_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << advance
      current_row_style << row_format
      current_row_type << :float

      sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
    end
    grand_total = ["Grand Total","", "", total_advance]
    sheet.add_row grand_total, :style => header_style
    book
    end
  def income_tax_excel(book)
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'Income Tax Deductions')
    book.use_autowidth = false
    sheet.sheet_view do |view|
      view.show_outline_symbols = true
    end
    book.use_autowidth = true

    cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
    sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']

    bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
    header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
    row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    total_income_tax = 0

    table_header = ["Employee ID","Employee Name", "Designation", "Income Tax Deduction (Rs.)"]
    sheet.add_row table_header, :style => header_style
    @pay_invoices.includes(:employee).each do |pay_invoice|
      income_tax = pay_invoice.monthly_tax.round(2)
      total_income_tax += income_tax

      current_row_value = []
      current_row_style = []
      current_row_type = []

      current_row_value << pay_invoice.employee_code.to_i
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << pay_invoice.employee.full_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << pay_invoice.employee.designation_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << income_tax
      current_row_style << row_format
      current_row_type << :float

      sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
    end
    grand_total = ["Grand Total","", "", total_income_tax]
    sheet.add_row grand_total, :style => header_style
    book
  end

  def mess_deduction_excel(book)
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'Mess Deductions')
    book.use_autowidth = false
    sheet.sheet_view do |view|
      view.show_outline_symbols = true
    end
    book.use_autowidth = true

    cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
    sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']

    bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
    header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
    row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    total_mess = 0

    table_header = ["Employee ID","Employee Name", "Designation", "Mess Deduction (Rs.)"]
    sheet.add_row table_header, :style => header_style
    @pay_invoices.includes(:employee).each do |pay_invoice|
      mess = pay_invoice.pay_invoice_details.where(:item_name => "Mess Deduction").sum(:amount).round(2)
      total_mess += mess

      current_row_value = []
      current_row_style = []
      current_row_type = []

      current_row_value << pay_invoice.employee_code.to_i
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << pay_invoice.employee.full_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << pay_invoice.employee.designation_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << mess
      current_row_style << row_format
      current_row_type << :float

      sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
    end
    grand_total = ["Grand Total","", "", total_mess]
    sheet.add_row grand_total, :style => header_style
    book
  end

  def pay_item_report_excel(book, pay_items)
    @pay_items = pay_items
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'Pay Item Report')
    book.use_autowidth = false
    sheet.sheet_view do |view|
      view.show_outline_symbols = true
    end
    book.use_autowidth = true

    cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
    sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']

    bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
    header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
    row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})

    table_header = ["Employee ID","Employee Name", "Designation"]
    @pay_items.each do |pay_item|
      table_header << pay_item.name
    end
    sheet.add_row table_header, :style => header_style

    pay_item_details = {}
    grand_total = {}
    pay_details = PayInvoiceDetail.where(pay_invoice_id: @pay_invoices.ids, item_id: @pay_items).pluck(:pay_invoice_id, :item_id, :amount)
    pay_details.each do |pay_detail|
      if pay_item_details[pay_detail[0]].nil?
        pay_item_details[pay_detail[0]] = {}
      end
    pay_item_details[pay_detail[0]][pay_detail[1]] = pay_detail[2]
    end

    @pay_invoices.includes(:employee).each do |pay_invoice|
      if pay_item_details[pay_invoice.id].values.sum != 0

        current_row_value = []
        current_row_style = []
        current_row_type = []

        current_row_value << pay_invoice.employee_code
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << pay_invoice.employee.full_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << pay_invoice.employee.designation_name
        current_row_style << row_format
        current_row_type << :string

        @pay_items.each do |pay_item|
          deduction = pay_item_details[pay_invoice.id][pay_item.id]
          current_row_value << deduction
          current_row_style << row_format
          current_row_type << :float
          grand_total[pay_item.id] = grand_total[pay_item.id].to_f + pay_item_details[pay_invoice.id][pay_item.id]
        end

        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
    end
    sheet.add_row ['', '', ''] + grand_total.values, :style => header_style, :types => :string
    book
  end

  def pf_deduction_excel(book)
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'PF Deductions')
    book.use_autowidth = false
    sheet.sheet_view do |view|
      view.show_outline_symbols = true
    end
    book.use_autowidth = true

    cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
    sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']

    bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
    header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
    row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    total_pf = 0

    table_header = ["Employee ID","Employee Name", "Designation", "Basic Salary", "Provident Fund Cont."]
    sheet.add_row table_header, :style => header_style
    department_ids = @pay_invoices.includes(:department).order('departments.name ASC').collect(&:department_id).uniq
    department_ids.each do |department_id|
      table_header = ["Department",Department.find(department_id).name]
      sheet.add_row table_header, :style => header_style
      department_total_pf = 0
      @pay_invoices.includes(:department).where(department_id: department_id).each do |pay_invoice|
        pf = pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").sum(:amount).round(2)
        basic_salary = pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).round(2)
        department_total_pf += pf

        current_row_value = []
        current_row_style = []
        current_row_type = []

        current_row_value << pay_invoice.employee_code.to_i
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << pay_invoice.employee.full_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << pay_invoice.employee.designation_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << basic_salary
        current_row_style << row_format
        current_row_type << :float

        current_row_value << pf
        current_row_style << row_format
        current_row_type << :float

        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
      table_header = ["Total", "", "", "",department_total_pf]
      sheet.add_row table_header, :style => header_style
      total_pf += department_total_pf
    end
    grand_total = ["Grand Total","", "", "", total_pf]
    sheet.add_row grand_total, :style => header_style
    book
  end

  def pf_summary_excel(book, company)
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'PF Summary')
    book.use_autowidth = false
    sheet.sheet_view do |view|
      view.show_outline_symbols = true
    end
    book.use_autowidth = true

    cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
    sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']

    bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
    header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
    row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    total_employee_cont_value = 0
    total_employer_cont_value = 0
    count = 0

    table_header = ["Description","No. of Employees", "Employee's Contribution (In PKR)", "Employer's Contribution (In PKR)", "Total Amount (In PKR)"]
    sheet.add_row table_header, :style => header_style
    @pay_invoices.includes(:employee).each do |pay_invoice|
      count = count + 1
      employee_cont = PayRollReportData.employee_pf_value(pay_invoice)
      employer_cont = PayRollReportData.employeer_pf_value(pay_invoice)
      total_employee_cont_value += employee_cont
      total_employer_cont_value += employer_cont
    end
    current_row_value = []
    current_row_style = []
    current_row_type = []

    current_row_value << company.name
    current_row_style << row_format
    current_row_type << :string

    current_row_value << count
    current_row_style << row_format
    current_row_type << :integer

    current_row_value << total_employee_cont_value
    current_row_style << row_format
    current_row_type << :float

    current_row_value << total_employer_cont_value
    current_row_style << row_format
    current_row_type << :float

    current_row_value << total_employee_cont_value + total_employer_cont_value
    current_row_style << row_format
    current_row_type << :float

    sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
    grand_total = ["Grand Total",count, total_employee_cont_value, total_employer_cont_value, total_employee_cont_value + total_employer_cont_value]
    sheet.add_row grand_total, :style => header_style
    book
  end

end