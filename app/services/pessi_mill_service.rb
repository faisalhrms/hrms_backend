class PessiMillService
  def initialize(params)
    @pay_invoices = params[:pay_invoices]
  end

  def pessi_excel(book)
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'PESSI')
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
    total_gross_salary = 0
    total_gross_pay = 0

    table_header = ["Employee ID","Employee Name", "Father Name", "Designation", "CNIC", "DOB", "PESSI Card No.", "Wrk. Days", "Gross Salary", "Gross Pay", "Amount on Which Cont. is Paid", "PESSI Percent (6%)"]
    sheet.add_row table_header, :style => header_style
    @pay_invoices.includes(:employee).each do |pay_invoice|
      employee = pay_invoice.employee
      if employee.social_security_allowed == true
        gross_salary = pay_invoice.actual_salary
        gross_pay = pay_invoice.actual_salary - (pay_invoice.pay_invoice_details.where(:item_name => "Attendance Deduction").sum(:amount).round)
        cont_amount = Employee::MIN_GROSS_FOR_HEALTH_INSURANCE
        worked_days = pay_invoice.no_of_pay_days - pay_invoice.deduction_days
        if gross_pay >= cont_amount
          pessi_value = cont_amount
        else
          cont_amount = gross_pay
          pessi_value = gross_pay
        end
        if worked_days > 0
          total_gross_pay += gross_pay
          total_gross_salary += gross_salary

          current_row_value = []
          current_row_style = []
          current_row_type = []

          current_row_value << pay_invoice.employee_code.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << pay_invoice.employee.full_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << pay_invoice.employee.father_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << pay_invoice.employee.designation_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.cnic_format(pay_invoice.employee.cnic_number)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(pay_invoice.employee.date_of_birth)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ""
          current_row_style << row_format
          current_row_type << :string

          current_row_value << worked_days
          current_row_style << row_format
          current_row_type << :string

          current_row_value << gross_salary.round(2)
          current_row_style << row_format
          current_row_type << :float

          current_row_value << gross_pay.round(2)
          current_row_style << row_format
          current_row_type << :float

          current_row_value << cont_amount.round(2)
          current_row_style << row_format
          current_row_type << :float

          current_row_value << ((pessi_value/100)*6).round(2)
          current_row_style << row_format
          current_row_type << :float

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

        end
      end
    end
    grand_total = ["Total","", "", "", "", "", "", "", total_gross_salary.round, total_gross_pay.round, "", ""]
    sheet.add_row grand_total, :style => header_style
    book
  end

end