class Api::V1::Web::Reports::EmployeeReportsController < ApplicationController

  def employee_list
    if params[:employee_type_id].to_i == 7 or params[:employee_type_id].to_i == 8 and params[:report_type].to_i == 7
      @company = Company.find (params[:company_id])
      @employees = Employee.where(:is_incharge => true)
      time = Time.now
      url_path = ""
      check_directory("#{Rails.public_path}/pdf")
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/web/reports/employee_reports/piecerate_employee_list.pdf.erb"),
        footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
        :margin => {
          :top      => '0.1in',
          :bottom   => '0.1in',
          :left     => '0.1in',
          :right    => '0.1in'
        },
        dpi: 300,
        orientation: 'Landscape'
      )
      file_name = "employee_list"
      url_path = save_pdf_file(pdf, file_name)

      render json: {message: "Pdf Created", path: url_path}
    elsif params[:employee_type_id].to_i == 7 or params[:employee_type_id].to_i == 8 and params[:report_type].to_i == 8
      @employees = Employee.where(:is_incharge => true)
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Piece Rate')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      header_style1 = wb.styles.add_style(:bg_color => "000000", :fg_color=> "ffffff", :sz => 12, :height => 15, :border=> {:style => :thin, :color => "ffffff"}, :alignment => { :horizontal => :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      green_row_format = wb.styles.add_style(:bg_color => "00ff00", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      yellow_row_format = wb.styles.add_style(:bg_color => "ffff00", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      red_row_format = wb.styles.add_style(:bg_color => "e62e00", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      date_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :format_code => 'yyyy-mm-dd', :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      # Array.new(31).each_index do |index|
      #   sheet.column_info[index].width = 20
      # end
      @employees.each do |employee|
        employee.group_id.split(',').each do |group_id|
          count = 0
          sheet.add_row ["Incharge Emp Code", "Incharge Name", "Group", "Line", "Floor", "Category", "Total Machines", "Total Employees"], :style => header_style1
          group = Piecerate.find(group_id.to_i)
          category = Piecerate.find(group.category_id.to_i)
          line = Piecerate.find(group.line_id.to_i)
          floor = Piecerate.find(line.floor_id.to_i)
          group_employees = Employee.where(:is_incharge => false, :group_id => group_id.to_s)


          row_format = old_row_format

          if count.even? == true
            row_format = even_row_format
          else
            row_format = old_row_format
          end

          current_row_value = []
          current_row_style = []
          current_row_type = []

          current_row_value << employee.employee_code.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee.full_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << group.name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << line.name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << floor.name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << category.name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << group.total_machines
          current_row_style << row_format
          current_row_type << :string


          current_row_value << group_employees.count
          if group_employees.count < group.total_machines
            current_row_style << yellow_row_format
          elsif group_employees.count > group.total_machines
            current_row_style << red_row_format
          else
            current_row_style << green_row_format
          end
          current_row_type << :string

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
          sheet.add_row ["Sr #", "Employee Code", "Employee Name", "Employee Type", "Group", "Line", "Floor", "Category"], :style => header_style
          group_employees.each do |group_emp|
            count = count + 1

            current_row_value = []
            current_row_style = []
            current_row_type = []

            current_row_value << count
            current_row_style << row_format
            current_row_type << :integer

            current_row_value << group_emp.employee_code.to_i
            current_row_style << row_format
            current_row_type << :integer

            current_row_value << group_emp.full_name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << group_emp.employee_type_name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << group.name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << line.name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << floor.name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << category.name
            current_row_style << row_format
            current_row_type << :string

            sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
          end
        end
      end
      file_name = "piecerate_employee_list_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    else
      if params[:report_type].to_i == 3
        if params[:is_active].present?
          if params[:is_active].to_s == "active"
            is_active = true
          elsif params[:is_active].to_s == "archive"
            is_active = false
          else
            is_active = [true, false]
          end
        else
          is_active = [true, false]
        end
      else
        is_active = true
      end

      @show_salary    = User.show_salary(current_user)
      @employees = Employee.where(:company_id => params[:company_id], :is_active => is_active, :salary_exempted => false, :excluded_from_reports => false).non_struck_off.order('id DESC')
      @company = Company.find (params[:company_id])
      if params[:location_ids].blank?
        location_ids = []
      else
        location_ids = params[:location_ids].map(&:to_i)
      end

      #################### Hierarchical Permission ####################
      if current_user.is_location_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => is_active, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
      elsif current_user.is_branch_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => is_active, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
      elsif current_user.is_department_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => is_active, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
      elsif current_user.all_company_department == true
        @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => is_active, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
      elsif current_user.is_sub_department_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => is_active, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
      elsif not current_user.employee.nil?
        if current_user.employee.is_line_manager == true
          sub_ordinates_ids = []
          employee_ids = []
          employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
          employee_ids = employee_ids.flatten.uniq
          employee_ids << current_user.employee.id
          @employees = Employee.where(:id => employee_ids.uniq, :is_active => is_active, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
        end
      end
      #################### Hierarchical Permission ####################


      @employees = Employee.multiple_branch_data(@employees, current_user)
      @employees = @employees.where(:salary_exempted => false).order('id DESC')

      if location_ids.count > 0
        @employees = @employees.where(:location_id => location_ids).order('id DESC')
      end
      if not params[:branch_id].blank?
        @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
      end
      if not params[:department_id].blank?
        @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
      end
      if not params[:designation_id].blank?
        @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
      end
      if not params[:job_title_id].blank?
        @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
      end
      if not params[:grade_id].blank?
        @employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
      end
      if not params[:salary_unit_id].blank?
        @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
      end
      if not params[:cost_center_id].blank?
        @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
      end
      unless params[:report_view] == "Provident Fund Detail"
        if not params[:start_date].blank?
          if not params[:end_date].blank?
            @employees = Employee.where(:id => @employees.collect(&:id), :joining_date => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day)
          else
            @employees = Employee.where(:id => @employees.collect(&:id))
          end
        else
          @employees = Employee.where(:id => @employees.collect(&:id))
        end
      end
      if params[:report_type].to_i == 1
        render status:200, template: 'api/v1/web/reports/employee_reports/employee_list.json.jbuilder'
      elsif params[:report_type].to_i == 2 and params[:report_view] == ""
        time = Time.now
        url_path = ""
        check_directory("#{Rails.public_path}/pdf")
        pdf = WickedPdf.new.pdf_from_string(
          render_to_string("api/v1/web/reports/employee_reports/employee_list.pdf.erb"),
          footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
          :margin => {
            :top      => '0.1in',
            :bottom   => '0.1in',
            :left     => '0.1in',
            :right    => '0.1in'
          },
          dpi: 300,
          orientation: 'Landscape'
        )
        file_name = "employee_list"
        url_path = save_pdf_file(pdf, file_name)

        render json: {message: "Pdf Created", path: url_path}
      elsif params[:report_type].to_i == 2 and params[:report_view] == "Provident Fund Detail"
        @employees = Employee.find(params[:employees].map(&:to_i)) if params[:employees].present?
        check_directory("#{Rails.public_path}/pdf")
        pdf = WickedPdf.new.pdf_from_string(
          render_to_string("api/v1/web/reports/employee_reports/pf_deduction_details.pdf.erb"),
          footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
          :margin => {
            :top      => '0.1in',
            :bottom   => '0.1in',
            :left     => '0.1in',
            :right    => '0.1in'
          },
          dpi: 300,
          orientation: 'Landscape'
        )
        file_name = "employee_list"
        url_path = save_pdf_file(pdf, file_name)

        render json: {message: "Pdf Created", path: url_path}
      elsif params[:report_type].to_i == 6
        if params[:employees].present?
          @employees = Employee.get_by_company(params[:company_id]).where(:id => params[:employees], confimration_due_date: params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day, :location_id => params[:location_ids].map(&:to_i))
        else
          @employees = Employee.get_by_company(params[:company_id]).where(confimration_due_date: params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day, :location_id => params[:location_ids].map(&:to_i))
        end
        if @employees.count > 0
          check_directory("#{Rails.public_path}/pdf")
          pdf = WickedPdf.new.pdf_from_string(
            render_to_string("api/v1/web/reports/employee_reports/confirmation_letter.pdf.erb"),
            footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
            :margin => {
              :top      => '0.1in',
              :bottom   => '0.1in',
              :left     => '0.1in',
              :right    => '0.1in'
            },
            dpi: 300,
            orientation: 'Portrait',
            )
          file_name = "confirmation_letter"
          url_path = save_pdf_file(pdf, file_name)
          render json: {message: "Pdf Created", path: url_path}
        else
          render json: {errors: "No Record Found"}, status: :unprocessable_entity
        end

      elsif params[:report_type].to_i == 3
        if srl_instance? or dtl_instance?
          srl_employee_list_details
        else
          time = Time.now
          book = Axlsx::Package.new
          check_directory("#{Rails.public_path}/excel")
          wb = book.workbook
          sheet = wb.add_worksheet(name: 'Employee List')
          book.use_autowidth = false
          sheet.sheet_view do |view|
            view.show_outline_symbols = true
          end
          book.use_autowidth = true
          header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
          bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
          cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

          sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
          sheet.add_row ['']
          sheet.add_row ['']
          sheet.add_row ['']
          sheet.add_row ['']

          sheet.add_row ["Sr #", "Emp Code", "Salutation", "Name", "Father Name", "Mother Name","Grade", "Designation", "Location", "Branch", "Department", "Sub Department", "Job Title", "Employee Type", "Hiring Shift", "Employment Status", "CNIC", "CNIC Expiry Date", "DOB", "DOJ", "DOC", "Contract Start Date", "Contract End Date", "Date Of Retirement","Official Email", "Official Number", "Personal Number","Emergency Contact Number","Current Address", "Permanent Address", "Service Tenure", "Experience", "Blood Group","Martial Status","Gross Salary", "Incentive", "Line Manager", "Line Manager Employee Code", "Employee Status"], :style => header_style

          old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
          date_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :format_code => 'yyyy-mm-dd', :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
          even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
          Array.new(31).each_index do |index|
            sheet.column_info[index].width = 20
          end
          count = 0
          @employees.each do |employee|
            count = count + 1
            row_format = old_row_format

            if count.even? == true
              row_format = even_row_format
            else
              row_format = old_row_format
            end

            current_row_value = []
            current_row_style = []
            current_row_type = []

            current_row_value << count
            current_row_style << row_format
            current_row_type << :integer

            current_row_value << employee.employee_code.to_i
            current_row_style << row_format
            current_row_type << :integer

            current_row_value << employee.salutation
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee.full_name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee.father_name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee.mother_name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee.grade_name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee.designation_name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee.location_name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee.branch_name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee.department_name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee.sub_department_name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee.job_title_name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee.employee_type_name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee.hiring_shift
            current_row_style << row_format
            current_row_type << :string

            current_row_value << ReportFormat.boolean_in_text_as_confirmed(employee.on_probation)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << ReportFormat.cnic_format(employee.cnic_number)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << ReportFormat.date_format(employee.cnic_expiry_date)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee.date_of_birth.to_date
            current_row_style << date_format
            current_row_type << :date

            current_row_value << employee.joining_date.to_date
            current_row_style << date_format
            current_row_type << :date

            current_row_value << employee.confirmation_date.try(:to_date)
            current_row_style << date_format
            current_row_type << :date

            current_row_value << ReportFormat.date_format(employee.contract_start_date)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << ReportFormat.date_format(employee.contract_end_date)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << "-"
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee.official_email
            current_row_style << row_format
            current_row_type << :string

            current_row_value << ReportFormat.phone_format(employee.official_mobile_number)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << ReportFormat.phone_format(employee.personal_number)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << ReportFormat.phone_format(employee.emergency_contact_phone)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee.current_address
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee.permanent_address
            current_row_style << row_format
            current_row_type << :string

            current_row_value << ReportFormat.date_in_human_readable(employee.joining_date)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << ReportFormat.employee_experince(employee.joining_date)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee.blood_group
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee.martial_status
            current_row_style << row_format
            current_row_type << :string

            if @show_salary == true
              current_row_value << employee.gross_salary
              current_row_style << row_format
              current_row_type << :float
            else
              current_row_value << "-"
              current_row_style << row_format
              current_row_type << :string
            end

            current_row_value << employee.incentives
            current_row_style << row_format
            current_row_type << :float

            current_row_value << employee.line_manager_name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee.line_manager_employee_code.to_i
            current_row_style << row_format
            current_row_type << :integer

            if employee.is_active == true
              current_row_value << "Active"
            else
              current_row_value << "In-Active"
            end
            current_row_style << row_format
            current_row_type << :string

            sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
          end
          file_name = "employee_list_report"
          url_path = save_excel_file(book, file_name)
          render json: {message: "Excel Created", path: url_path}
        end
      elsif params[:report_type].to_i == 4
        time = Time.now
        book = Axlsx::Package.new
        check_directory("#{Rails.public_path}/excel")
        wb = book.workbook
        sheet = wb.add_worksheet(name: 'User Account')
        book.use_autowidth = false
        sheet.sheet_view do |view|
          view.show_outline_symbols = true
        end
        book.use_autowidth = true
        header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
        bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
        cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

        sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
        sheet.add_row ['']
        sheet.add_row ['']
        sheet.add_row ['']
        sheet.add_row ['']

        sheet.add_row ["Sr #", "Salary Unit", "Location", "Emp Code", "Name", "Department", "Designation", "DOJ", "Date of Transfer", "User Account", "Role", "Email"], :style => header_style
        old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
        date_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :format_code => 'yyyy-mm-dd', :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
        even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
        # Array.new(31).each_index do |index|
        #   sheet.column_info[index].width = 20
        # end
        count = 0
        @employees.each do |employee|
          count = count + 1
          row_format = old_row_format

          if count.even? == true
            row_format = even_row_format
          else
            row_format = old_row_format
          end

          current_row_value = []
          current_row_style = []
          current_row_type = []

          if count.even? == true
            row_format = even_row_format
          else
            row_format = old_row_format
          end

          current_row_value = []
          current_row_style = []
          current_row_type = []

          current_row_value << count
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee.salary_unit_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.location_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.employee_code.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee.full_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.department_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.designation_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(employee.joining_date)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(employee.old_joining_date)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.create_login)
          current_row_style << row_format
          current_row_type << :string

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
        end
        file_name = "employee_list_report"
        url_path = save_excel_file(book, file_name)
        render json: {message: "Excel Created", path: url_path}
      elsif params[:report_type].to_i == 5
        time = Time.now
        book = Axlsx::Package.new
        check_directory("#{Rails.public_path}/excel")
        wb = book.workbook
        sheet = wb.add_worksheet(name: 'Attendnace Information')
        book.use_autowidth = false
        sheet.sheet_view do |view|
          view.show_outline_symbols = true
        end
        book.use_autowidth = true
        header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
        bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
        cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

        sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
        sheet.add_row ['']
        sheet.add_row ['']
        sheet.add_row ['']
        sheet.add_row ['']

        sheet.add_row ["Sr #", "Salary Unit", "Location", "Emp Code", "Name", "Department", "Designation", "Attendance Exception", "Overtime (Regular Working Day)", "Overtime (Rest Day)", "Off Day Working", "Quota Encashment (Regular Working Day)", "Quota Encashment (Rest Day)", "CPL (Rest/Public Day)", "Late Exempted", "Attendance Exempted", "Approval Based Overtime", "Salary Exempted", "Hold Salary", "Back Date EOBI", "Back Date Allowance", "Back Date Provident Fund", "Medical Allowance (Restriction)"], :style => header_style
        old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
        date_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :format_code => 'yyyy-mm-dd', :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
        even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')

        count = 0
        @employees.each do |employee|
          count = count + 1
          row_format = old_row_format

          if count.even? == true
            row_format = even_row_format
          else
            row_format = old_row_format
          end

          current_row_value = []
          current_row_style = []
          current_row_type = []

          if count.even? == true
            row_format = even_row_format
          else
            row_format = old_row_format
          end

          current_row_value = []
          current_row_style = []
          current_row_type = []

          current_row_value << count
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee.salary_unit_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.location_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.employee_code.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee.full_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.department_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.designation_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.attendance_impact_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.is_overtime)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.is_holiday_overtime)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.is_off_day_working)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.regular_quota_encashment)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.holiday_quota_encashment)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.is_regular_cpl)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.late_exempted)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.attendance_exempted)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.approval_base_overtime)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.salary_exempted)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.hold_salary)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.back_date_eobi_impact)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.back_date_allowance_impact)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.back_date_pf_impact)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.is_medical_allowance)
          current_row_style << row_format
          current_row_type << :string

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
        end
        file_name = "employee_list_report"
        url_path = save_excel_file(book, file_name)
        render json: {message: "Excel Created", path: url_path}
      elsif params[:report_type].to_i == 10
        time = Time.now
        book = Axlsx::Package.new
        check_directory("#{Rails.public_path}/excel")
        wb = book.workbook
        sheet = wb.add_worksheet(name: 'Compliance List')
        book.use_autowidth = false
        sheet.sheet_view do |view|
          view.show_outline_symbols = true
        end
        book.use_autowidth = true
        header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
        bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
        cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

        sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
        sheet.add_row ['']
        sheet.add_row ['']
        sheet.add_row ['']
        sheet.add_row ['']

        sheet.add_row ["Sr #", "Employee Code", "Employee Name", "Location", "Branch", "Department", "Designation", "Employee Email", "Line Manager Name", "Line Manager Email", "HOD Name", "HOD Email"], :style => header_style
        old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
        date_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :format_code => 'yyyy-mm-dd', :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
        even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')

        count = 0
        @employees.each do |employee|
          count = count + 1
          row_format = old_row_format

          if count.even? == true
            row_format = even_row_format
          else
            row_format = old_row_format
          end

          current_row_value = []
          current_row_style = []
          current_row_type = []

          if count.even? == true
            row_format = even_row_format
          else
            row_format = old_row_format
          end

          current_row_value = []
          current_row_style = []
          current_row_type = []

          current_row_value << count
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee.employee_code
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.full_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.location_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.branch_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.department_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.designation_name
          current_row_style << row_format
          current_row_type << :string

          if employee.official_email.present?
            current_row_value << employee.official_email
            current_row_style << row_format
            current_row_type << :string
          else
            current_row_value << ""
            current_row_style << row_format
            current_row_type << :string
          end

          if employee.line_manager.present?
            current_row_value << employee.line_manager.full_name
            current_row_style << row_format
            current_row_type << :string
          else
            current_row_value << ""
            current_row_style << row_format
            current_row_type << :string
          end

          if employee.line_manager.present?
            if employee.line_manager.official_email.present?
              current_row_value << employee.line_manager.official_email
              current_row_style << row_format
              current_row_type << :string
            else
              current_row_value << ""
              current_row_style << row_format
              current_row_type << :string
            end
          else
            current_row_value << ""
            current_row_style << row_format
            current_row_type << :string
          end

          if employee.head_of_department.present?
            current_row_value << employee.head_of_department.full_name
            current_row_style << row_format
            current_row_type << :string
          else
            current_row_value << ""
            current_row_style << row_format
            current_row_type << :string
          end

          if employee.head_of_department.present?
            if employee.head_of_department.official_email.present?
              current_row_value << employee.head_of_department.official_email
              current_row_style << row_format
              current_row_type << :string
            else
              current_row_value << ""
              current_row_style << row_format
              current_row_type << :string
            end
          else
            current_row_value << ""
            current_row_style << row_format
            current_row_type << :string
          end

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
        end
        file_name = "compliance_list"
        url_path = save_excel_file(book, file_name)
        render json: {message: "Excel Created", path: url_path}
      end
    end
  end



  def employee_profile_detail
    @show_salary    = User.show_salary(current_user)
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :salary_exempted => false, :excluded_from_reports => false).non_struck_off.order('id DESC')
    @company = Company.find (params[:company_id])
    if params[:location_ids].blank?
      location_ids = []
    else
      location_ids = params[:location_ids].map(&:to_i)
    end

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
      end
    end
    #################### Hierarchical Permission ####################

    if location_ids.count > 0
      @employees = @employees.where(:location_id => location_ids).order('id DESC')
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end

    if not (params[:start_date].blank? and params[:end_date].blank?)
      @employees = Employee.where(:id => @employees.collect(&:id), :joining_date => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day)
    else
      @employees = Employee.where(:id => @employees.collect(&:id))
    end

    @employees = @employees.where(:is_active => true, :salary_exempted => false).order('id DESC')

    if params[:report_type].to_i == 1
      render status:200, template: 'api/v1/web/reports/employee_reports/employee_profile_detail.json.jbuilder'
    elsif params[:report_type].to_i == 2
      time = Time.now
      url_path = ""
      check_directory("#{Rails.public_path}/pdf")
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/web/reports/employee_reports/employee_profile_detail.pdf.erb"),
        footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
        :margin => {
          :top      => '0.1in',
          :bottom   => '0.1in',
          :left     => '0.1in',
          :right    => '0.1in'
        },
        dpi: 300,
        orientation: 'Landscape'
      )
      file_name = "employee_list"
      url_path = save_pdf_file(pdf, file_name)

      render json: {message: "Pdf Created", path: url_path}
    elsif params[:report_type].to_i == 3
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Employee Profile Detail')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Salary Unit", "Location", "Employee Type", "Emp Code", "Name", "Father Name", "Department", "Designation", "Grade", "DOJ", "Gross Salary", "Probation Period", "Total Experience", "Official Email Address", "Personal Email Address", "Official Mobile #", "Personal Mobile #", "DOB", "Age", "CNIC No.", "Expiry date of CNIC", "NTN #", "Present Address", "Permanent Address", "Contract Start Date", "Contract End Date", "Confirmation Date", "Is Line Manager", "Line Manager"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      Array.new(28).each_index do |index|
        sheet.column_info[index].width = 20
      end
      count = 0
      @employees.each do |employee|
        count = count + 1
        row_format = old_row_format

        if count.even? == true
          row_format = even_row_format
        else
          row_format = old_row_format
        end

        current_row_value = []
        current_row_style = []
        current_row_type = []

        current_row_value << count
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.salary_unit_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.location_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.employee_type_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.employee_code.to_i
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.full_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.father_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.department_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.designation_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.grade_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.joining_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.gross_salary.to_f
        current_row_style << row_format
        current_row_type << :float

        current_row_value << ReportFormat.boolean_in_text(employee.on_probation)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.employee_current_experince_in_years(employee)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.official_email
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.personal_email
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.phone_format(employee.official_mobile_number)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.phone_format(employee.personal_number)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.date_of_birth)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.employee_age(employee.date_of_birth)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.cnic_format(employee.cnic_number)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.cnic_expiry_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.ntn_number
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.current_address
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.permanent_address
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.contract_start_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.contract_end_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.confimration_due_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.boolean_in_text(employee.is_line_manager)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.line_manager_name
        current_row_style << row_format
        current_row_type << :string

        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
      file_name = "employee_profile_detail_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    elsif params[:report_type].to_i == 5
      document_checklist
    elsif params[:report_type].to_i == 4
      if srl_instance? or dtl_instance?
        srl_employee_profile_report
      else
        time = Time.now
        book = Axlsx::Package.new
        check_directory("#{Rails.public_path}/excel")
        wb = book.workbook
        sheet = wb.add_worksheet(name: 'Employee Profile Detail')
        book.use_autowidth = false
        sheet.sheet_view do |view|
          view.show_outline_symbols = true
        end
        book.use_autowidth = true
        header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
        bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
        cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

        sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
        sheet.add_row ['']
        sheet.add_row ['']
        sheet.add_row ['']
        sheet.add_row ['']

        sheet.add_row ['Personal Information', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 'Present Address', '', '', '', '', '', '', '', 'Permanent Address', '', '', '', '', '', '', '', 'Employment Information', '', '', '', '', '', '', '', '', '', 'User Account', '', '', 'Emergency Contact', '', '', '', 'Attendance Information', '', '', '', '', '', '', '', '', '', '', '', '', '', 'Salary Information ', 'Salary Information', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 'Benefits Information', 'Benefits Information', 'Benefits Information', 'Benefits Information', 'Benefits Information', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 'Other Information', 'Other Information', ''], :style => header_style
        sheet.merge_cells Axlsx::cell_r(0, 5) + ':' + Axlsx::cell_r(34, 5)
        sheet.merge_cells Axlsx::cell_r(35, 5) + ':' + Axlsx::cell_r(42, 5)
        sheet.merge_cells Axlsx::cell_r(43, 5) + ':' + Axlsx::cell_r(50, 5)
        sheet.merge_cells Axlsx::cell_r(51, 5) + ':' + Axlsx::cell_r(60, 5)
        sheet.merge_cells Axlsx::cell_r(61, 5) + ':' + Axlsx::cell_r(63, 5)
        sheet.merge_cells Axlsx::cell_r(64, 5) + ':' + Axlsx::cell_r(67, 5)
        sheet.merge_cells Axlsx::cell_r(68, 5) + ':' + Axlsx::cell_r(82, 5)
        sheet.merge_cells Axlsx::cell_r(83, 5) + ':' + Axlsx::cell_r(100, 5)
        sheet.merge_cells Axlsx::cell_r(101, 5) + ':' + Axlsx::cell_r(119, 5)
        sheet.merge_cells Axlsx::cell_r(120, 5) + ':' + Axlsx::cell_r(122, 5)
        sheet.add_row ["Sr #", "Emp Code", "Name", "Salutation", "First Name", "Last Name", "Father Name", "Mother Name", "Location Type", "Location", "Department", "Sub Department", "Grade", "Designation", "Job Title", "Salary Unit", "Cost Center", "Employee Type", "Official Email Address", "Personal Email Address", "Official Mobile #", "Personal Mobile #", "DOB", "Age", "Gender", "Blood Group", "Marital Status", "CNIC No.", "Expiry date of CNIC", "File Number", "Family Number", "Tags", "NTN #", "Religion", "Religion Sect", "Present Address", "Country", "State/Province", "City", "Division", "Tehsil", "Union Council", "Police Station", "Permanent Address", "Country", "State/Province", "City", "Division", "Tehsil", "Union Council", "Police Station", "DOJ", "Old Joining Date", "Date of Transfer", "Contract Start Date", "Contract End Date", "Confirmation Due Date", "Confirmation Date", "Previous Employee Code", "Is Line Manager ?", "Line Manager", "User Account", "Role", "Email", "Emergency Contact Name", "Emergency Contact Relation", "Emergency Contact Email", "Emergency Contact Phone", "Request Exempted", "Attendance Exception", "Overtime (Regular Working Day)", "Overtime (Rest Day)", "Off Day Working", "Quota Encashment (Regular Working Day)", "Quota Encashment (Rest Day)", "CPL (Regular Working Day)", "CPL (Rest/Public Day)", "", "Late Exempted", "Attendance Exempted", "Approval Based Overtime", "Exempted From Reports", "-", "Payment Method", "Gross Salary", "Salary Exempted", "Hold Salary", "Back Date EOBI", "Back Date Allowance", "Back Date Provident Fund", "-", "Medical Allowance (Restriction)", "-", "-", "-", "-", "Bank Name", "Branch Name", "Branch Code", "Account Title", "Account #", "Social Security", "Group Life Insurance", "Health Insurance", "Cellphone Bill", "Fuel Reimbursement", "Cell Phone", "Laptop", "Vehicle", "Provident Fund", "EOBI", "Gratuity", "House Allowance", "LFA", "Vehicle Allowance", "Maintenance", "Travel Allowance", "Eid-ul-fitr Bonus", "Eid-ul-Azha Bonus", "Annual Bonus", "Total # of Experience before Sapphire", "Total # of Experience with Sapphire", "Status"], :style => header_style

        old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
        even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
        Array.new(28).each_index do |index|
          sheet.column_info[index].width = 20
        end
        count = 0
        @employees.each do |employee|
          count = count + 1
          row_format = old_row_format

          if count.even? == true
            row_format = even_row_format
          else
            row_format = old_row_format
          end

          current_row_value = []
          current_row_style = []
          current_row_type = []

          current_row_value << count
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee.employee_code.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee.full_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.salutation
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.first_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.last_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.father_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.location_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.branch_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.department_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.sub_department_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.grade_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.designation_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.job_title_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.salary_unit_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.cost_center_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.employee_type_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.official_email
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.personal_email
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.phone_format(employee.official_mobile_number)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.phone_format(employee.personal_number)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(employee.date_of_birth)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.employee_age(employee.date_of_birth)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.gender
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.blood_group
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.martial_status
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.cnic_format(employee.cnic_number)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(employee.cnic_expiry_date)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.file_number
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.family_number
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.tags
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.ntn_number
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.religion_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.religion_sect_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.permanent_address
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.permanent_country_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.permanent_state_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.permanent_city_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.division_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.tehsil_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.current_address
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.country_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.state_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.city_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.division_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.tehsil_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(employee.joining_date)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(employee.contract_start_date)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(employee.contract_end_date)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(employee.confimration_due_date)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(employee.confirmation_date)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.prev_employee_code
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.is_line_manager)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.line_manager_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.create_login)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.role_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.user_account_email
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.emergency_contact_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.relationship_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.emergency_contact_email
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.phone_format(employee.emergency_contact_phone)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.attendance_impact_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.is_overtime)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.is_holiday_overtime)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.is_off_day_working)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.regular_quota_encashment)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.regular_quota_encashment)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.is_regular_cpl)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.is_cpl)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.late_exempted)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.attendance_exempted)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.approval_base_overtime)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.excluded_from_reports)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.payment_method
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.gross_salary
          current_row_style << row_format
          current_row_type << :float

          current_row_value << ReportFormat.boolean_in_text(employee.salary_exempted)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.hold_salary)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.back_date_eobi_impact)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.back_date_allowance_impact)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.back_date_pf_impact)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.is_medical_allowance)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.bank_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.bank_branch_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.bank_branch_code
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.bank_account_title
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.bank_account_number
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.social_security_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.life_insurance_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.health_insurance_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.cell_phone_bill_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.fuel_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.cell_phone_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.laptop_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.velicle_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.provident_fund_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.eobi_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.house_allowance_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.lfa_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.vehicle_allowance_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.maintenance_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.travel_allowance_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.bonus1_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.bonus2_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.bonus3_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.employee_previous_experince(employee)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.employee_current_experince(employee)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.is_active)
          current_row_style << row_format
          current_row_type << :string

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

        end
        file_name = "employee_profile_detail_report"
        url_path = save_excel_file(book, file_name)
        render json: {message: "Excel Created", path: url_path}
      end
    end
  end


  def line_manager_detail
    @show_salary    = User.show_salary(current_user)
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :excluded_from_reports => false).where.not(:line_manager_id => nil).order('line_manager_id ASC')
    @company = Company.find (params[:company_id])
    if params[:location_ids].blank?
      location_ids = []
    else
      location_ids = params[:location_ids].map(&:to_i)
    end

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :excluded_from_reports => false).order('id DESC')
      end
    end
    #################### Hierarchical Permission ####################

    @employees = Employee.multiple_branch_data(@employees, current_user)

    if location_ids.count > 0
      @employees = @employees.where(:location_id => location_ids).order('id DESC')
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end

    if not (params[:start_date].blank? and params[:end_date].blank?)
      @employees = Employee.where(:id => @employees.collect(&:id), :joining_date => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day)
    else
      @employees = Employee.where(:id => @employees.collect(&:id))
    end

    @employees = @employees.where.not(:line_manager_id => nil).order('line_manager_id ASC')

    if params[:report_type].to_i == 1
      render status:200, template: 'api/v1/web/reports/employee_reports/line_manager_detail.json.jbuilder'
    elsif params[:report_type].to_i == 2
      time = Time.now
      url_path = ""
      check_directory("#{Rails.public_path}/pdf")
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/web/reports/employee_reports/line_manager_detail.pdf.erb"),
        footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
        :margin => {
          :top      => '0.1in',
          :bottom   => '0.1in',
          :left     => '0.1in',
          :right    => '0.1in'
        },
        dpi: 300,
        orientation: 'Landscape'
      )
      file_name = "employee_list"
      url_path = save_pdf_file(pdf, file_name)

      render json: {message: "Pdf Created", path: url_path}
    elsif params[:report_type].to_i == 3
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Employee List')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Emp Code", "Name", "Grade", "Designation", "Location", "Branch", "Department", "Job Title", "Line Manager", "HOD", "CNIC", "DOJ", "DOB", "Official Email", "Official Number"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')

      Array.new(15).each_index do |index|
        sheet.column_info[index].width = 20
      end

      count = 0
      @employees.each do |employee|
        count = count + 1
        row_format = old_row_format

        if count.even? == true
          row_format = even_row_format
        else
          row_format = old_row_format
        end

        current_row_value = []
        current_row_style = []
        current_row_type = []

        current_row_value << count
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.employee_code.to_i
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.full_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.grade_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.designation_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.location_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.branch_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.department_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.job_title_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.line_manager_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.hod_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.cnic_format(employee.cnic_number)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.joining_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.date_of_birth)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.official_email
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.phone_format(employee.official_mobile_number)
        current_row_style << row_format
        current_row_type << :string

        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
      file_name = "line_manager_detail"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    end
  end

  def joiner_detail
    is_active = true
    if params[:is_active] == "Active"
      is_active = true
    else
      is_active = false
    end

    @show_salary    = User.show_salary(current_user)
    @employees = Employee.where(:company_id => params[:company_id], :is_active => is_active, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    @company = Company.find (params[:company_id])
    if params[:location_ids].blank?
      location_ids = []
    else
      location_ids = params[:location_ids].map(&:to_i)
    end

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => is_active, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => is_active, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => is_active, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => is_active, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => is_active, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => is_active, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
      end
    end
    #################### Hierarchical Permission ####################

    @employees = Employee.multiple_branch_data(@employees, current_user)

    if location_ids.count > 0
      @employees = @employees.where(:location_id => location_ids).order('id DESC')
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end

    @employees = Employee.where(:id => @employees.collect(&:id), :joining_date => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day)

    if params[:report_type].to_i == 1
      render status:200, template: 'api/v1/web/reports/employee_reports/joiner_detail.json.jbuilder'
    elsif params[:report_type].to_i == 2
      time = Time.now
      url_path = ""
      check_directory("#{Rails.public_path}/pdf")
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/web/reports/employee_reports/joiner_detail.pdf.erb"),
        footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
        :margin => {
          :top      => '0.1in',
          :bottom   => '0.1in',
          :left     => '0.1in',
          :right    => '0.1in'
        },
        dpi: 300,
        orientation: 'Landscape'
      )
      file_name = "view_activity_stream"
      url_path = save_pdf_file(pdf, file_name)

      render json: {message: "Pdf Created", path: url_path}
    elsif params[:report_type].to_i == 3
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Joiner Detail')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Emp Code", "Salutation", "Name", "Gender", "Location", "Branch", "Department", "Grade", "Designation", "CNIC", "DOJ", "DOB", "Address", "Age", "Salary"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')

      Array.new(14).each_index do |index|
        sheet.column_info[index].width = 20
      end

      count = 0
      @employees.each do |employee|
        count = count + 1
        row_format = old_row_format

        if count.even? == true
          row_format = even_row_format
        else
          row_format = old_row_format
        end

        current_row_value = []
        current_row_style = []
        current_row_type = []

        current_row_value << count
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.employee_code.to_i
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.salutation
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.full_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.gender
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.location_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.branch_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.department_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.grade_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.designation_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.cnic_format(employee.cnic_number)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.joining_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.date_of_birth)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.current_address
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_in_human_readable(employee.date_of_birth)
        current_row_style << row_format
        current_row_type << :string

        if @show_salary == true
          current_row_value << employee.gross_salary
          current_row_style << row_format
          current_row_type << :float
        else
          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string
        end

        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
      file_name = "joiner_detail_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    elsif params[:report_type].to_i == 4
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Joiner Detail')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Salary Unit", "Location", "Employee Type", "Emp Code", "File No.", "Salutation", "Name", "Father Name", "Department", "Designation", "Grade", "DOJ", "Date of Transfer", "Joining Salary", "Probationary Period", "Salary after Proation", "Reporting To", "Total Experience", "Latest Qulaification", "Year passed ", "Institute"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')

      Array.new(14).each_index do |index|
        sheet.column_info[index].width = 20
      end

      count = 0
      @employees.each do |employee|
        count = count + 1
        row_format = old_row_format

        if count.even? == true
          row_format = even_row_format
        else
          row_format = old_row_format
        end

        current_row_value = []
        current_row_style = []
        current_row_type = []

        current_row_value << count
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.salary_unit_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.location_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.employee_type_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.employee_code.to_i
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.file_number
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.salutation
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.full_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.father_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.department_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.designation_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.grade_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.joining_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.old_joining_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.gross_salary
        current_row_style << row_format
        current_row_type << :float

        current_row_value << ReportFormat.boolean_in_text(employee.on_probation)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.gross_salary
        current_row_style << row_format
        current_row_type << :float

        current_row_value << employee.line_manager_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.employee_current_experince(employee)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.employee_qualification_program_name(employee)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.employee_qualification_year(employee)
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << ReportFormat.employee_qualification_institute_name(employee)
        current_row_style << row_format
        current_row_type << :string

        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
      file_name = "joiner_detail_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    end
  end

  def probation_detail
    @show_salary    = User.show_salary(current_user)
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :excluded_from_reports => false).order('id DESC')
    @company = Company.find (params[:company_id])
    if params[:location_ids].blank?
      location_ids = []
    else
      location_ids = params[:location_ids].map(&:to_i)
    end

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :excluded_from_reports => false).order('id DESC')
      end
    end
    #################### Hierarchical Permission ####################

    @employees = Employee.multiple_branch_data(@employees, current_user)

    if location_ids.count > 0
      @employees = @employees.where(:location_id => location_ids).order('id DESC')
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end

    @employees = Employee.where(:id => @employees.collect(&:id), :confirmation_date => nil, :on_probation => true, :is_active => true, :is_contractual => false).where('confimration_due_date <= ?', params[:selected_date].to_date)

    if params[:report_type].to_i == 1
      render status:200, template: 'api/v1/web/reports/employee_reports/probation_detail.json.jbuilder'
    elsif params[:report_type].to_i == 2
      time = Time.now
      url_path = ""
      check_directory("#{Rails.public_path}/pdf")
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/web/reports/employee_reports/probation_detail.pdf.erb"),
        footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
        :margin => {
          :top      => '0.1in',
          :bottom   => '0.1in',
          :left     => '0.1in',
          :right    => '0.1in'
        },
        dpi: 300,
        orientation: 'Landscape'
      )
      file_name = "view_activity_stream"
      url_path = save_pdf_file(pdf, file_name)

      render json: {message: "Pdf Created", path: url_path}
    elsif params[:report_type].to_i == 3
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Probation Detail')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Emp Code", "Name", "Location", "Branch", "Department", "Grade", "Designation", "Job Title", "DOJ", "Confirmation Due Date", "Line Manager"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')

      Array.new(11).each_index do |index|
        sheet.column_info[index].width = 20
      end

      count = 0
      @employees.each do |employee|
        count = count + 1
        row_format = old_row_format

        if count.even? == true
          row_format = even_row_format
        else
          row_format = old_row_format
        end

        current_row_value = []
        current_row_style = []
        current_row_type = []

        current_row_value << count
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.employee_code.to_i
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.full_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.location_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.branch_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.department_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.grade_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.designation_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.job_title_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.joining_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.confimration_due_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.line_manager_name
        current_row_style << row_format
        current_row_type << :string

        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
      file_name = "probation_detail_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    end
  end

  def transfer_detail
    @show_salary    = User.show_salary(current_user)
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :excluded_from_reports => false).order('id DESC')
    @company = Company.find (params[:company_id])
    if params[:location_ids].blank?
      location_ids = []
    else
      location_ids = params[:location_ids].map(&:to_i)
    end

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :excluded_from_reports => false).order('id DESC')
      end
    end
    #################### Hierarchical Permission ####################

    @employees = Employee.multiple_branch_data(@employees, current_user)

    if location_ids.count > 0
      @employees = @employees.where(:location_id => location_ids).order('id DESC')
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end

    @employee_transactions = EmployeeTransactionHistory.where(:employee_id => @employees.collect(&:id), :transaction_date => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day, :transaction_type => "Transfer")

    if params[:report_type].to_i == 1
      render status:200, template: 'api/v1/web/reports/employee_reports/transfer_detail.json.jbuilder'
    elsif params[:report_type].to_i == 2
      time = Time.now
      url_path = ""
      check_directory("#{Rails.public_path}/pdf")
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/web/reports/employee_reports/transfer_detail.pdf.erb"),
        footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
        :margin => {
          :top      => '0.1in',
          :bottom   => '0.1in',
          :left     => '0.1in',
          :right    => '0.1in'
        },
        dpi: 300,
        orientation: 'Landscape'
      )
      file_name = "view_activity_stream"
      url_path = save_pdf_file(pdf, file_name)

      render json: {message: "Pdf Created", path: url_path}
    elsif params[:report_type].to_i == 3
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Transfer Detail')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Emp Code", "Name", "Location", "Branch", "Department", "Grade", "Designation", "Transaction Date", "Transfer Type", "From", "To"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')

      Array.new(12).each_index do |index|
        sheet.column_info[index].width = 20
      end

      count = 0
      @employee_transactions.each do |employee_transaction|
        count = count + 1
        row_format = old_row_format

        if count.even? == true
          row_format = even_row_format
        else
          row_format = old_row_format
        end

        current_row_value = []
        current_row_style = []
        current_row_type = []

        current_row_value << count
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee_transaction.employee.employee_code
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_transaction.employee.full_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_transaction.employee.location_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_transaction.employee.branch_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_transaction.employee.department_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_transaction.employee.grade_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_transaction.employee.designation_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee_transaction.transaction_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_transaction.transfer_type
        current_row_style << row_format
        current_row_type << :string

        if employee_transaction.transfer_type == "Branch"
          current_row_value << employee_transaction.prve_branch_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee_transaction.current_branch_name
          current_row_style << row_format
          current_row_type << :string
        elsif employee_transaction.transfer_type == "Department"
          current_row_value << employee_transaction.prve_department_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee_transaction.current_department_name
          current_row_style << row_format
          current_row_type << :string
        else
          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string
        end



        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
      file_name = "transfer_detail_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    elsif params[:report_type].to_i == 4
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Transfer Detail')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Salary Unit", "Location", "Employee Type", "Emp Code", "Name", "Father Name", "DOJ", "DOT", "Transfer Type (Unit/Inter Department)", "Transfer From", "Transfer To", "Effective Date of Transfer", "Reporting To", "Department", "Salary Before Tarnsfer", "Salay After Tarnsfer", "Designation Before Transfer", "Designation After Transfer"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')

      Array.new(12).each_index do |index|
        sheet.column_info[index].width = 20
      end

      count = 0
      @employee_transactions.each do |employee_transaction|
        count = count + 1
        row_format = old_row_format

        if count.even? == true
          row_format = even_row_format
        else
          row_format = old_row_format
        end

        current_row_value = []
        current_row_style = []
        current_row_type = []

        current_row_value << count
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee_transaction.employee.salary_unit_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_transaction.employee.location_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_transaction.employee.employee_type_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_transaction.employee.employee_code.to_i
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee_transaction.employee.full_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_transaction.employee.father_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee_transaction.employee.joining_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee_transaction.employee.old_joining_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_transaction.transfer_type
        current_row_style << row_format
        current_row_type << :string

        if employee_transaction.transfer_type == "Branch"
          current_row_value << employee_transaction.prve_branch_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee_transaction.current_branch_name
          current_row_style << row_format
          current_row_type << :string
        elsif employee_transaction.transfer_type == "Department"
          current_row_value << employee_transaction.prve_department_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee_transaction.current_department_name
          current_row_style << row_format
          current_row_type << :string
        else
          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string
        end

        current_row_value << ReportFormat.date_format(employee_transaction.transaction_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_transaction.employee.line_manager_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_transaction.employee.department_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_transaction.employee.gross_salary
        current_row_style << row_format
        current_row_type << :float

        current_row_value << employee_transaction.employee.gross_salary
        current_row_style << row_format
        current_row_type << :float

        current_row_value << employee_transaction.employee.designation_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_transaction.employee.designation_name
        current_row_style << row_format
        current_row_type << :string

        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
      file_name = "transfer_detail_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    end
  end

  def leaver_detail
    @show_salary    = User.show_salary(current_user)
    @employees = Employee.where(:company_id => params[:company_id], :excluded_from_reports => false).order('id DESC')
    @company = Company.find (params[:company_id])
    if params[:location_ids].blank?
      location_ids = []
    else
      location_ids = params[:location_ids].map(&:to_i)
    end

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :excluded_from_reports => false).order('id DESC')
      end
    end
    #################### Hierarchical Permission ####################

    @employees = Employee.multiple_branch_data_in_active(@employees, current_user)

    if location_ids.count > 0
      @employees = @employees.where(:location_id => location_ids).order('id DESC')
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end

    if params[:report_view] == "Struck Off"
      @employee_transactions = EmployeeTransactionHistory.where(:employee_id => @employees.collect(&:id), :transaction_date => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day, :transaction_type => "End of Employment", left_type: "Struck Off")
    else
      @employee_transactions = EmployeeTransactionHistory.where(:employee_id => @employees.where(is_active: false).collect(&:id), :transaction_date => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day, :transaction_type => "End of Employment").where.not(left_type: "Struck Off")
    end

    if params[:report_type].to_i == 1
      render status:200, template: 'api/v1/web/reports/employee_reports/leaver_detail.json.jbuilder'
    elsif params[:report_type].to_i == 2
      time = Time.now
      url_path = ""
      check_directory("#{Rails.public_path}/pdf")
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/web/reports/employee_reports/leaver_detail.pdf.erb"),
        footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
        :margin => {
          :top      => '0.1in',
          :bottom   => '0.1in',
          :left     => '0.1in',
          :right    => '0.1in'
        },
        dpi: 300,
        orientation: 'Landscape'
      )
      file_name = "view_activity_stream"
      url_path = save_pdf_file(pdf, file_name)

      render json: {message: "Pdf Created", path: url_path}
    elsif params[:report_type].to_i == 3
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      if params[:report_view] == "Struck Off"
        sheet = wb.add_worksheet(name: 'Struck Off Detail')
      else
        sheet = wb.add_worksheet(name: 'Leaver Detail')
      end
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
      date_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :format_code => 'yyyy-mm-dd', :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      if srl_instance? or dtl_instance?
        sheet.add_row ["Sr #", "Emp Code", "Salutation", "Name", "Father Name", "Gender", "Designation","Job Title","Location", "Branch", "Department", "Grade", "Employee Type", "Gross Salary", "Basic Salary", "DOJ", "Employment Status", params[:report_view] == "" ? "DOL" : "Struck Off Date","Resignation Date","Left Reason","DOB", "Age", "CNIC", "File Number"], :style => header_style
      else
        sheet.add_row ["Sr #", "Emp Code", "Salutation", "Name", "Father Name", "Gender", "Designation", "Location", "Branch", "Department", "Grade", "Employee Type", "Gross Salary", "Basic Salary", "DOJ", "Employment Status", params[:report_view] == "" ? "DOL" : "Struck Off Date", "DOB", "Age", "CNIC", "File Number"], :style => header_style
      end
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')

      Array.new(11).each_index do |index|
        sheet.column_info[index].width = 20
      end

      count = 0
      employees_ids = []
      @employee_transactions.each do |employee_transaction|
        if employees_ids.include?(employee_transaction.employee_id) == false
          employees_ids << employee_transaction.employee_id
          count = count + 1
          row_format = old_row_format

          if count.even? == true
            row_format = even_row_format
          else
            row_format = old_row_format
          end

          current_row_value = []
          current_row_style = []
          current_row_type = []

          current_row_value << count
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee_transaction.employee.employee_code.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee_transaction.employee.salutation
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee_transaction.employee.full_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee_transaction.employee.father_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee_transaction.employee.gender
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee_transaction.employee.designation_name
          current_row_style << row_format
          current_row_type << :string

          if srl_instance? or dtl_instance?
            current_row_value << employee_transaction.employee.job_title_name
            current_row_style << row_format
            current_row_type << :string
          end

          current_row_value << employee_transaction.employee.location_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee_transaction.employee.branch_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee_transaction.employee.department_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee_transaction.employee.grade_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee_transaction.employee.employee_type_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << (employee_transaction.employee.gross_salary.to_f).round
          current_row_style << row_format
          current_row_type << :float

          current_row_value << (employee_transaction.employee.gross_salary * 0.67).round
          current_row_style << row_format
          current_row_type << :float

          current_row_value << employee_transaction.employee.joining_date.to_date
          current_row_style << date_format
          current_row_type << :date

          current_row_value << ReportFormat.boolean_in_text_as_confirmed(employee_transaction.employee.on_probation)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee_transaction.transaction_date.to_date
          current_row_style << date_format
          current_row_type << :date

          if srl_instance? or dtl_instance?
            current_row_value << employee_transaction.resign_date
            current_row_style << date_format
            current_row_type << :date

            current_row_value << employee_transaction.left_reason
            current_row_style << row_format
            current_row_type << :string
          end

          current_row_value << ReportFormat.date_format(employee_transaction.employee.date_of_birth)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.employee_age(employee_transaction.employee.date_of_birth)
          current_row_style << row_format
          current_row_type << :float

          current_row_value << ReportFormat.cnic_format(employee_transaction.employee.cnic_number)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.non_text_to_dash(employee_transaction.employee.file_number)
          current_row_style << row_format
          current_row_type << :string

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
        end
      end
      if params[:report_view] == "Struck Off"
        file_name = "struck_off_detail_report"
      else
        file_name = "leaver_detail_report"
      end
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    end
  end

  def benefit_detail
    @show_salary    = User.show_salary(current_user)
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :excluded_from_reports => false).order('id DESC')
    @company = Company.find (params[:company_id])
    if params[:location_ids].blank?
      location_ids = []
    else
      location_ids = params[:location_ids].map(&:to_i)
    end

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :excluded_from_reports => false).order('id DESC')
      end
    end
    #################### Hierarchical Permission ####################

    if location_ids.count > 0
      @employees = @employees.where(:location_id => location_ids).order('id DESC')
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end
    @employees = Employee.multiple_branch_data(@employees, current_user)
    if params[:report_type].to_i == 1
      render status:200, template: 'api/v1/web/reports/employee_reports/benefit_detail.json.jbuilder'
    elsif params[:report_type].to_i == 3
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Benefits Entitlement')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Emp Code", "Name", "Department", "Designation", "Social Security", "Group Life Insurance", "Health Insurance", "Cellphone Bill", "Fuel Reimbursement", "Cell Phone", "Laptop", "Vehicle", "Provident Fund", "EOBI", "Gratuity", "House Allowance", "LFA", "Vehicle Allowance", "Maintenance", "Travel Allowance", "Eid-ul-fitr Bonus", "Eid-ul-Azha Bonus", "Annual Bonus"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      Array.new(11).each_index do |index|
        sheet.column_info[index].width = 20
      end
      count = 0
      grades_ids = @employees.collect(&:grade_id).uniq
      Grade.where(:id => grades_ids).order('sort_order DESC').each do |grade|
        @employees.where(:grade_id => grade.id).order('employee_code ASC').each do |employee|
          count = count + 1
          row_format = old_row_format

          if count.even? == true
            row_format = even_row_format
          else
            row_format = old_row_format
          end

          current_row_value = []
          current_row_style = []
          current_row_type = []

          current_row_value << count
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee.employee_code.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee.full_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.department_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.designation_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.social_security_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.life_insurance_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.health_insurance_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.cell_phone_bill_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.fuel_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.cell_phone_bill_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.laptop_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.velicle_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.provident_fund_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.eobi_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.gratuity_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.house_allowance_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.lfa_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.vehicle_allowance_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.maintenance_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.travel_allowance_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.bonus1_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.bonus2_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee.bonus3_allowed)
          current_row_style << row_format
          current_row_type << :string

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

        end
      end

      file_name = "benefit_detail_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    end
  end

  def health_insurance_report
    is_active = true
    if params[:is_active] == "Active"
      is_active = true
    else
      is_active = false
    end

    @show_salary    = User.show_salary(current_user)
    @employees = Employee.where(:company_id => params[:company_id], :is_active => is_active).order('id DESC')
    @company = Company.find (params[:company_id])
    if params[:location_ids].blank?
      location_ids = []
    else
      location_ids = params[:location_ids].map(&:to_i)
    end

    @location_name = ""
    @branch_name = ""
    @department_name = ""
    @grade_name = ""
    @salary_unit_name = ""

    #################### Hierarchical Permission ####################
    if current_user.is_admin == true
      @employees = Employee.where(:company_id => params[:company_id], :is_active => is_active).order('id DESC')
    elsif current_user.is_company_head == true
      @employees = Employee.where(:company_id => params[:company_id], :is_active => is_active).order('id DESC')
    elsif current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => is_active).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => is_active).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => is_active).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => is_active).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => is_active).order('id DESC')
      end
    end
    #################### Hierarchical Permission ####################

    if location_ids.count > 0
      @location_name = Location.where(:id => params[:location_ids]).collect(&:name).join(',')
      @employees = @employees.where(:location_id => location_ids).order('id DESC')
    end
    if not params[:branch_id].blank?
      @branch_name = Branch.find(params[:branch_id]).name
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @department_name = Department.find(params[:department_id]).name
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @salary_unit_name = SalaryUnit.find(params[:salary_unit_id]).name
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end

    if not (params[:start_date].blank? and params[:end_date].blank?)
      @employees = Employee.where(:id => @employees.collect(&:id), :joining_date => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day)
    else
      @employees = Employee.where(:id => @employees.collect(&:id))
    end

    @employees = @employees.where(:employee_type_id => params[:employee_type_ids].map(&:to_i)).health_insurance_employees

    if params[:report_type].to_i == 1
      render status:200, template: 'api/v1/web/reports/employee_reports/health_insurance.json.jbuilder'
    elsif params[:report_type].to_i == 2
      time = Time.now
      url_path = ""
      check_directory("#{Rails.public_path}/pdf")
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/web/reports/employee_reports/health_insurance.pdf.erb"),
        footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
        :margin => {
          :top      => '0.1in',
          :bottom   => '0.1in',
          :left     => '0.1in',
          :right    => '0.1in'
        },
        dpi: 400,
        page_size: "Legal",
        orientation: 'Landscape'
      )
      file_name = "health_insurance"
      url_path = save_pdf_file(pdf, file_name)

      render json: {message: "Pdf Created", path: url_path}
    elsif params[:report_type].to_i == 3
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Health Insurance')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Emp Code", "Name", "CNIC", "Insurance Credit Letter No.", "Category / Plan", "Date of Joining", "Date of Enrollment", "Date of Leaving", "Date of Birth", "Age", "Gender", "Relation", "Grade", "Designation", "Job Title", "Department", "Salary Unit", "Location Type", "Remarks"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      Array.new(11).each_index do |index|
        sheet.column_info[index].width = 20
      end
      count = 0
      grades_ids = @employees.collect(&:grade_id).uniq
      Grade.where(:id => grades_ids).order('sort_order DESC').each do |grade|
        @employees.where(:grade_id => grade.id).order('employee_code ASC').each do |employee|
          count = count + 1
          row_format = old_row_format

          if count.even? == true
            row_format = even_row_format
          else
            row_format = old_row_format
          end

          current_row_value = []
          current_row_style = []
          current_row_type = []

          current_row_value << count
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee.employee_code.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee.full_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.cnic_format(employee.cnic_number)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.insurance_report_date_format(employee.joining_date)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.insurance_report_date_format(employee.joining_date)
          current_row_style << row_format
          current_row_type << :string

          if employee.is_active == false
            employee_transaction_history = employee.employee_transaction_histories.where(:transaction_type => "End of Employment").last
            if employee_transaction_history.nil?
              current_row_value << "-"
              current_row_style << row_format
              current_row_type << :string
            else
              current_row_value << ReportFormat.insurance_report_date_format(employee_transaction_history.transaction_date)
              current_row_style << row_format
              current_row_type << :string
            end
          else
            current_row_value << "-"
            current_row_style << row_format
            current_row_type << :string
          end

          current_row_value << ReportFormat.insurance_report_date_format(employee.date_of_birth)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_of_birth_in_years(employee.date_of_birth)
          current_row_style << row_format
          current_row_type << :float

          current_row_value << employee.gender
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "Employee"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.grade_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.designation_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.job_title_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.department_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.salary_unit_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.location_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

          employee.employee_relatives.where(:is_dependent => true).order('id ASC').each do |employee_relative|

            count = count + 1

            current_row_value = []
            current_row_style = []
            current_row_type = []

            current_row_value << count
            current_row_style << row_format
            current_row_type << :integer

            current_row_value << "-"
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee_relative.relative_name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << ReportFormat.cnic_format(employee_relative.cnic_number)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << "-"
            current_row_style << row_format
            current_row_type << :string

            current_row_value << "-"
            current_row_style << row_format
            current_row_type << :string

            current_row_value << "-"
            current_row_style << row_format
            current_row_type << :string

            current_row_value << ReportFormat.insurance_report_date_format(employee_relative.date_of_enrollment)
            current_row_style << row_format
            current_row_type << :string

            if employee.is_active == false
              employee_transaction_history = employee.employee_transaction_histories.where(:transaction_type => "End of Employment").last
              if employee_transaction_history.nil?
                current_row_value << "-"
                current_row_style << row_format
                current_row_type << :string
              else
                current_row_value << ReportFormat.insurance_report_date_format(employee_transaction_history.transaction_date)
                current_row_style << row_format
                current_row_type << :string
              end
            else
              current_row_value << "-"
              current_row_style << row_format
              current_row_type << :string
            end
            current_row_value << ReportFormat.insurance_report_date_format(employee_relative.date_of_birth)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << ReportFormat.date_of_birth_in_years(employee_relative.date_of_birth)
            current_row_style << row_format
            current_row_type << :float

            current_row_value << employee_relative.gender
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee_relative.relationship_name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << "-"
            current_row_style << row_format
            current_row_type << :string

            current_row_value << "-"
            current_row_style << row_format
            current_row_type << :string

            current_row_value << "-"
            current_row_style << row_format
            current_row_type << :string

            current_row_value << "-"
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee.salary_unit_name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << employee.location_name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << "-"
            current_row_style << row_format
            current_row_type << :string

            sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
          end
        end
      end

      file_name = "health_insurance_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    elsif params[:report_type].to_i == 4
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Health Insurance')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["CER No.", "Insured's Name", "Age", "Designation/Relation", "Date of Birth", "Plan"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      Array.new(6).each_index do |index|
        sheet.column_info[index].width = 20
      end
      count = 0
      grades_ids = @employees.collect(&:grade_id).uniq
      Grade.where(:id => grades_ids).order('sort_order DESC').each do |grade|
        @employees.where(:grade_id => grade.id).order('employee_code ASC').each do |employee|
          count = count + 1
          row_format = old_row_format

          if count.even? == true
            row_format = even_row_format
          else
            row_format = old_row_format
          end

          current_row_value = []
          current_row_style = []
          current_row_type = []

          current_row_value << count
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee.full_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_of_birth_in_years(employee.date_of_birth).to_f
          current_row_style << row_format
          current_row_type << :float

          current_row_value << employee.designation_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.insurance_report_date_format(employee.date_of_birth)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.health_insurance_plan
          current_row_style << row_format
          current_row_type << :string

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

          relative_count = 0

          employee.employee_relatives.where(:insurance_allowed => true).order('id ASC').each do |employee_relative|

            relative_count = relative_count + 1

            current_row_value = []
            current_row_style = []
            current_row_type = []

            if relative_count == 1
              current_row_value << employee.employee_code.to_i
              current_row_style << row_format
              current_row_type << :integer
            else
              current_row_value << ""
              current_row_style << row_format
              current_row_type << :string
            end

            current_row_value << employee_relative.relative_name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << ReportFormat.date_of_birth_in_years(employee_relative.date_of_birth).to_f
            current_row_style << row_format
            current_row_type << :float

            current_row_value << employee_relative.relationship_name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << ReportFormat.insurance_report_date_format(employee_relative.date_of_birth)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << ""
            current_row_style << row_format
            current_row_type << :string

            sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
          end

          current_row_value = []
          current_row_style = []
          current_row_type = []

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "Total Family Premium (Rs.):"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

        end
      end

      file_name = "health_insurance_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    end
  end

  def employee_bank_detail
    @show_salary    = User.show_salary(current_user)
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    @company = Company.find (params[:company_id])
    if params[:location_ids].blank?
      location_ids = []
    else
      location_ids = params[:location_ids].map(&:to_i)
    end

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
      end
    end
    #################### Hierarchical Permission ####################

    if location_ids.count > 0
      @employees = @employees.where(:location_id => location_ids).order('id DESC')
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end

    if not (params[:start_date].blank? and params[:end_date].blank?)
      @employees = Employee.where(:id => @employees.collect(&:id), :joining_date => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day)
    else
      @employees = Employee.where(:id => @employees.collect(&:id))
    end

    if params[:report_type].to_i == 1
      render status:200, template: 'api/v1/web/reports/employee_reports/employee_bank_detail.json.jbuilder'
    elsif params[:report_type].to_i == 2
      time = Time.now
      url_path = ""
      check_directory("#{Rails.public_path}/pdf")
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/web/reports/employee_reports/employee_bank_detail.pdf.erb"),
        footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
        :margin => {
          :top      => '0.1in',
          :bottom   => '0.1in',
          :left     => '0.1in',
          :right    => '0.1in'
        },
        dpi: 300,
        orientation: 'Landscape'
      )
      file_name = "employee_bank_detail"
      url_path = save_pdf_file(pdf, file_name)

      render json: {message: "Pdf Created", path: url_path}
    elsif params[:report_type].to_i == 3
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Bank Account Detail')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Emp Code", "Name", "Department", "Designation", "Bank Name", "Branch Name", "Account Title", "Account #"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      Array.new(8).each_index do |index|
        sheet.column_info[index].width = 20
      end
      count = 0
      @employees.each do |employee|
        count = count + 1
        row_format = old_row_format

        if count.even? == true
          row_format = even_row_format
        else
          row_format = old_row_format
        end

        current_row_value = []
        current_row_style = []
        current_row_type = []

        current_row_value << count
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.employee_code.to_i
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.full_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.department_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.designation_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.bank_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.bank_branch_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.bank_account_title
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.bank_account_number
        current_row_style << row_format
        current_row_type << :string

        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
      file_name = "employee_bank_detail_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    end
  end

  def employee_contact_detail
    @show_salary    = User.show_salary(current_user)
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    @company = Company.find (params[:company_id])
    if params[:location_ids].blank?
      location_ids = []
    else
      location_ids = params[:location_ids].map(&:to_i)
    end

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
      end
    end
    #################### Hierarchical Permission ####################

    if location_ids.count > 0
      @employees = @employees.where(:location_id => location_ids).order('id DESC')
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end

    if not (params[:start_date].blank? and params[:end_date].blank?)
      @employees = Employee.where(:id => @employees.collect(&:id), :joining_date => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day)
    else
      @employees = Employee.where(:id => @employees.collect(&:id))
    end

    if params[:report_type].to_i == 1
      render status:200, template: 'api/v1/web/reports/employee_reports/employee_contact_detail.json.jbuilder'
    elsif params[:report_type].to_i == 2
      time = Time.now
      url_path = ""
      check_directory("#{Rails.public_path}/pdf")
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/web/reports/employee_reports/employee_contact_detail.pdf.erb"),
        footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
        :margin => {
          :top      => '0.1in',
          :bottom   => '0.1in',
          :left     => '0.1in',
          :right    => '0.1in'
        },
        dpi: 300,
        orientation: 'Landscape'
      )
      file_name = "employee_contact_detail"
      url_path = save_pdf_file(pdf, file_name)

      render json: {message: "Pdf Created", path: url_path}
    elsif params[:report_type].to_i == 3
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Employee Contact Detail')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Emp Code", "Name", "Official Email Address", "Official Mobile No.", "Personal Email address", "Personal Mobile No.", "Present Address", "Permanent Address", "Emergency Contact Name", "Emergency Contact Email", "Emergency Contact No.", "Emergency Contact Relation"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      Array.new(11).each_index do |index|
        sheet.column_info[index].width = 20
      end
      count = 0
      @employees.each do |employee|
        count = count + 1
        row_format = old_row_format

        if count.even? == true
          row_format = even_row_format
        else
          row_format = old_row_format
        end

        current_row_value = []
        current_row_style = []
        current_row_type = []

        current_row_value << count
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.employee_code.to_i
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.full_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.official_email
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.official_mobile_number
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.personal_email
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.personal_number
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.current_address
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.permanent_address
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.emergency_contact_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.emergency_contact_email
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.emergency_contact_phone
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.relationship_name
        current_row_style << row_format
        current_row_type << :string

        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
      file_name = "employee_contact_detail_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    elsif params[:report_type].to_i == 4
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Emergency Contact')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Salary Unit", "Location", "Emp Code", "Name", "Department", "Designation", "Emergency Contact Name", "Emergency Contact Relation", "Emergency Contact Phone"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')

      count = 0
      @employees.each do |employee|
        count = count + 1
        row_format = old_row_format

        if count.even? == true
          row_format = even_row_format
        else
          row_format = old_row_format
        end

        current_row_value = []
        current_row_style = []
        current_row_type = []

        current_row_value << count
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.salary_unit_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.location_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.employee_code.to_i
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.full_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.department_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.designation_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.emergency_contact_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.relationship_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.emergency_contact_phone
        current_row_style << row_format
        current_row_type << :string

        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
      file_name = "employee_contact_detail_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    end
  end

  def employee_reference_detail
    @show_salary    = User.show_salary(current_user)
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    @company = Company.find (params[:company_id])
    if params[:location_ids].blank?
      location_ids = []
    else
      location_ids = params[:location_ids].map(&:to_i)
    end

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
      end
    end
    #################### Hierarchical Permission ####################

    if location_ids.count > 0
      @employees = @employees.where(:location_id => location_ids).order('id DESC')
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end

    if not (params[:start_date].blank? and params[:end_date].blank?)
      @employees = Employee.where(:id => @employees.collect(&:id), :joining_date => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day)
    else
      @employees = Employee.where(:id => @employees.collect(&:id))
    end

    @employee_references = EmployeeReference.where(:employee_id => @employees.collect(&:id))

    if params[:report_type].to_i == 1
      render status:200, template: 'api/v1/web/reports/employee_reports/employee_reference_detail.json.jbuilder'
    elsif params[:report_type].to_i == 3
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Employee Reference Detail')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Emp Code", "Name", "Reference Type", "Name", "Email", "Contact Number", "Organization", "Designation", "Address"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      Array.new(10).each_index do |index|
        sheet.column_info[index].width = 20
      end
      count = 0
      @employee_references.order('employee_id ASC').each do |employee_reference|
        count = count + 1
        row_format = old_row_format

        if count.even? == true
          row_format = even_row_format
        else
          row_format = old_row_format
        end

        current_row_value = []
        current_row_style = []
        current_row_type = []

        current_row_value << count
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee_reference.employee_code.to_i
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee_reference.employee_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_reference.reference_type
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_reference.name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_reference.email
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.phone_format(employee_reference.contact_number)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_reference.organization
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_reference.designation
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_reference.address
        current_row_style << row_format
        current_row_type << :string

        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
      file_name = "employee_reference_detail_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    end
  end

  def employee_next_of_kin_detail
    @show_salary    = User.show_salary(current_user)
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    @company = Company.find (params[:company_id])
    if params[:location_ids].blank?
      location_ids = []
    else
      location_ids = params[:location_ids].map(&:to_i)
    end

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
      end
    end
    #################### Hierarchical Permission ####################

    if location_ids.count > 0
      @employees = @employees.where(:location_id => location_ids).order('id DESC')
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end

    if not (params[:start_date].blank? and params[:end_date].blank?)
      @employees = Employee.where(:id => @employees.collect(&:id), :joining_date => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day)
    else
      @employees = Employee.where(:id => @employees.collect(&:id))
    end

    @employee_next_of_kins = EmployeeNextOfKin.where(:employee_id => @employees.collect(&:id))

    if params[:report_type].to_i == 1
      render status:200, template: 'api/v1/web/reports/employee_reports/employee_next_of_kin_detail.json.jbuilder'
    elsif params[:report_type].to_i == 3
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Employee Next of Kin Detail')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Emp Code", "Name", "Relative Name", "Relationship Name", "Guardian Name", "Relative Age", "Percentage"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      Array.new(8).each_index do |index|
        sheet.column_info[index].width = 20
      end
      count = 0
      @employee_next_of_kins.order('employee_id ASC').each do |employee_next_of_kin|
        count = count + 1
        row_format = old_row_format

        if count.even? == true
          row_format = even_row_format
        else
          row_format = old_row_format
        end

        current_row_value = []
        current_row_style = []
        current_row_type = []

        current_row_value << count
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee_next_of_kin.employee_code.to_i
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee_next_of_kin.employee_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_next_of_kin.employee_relative_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_next_of_kin.relationship_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_next_of_kin.guardian_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_next_of_kin.relative_age
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_next_of_kin.percentage
        current_row_style << row_format
        current_row_type << :string


        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
      file_name = "employee_next_of_kin_detail_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    end
  end

  def employee_relative_detail
    @show_salary    = User.show_salary(current_user)
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    @company = Company.find (params[:company_id])
    if params[:location_ids].blank?
      location_ids = []
    else
      location_ids = params[:location_ids].map(&:to_i)
    end

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
      end
    end
    #################### Hierarchical Permission ####################

    if location_ids.count > 0
      @employees = @employees.where(:location_id => location_ids).order('id DESC')
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end

    if not (params[:start_date].blank? and params[:end_date].blank?)
      @employees = Employee.where(:id => @employees.collect(&:id), :joining_date => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day)
    else
      @employees = Employee.where(:id => @employees.collect(&:id))
    end

    @employee_relatives = EmployeeRelative.where(:employee_id => @employees.collect(&:id))
    if srl_instance? or dtl_instance?
      if params[:report_type].to_i == 1
        render status:200, template: 'api/v1/web/reports/employee_reports/employee_relative_detail.json.jbuilder'
      elsif params[:report_type].to_i == 3
        srl_employee_relative
      end
    else
      if params[:report_type].to_i == 1
        render status:200, template: 'api/v1/web/reports/employee_reports/employee_relative_detail.json.jbuilder'
      elsif params[:report_type].to_i == 3
        time = Time.now
        book = Axlsx::Package.new
        check_directory("#{Rails.public_path}/excel")
        wb = book.workbook
        sheet = wb.add_worksheet(name: 'Employee Relative Detail')
        book.use_autowidth = false
        sheet.sheet_view do |view|
          view.show_outline_symbols = true
        end
        book.use_autowidth = true
        header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
        bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
        cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

        sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
        sheet.add_row ['']
        sheet.add_row ['']
        sheet.add_row ['']
        sheet.add_row ['']

        sheet.add_row ["Sr #", "Emp Code", "Name", "Relative Name", "Relationship Name", "Email", "Date of Birth", "Date of Enrollment", "Gender", "CNIC","Is Dependent", "Insurance Allowed","Same as Employee Current Address", "Same as Employee Permanent Address","Insurance Plan", "Address", "Relative Age"], :style => header_style
        old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
        even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
        Array.new(17).each_index do |index|
          sheet.column_info[index].width = 20
        end
        count = 0
        @employee_relatives.order('employee_id ASC').each do |employee_relative|
          count = count + 1
          row_format = old_row_format

          if count.even? == true
            row_format = even_row_format
          else
            row_format = old_row_format
          end

          current_row_value = []
          current_row_style = []
          current_row_type = []

          current_row_value << count
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee_relative.employee_code.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee_relative.employee_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee_relative.relative_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee_relative.relationship_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee_relative.email
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(employee_relative.date_of_birth)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(employee_relative.date_of_enrollment)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee_relative.gender
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.cnic_format(employee_relative.cnic_number)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee_relative.is_dependent)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee_relative.insurance_allowed)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee_relative.same_as_employee_address)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text(employee_relative.same_as_employee_address)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee_relative.employee.health_insurance_plan
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee_relative.address
          current_row_style << row_format
          current_row_type << :string

          if employee_relative.date_of_birth.nil?
            current_row_value <<  0
            current_row_style << row_format
            current_row_type << :integer
          else
            current_row_value << Time.now.year - employee_relative.date_of_birth.year
            current_row_style << row_format
            current_row_type << :integer
          end
          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
        end
        file_name = "employee_relative_detail_report"
        url_path = save_excel_file(book, file_name)
        render json: {message: "Excel Created", path: url_path}
      end
    end
  end

  def employee_qualification_detail
    @show_salary    = User.show_salary(current_user)
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    @company = Company.find (params[:company_id])
    if params[:location_ids].blank?
      location_ids = []
    else
      location_ids = params[:location_ids].map(&:to_i)
    end

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
      end
    end
    #################### Hierarchical Permission ####################

    if location_ids.count > 0
      @employees = @employees.where(:location_id => location_ids).order('id DESC')
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end

    if not (params[:start_date].blank? and params[:end_date].blank?)
      @employees = Employee.where(:id => @employees.collect(&:id), :joining_date => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day)
    else
      @employees = Employee.where(:id => @employees.collect(&:id))
    end

    @employee_qualifications = EmployeeQualification.where(:employee_id => @employees.collect(&:id))

    if params[:report_type].to_i == 1
      render status:200, template: 'api/v1/web/reports/employee_reports/employee_qualification_detail.json.jbuilder'
    elsif params[:report_type].to_i == 3
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Employee Qualification Detail')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Emp Code", "Name", "Institute Name", "Qualification Level", "Program Name", "Specialization Name", "Status", "Start Date", "End Date", "Achievement"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      Array.new(11).each_index do |index|
        sheet.column_info[index].width = 20
      end
      count = 0
      @employee_qualifications.order('employee_id ASC').each do |employee_qualification|
        count = count + 1
        row_format = old_row_format

        if count.even? == true
          row_format = even_row_format
        else
          row_format = old_row_format
        end

        current_row_value = []
        current_row_style = []
        current_row_type = []

        current_row_value << count
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee_qualification.employee_code.to_i
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee_qualification.employee_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee_qualification.institute_name)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee_qualification.qualification_level)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee_qualification.program_name)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee_qualification.specialization_name)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee_qualification.status)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_only_year(employee_qualification.start_date)
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << ReportFormat.date_only_year(employee_qualification.end_date)
        current_row_style << row_format
        current_row_type << :integer

        if employee_qualification.status == "Grade" or employee_qualification.status == "Pass/Fail" or employee_qualification.status == "Division"
          current_row_value <<  ReportFormat.non_text_to_dash(employee_qualification.status_text)
          current_row_style << row_format
          current_row_type << :string
        elsif employee_qualification.status == "GPA" or employee_qualification.status == "Percentage"
          current_row_value <<  ReportFormat.non_float_to_dash(employee_qualification.gpa_or_percentage)
          current_row_style << row_format
          current_row_type << :float
        else
          current_row_value <<  "-"
          current_row_style << row_format
          current_row_type << :string
        end

        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
      file_name = "employee_qualification_detail_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    end
  end

  def employee_last_qualification_detail
    @show_salary    = User.show_salary(current_user)
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    @company = Company.find (params[:company_id])
    if params[:location_ids].blank?
      location_ids = []
    else
      location_ids = params[:location_ids].map(&:to_i)
    end

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
      end
    end
    #################### Hierarchical Permission ####################

    if location_ids.count > 0
      @employees = @employees.where(:location_id => location_ids).order('id DESC')
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end

    if not (params[:start_date].blank? and params[:end_date].blank?)
      @employees = Employee.where(:id => @employees.collect(&:id), :joining_date => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day)
    else
      @employees = Employee.where(:id => @employees.collect(&:id))
    end

    @employee_qualifications = EmployeeQualification.where(:employee_id => @employees.collect(&:id))

    if params[:report_type].to_i == 1
      render status:200, template: 'api/v1/web/reports/employee_reports/employee_last_qualification_detail.json.jbuilder'
    elsif params[:report_type].to_i == 3
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Employee Qualification Detail')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Emp Code", "Name", "Institute Name", "Qualification Level", "Program Name", "Specialization Name", "Status", "Start Date", "End Date", "Achievement"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      Array.new(11).each_index do |index|
        sheet.column_info[index].width = 20
      end
      count = 0
      @employees.each do |employee|
        if @employee_qualifications.where(:employee_id => employee.id).count > 0
          employee_qualification = @employee_qualifications.where(:employee_id => employee.id).first
          count = count + 1
          row_format = old_row_format

          if count.even? == true
            row_format = even_row_format
          else
            row_format = old_row_format
          end

          current_row_value = []
          current_row_style = []
          current_row_type = []

          current_row_value << count
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee_qualification.employee_code.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee_qualification.employee_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.non_text_to_dash(employee_qualification.institute_name)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.non_text_to_dash(employee_qualification.qualification_level)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.non_text_to_dash(employee_qualification.program_name)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.non_text_to_dash(employee_qualification.specialization_name)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.non_text_to_dash(employee_qualification.status)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_only_year(employee_qualification.start_date)
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << ReportFormat.date_only_year(employee_qualification.end_date)
          current_row_style << row_format
          current_row_type << :integer

          if employee_qualification.status == "Grade" or employee_qualification.status == "Pass/Fail" or employee_qualification.status == "Division"
            current_row_value <<  ReportFormat.non_text_to_dash(employee_qualification.status_text)
            current_row_style << row_format
            current_row_type << :string
          elsif employee_qualification.status == "GPA" or employee_qualification.status == "Percentage"
            current_row_value <<  ReportFormat.non_float_to_dash(employee_qualification.gpa_or_percentage)
            current_row_style << row_format
            current_row_type << :float
          else
            current_row_value <<  "-"
            current_row_style << row_format
            current_row_type << :string
          end

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
        end
      end
      file_name = "employee_last_qualification_detail_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    end
  end

  def employee_experience_detail
    @show_salary    = User.show_salary(current_user)
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    @company = Company.find (params[:company_id])
    if params[:location_ids].blank?
      location_ids = []
    else
      location_ids = params[:location_ids].map(&:to_i)
    end

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
      end
    end
    #################### Hierarchical Permission ####################

    if location_ids.count > 0
      @employees = @employees.where(:location_id => location_ids).order('id DESC')
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end

    if not (params[:start_date].blank? and params[:end_date].blank?)
      @employees = Employee.where(:id => @employees.collect(&:id), :joining_date => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day)
    else
      @employees = Employee.where(:id => @employees.collect(&:id))
    end

    @employee_experiences = EmployeeExperience.where(:employee_id => @employees.collect(&:id))
    @employee_membership = EmployeeMembership.where(:employee_id => @employees.collect(&:id))

    if srl_instance? or dtl_instance?
      if params[:report_type].to_i == 1
        render status:200, template: 'api/v1/web/reports/employee_reports/employee_experience_detail.json.jbuilder'
      elsif params[:report_type].to_i == 3
        srl_employee_experience_report
      elsif params[:report_type].to_i == 4
        srl_employee_membership
      end
    else
      if params[:report_type].to_i == 1
        render status:200, template: 'api/v1/web/reports/employee_reports/employee_experience_detail.json.jbuilder'
      elsif params[:report_type].to_i == 3
        time = Time.now
        book = Axlsx::Package.new
        check_directory("#{Rails.public_path}/excel")
        wb = book.workbook
        sheet = wb.add_worksheet(name: 'Employee Experience Detail')
        book.use_autowidth = false
        sheet.sheet_view do |view|
          view.show_outline_symbols = true
        end
        book.use_autowidth = true
        header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
        bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
        cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

        sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
        sheet.add_row ['']
        sheet.add_row ['']
        sheet.add_row ['']
        sheet.add_row ['']

        sheet.add_row ["Sr #", "Emp Code", "Name", "Organization","Left Reason", "Salary", "Start Date", "End Date", "Total Previous Experince"], :style => header_style
        old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
        even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
        Array.new(9).each_index do |index|
          sheet.column_info[index].width = 20
        end
        count = 0
        @employee_experiences.order('employee_id ASC').each do |employee_experience|
          count = count + 1
          row_format = old_row_format

          if count.even? == true
            row_format = even_row_format
          else
            row_format = old_row_format
          end

          current_row_value = []
          current_row_style = []
          current_row_type = []

          current_row_value << count
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee_experience.employee_code.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee_experience.employee_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.non_text_to_dash(employee_experience.organization)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.non_text_to_dash(employee_experience.job_title)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.non_text_to_dash(employee_experience.left_reason)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.non_float_to_dash(employee_experience.salary)
          current_row_style << row_format
          current_row_type << :float

          current_row_value << ReportFormat.date_format(employee_experience.start_date)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(employee_experience.end_date)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.employee_previous_experince_in_years(employee_experience.employee)
          current_row_style << row_format
          current_row_type << :string

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
        end
        file_name = "employee_experience_detail_report"
        url_path = save_excel_file(book, file_name)
        render json: {message: "Excel Created", path: url_path}
      end
    end
  end

  def employee_first_experience
    @show_salary    = User.show_salary(current_user)
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    @company = Company.find (params[:company_id])
    if params[:location_ids].blank?
      location_ids = []
    else
      location_ids = params[:location_ids].map(&:to_i)
    end

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
      end
    end
    #################### Hierarchical Permission ####################

    if location_ids.count > 0
      @employees = @employees.where(:location_id => location_ids).order('id DESC')
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end

    if not (params[:start_date].blank? and params[:end_date].blank?)
      @employees = Employee.where(:id => @employees.collect(&:id), :joining_date => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day)
    else
      @employees = Employee.where(:id => @employees.collect(&:id))
    end

    @employee_experiences = EmployeeExperience.where(:employee_id => @employees.collect(&:id))

    if params[:report_type].to_i == 1
      render status:200, template: 'api/v1/web/reports/employee_reports/employee_first_experience.json.jbuilder'
    elsif params[:report_type].to_i == 3
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Employee Experience Detail')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Emp Code", "Name", "Organization", "Job Title", "Left Reason", "Salary", "Start Date", "End Date", "Total Previous Experince"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      Array.new(10).each_index do |index|
        sheet.column_info[index].width = 20
      end
      count = 0
      @employees.each do |employee|
        if @employee_experiences.where(:employee_id => employee.id).count > 0
          employee_experience = @employee_experiences.where(:employee_id => employee.id).first
          count = count + 1
          row_format = old_row_format

          if count.even? == true
            row_format = even_row_format
          else
            row_format = old_row_format
          end

          current_row_value = []
          current_row_style = []
          current_row_type = []

          current_row_value << count
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee_experience.employee_code.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee_experience.employee_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.non_text_to_dash(employee_experience.organization)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.non_text_to_dash(employee_experience.job_title)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.non_text_to_dash(employee_experience.left_reason)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.non_float_to_dash(employee_experience.salary)
          current_row_style << row_format
          current_row_type << :float

          current_row_value << ReportFormat.date_format(employee_experience.start_date)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(employee_experience.end_date)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.employee_previous_experince_in_years(employee_experience.employee)
          current_row_style << row_format
          current_row_type << :string

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
        end
      end
      file_name = "employee_first_experience_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    end
  end

  def employee_last_experience
    @show_salary    = User.show_salary(current_user)
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    @company = Company.find (params[:company_id])
    if params[:location_ids].blank?
      location_ids = []
    else
      location_ids = params[:location_ids].map(&:to_i)
    end

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
      end
    end
    #################### Hierarchical Permission ####################

    if location_ids.count > 0
      @employees = @employees.where(:location_id => location_ids).order('id DESC')
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end

    if not (params[:start_date].blank? and params[:end_date].blank?)
      @employees = Employee.where(:id => @employees.collect(&:id), :joining_date => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day)
    else
      @employees = Employee.where(:id => @employees.collect(&:id))
    end

    @employee_experiences = EmployeeExperience.where(:employee_id => @employees.collect(&:id))

    if params[:report_type].to_i == 1
      render status:200, template: 'api/v1/web/reports/employee_reports/employee_last_experience.json.jbuilder'
    elsif params[:report_type].to_i == 3
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Employee Experience Detail')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Emp Code", "Name", "Organization", "Job Title", "Left Reason", "Salary", "Start Date", "End Date", "Total Previous Experince"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      Array.new(10).each_index do |index|
        sheet.column_info[index].width = 20
      end
      count = 0
      @employees.each do |employee|
        if @employee_experiences.where(:employee_id => employee.id).count > 0
          employee_experience = @employee_experiences.where(:employee_id => employee.id).last

          count = count + 1
          row_format = old_row_format

          if count.even? == true
            row_format = even_row_format
          else
            row_format = old_row_format
          end

          current_row_value = []
          current_row_style = []
          current_row_type = []

          current_row_value << count
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee_experience.employee_code.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee_experience.employee_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.non_text_to_dash(employee_experience.organization)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.non_text_to_dash(employee_experience.job_title)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.non_text_to_dash(employee_experience.left_reason)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.non_float_to_dash(employee_experience.salary)
          current_row_style << row_format
          current_row_type << :float

          current_row_value << ReportFormat.date_format(employee_experience.start_date)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(employee_experience.end_date)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.employee_previous_experince_in_years(employee_experience.employee)
          current_row_style << row_format
          current_row_type << :string

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
        end
      end
      file_name = "employee_last_experience_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    end
  end

  def employee_asset_detail
    @show_salary    = User.show_salary(current_user)
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    @company = Company.find (params[:company_id])
    if params[:location_ids].blank?
      location_ids = []
    else
      location_ids = params[:location_ids].map(&:to_i)
    end

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => true, :salary_exempted => false, :excluded_from_reports => false).order('id DESC')
      end
    end
    #################### Hierarchical Permission ####################

    if location_ids.count > 0
      @employees = @employees.where(:location_id => location_ids).order('id DESC')
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
    end
    if not params[:grade_id].blank?
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end

    if not (params[:start_date].blank? and params[:end_date].blank?)
      @employees = Employee.where(:id => @employees.collect(&:id), :joining_date => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day)
    else
      @employees = Employee.where(:id => @employees.collect(&:id))
    end

    if params[:report_type].to_i == 1
      render status:200, template: 'api/v1/web/reports/employee_reports/employee_asset_detail.json.jbuilder'
    elsif params[:report_type].to_i == 3
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Employee Asset Detail')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Emp Code", "Name", "Fuel Allowed", "Fuel Exception", "Fuel Eligibility", "Fuel Other Date", "Fuel Limit", "Fuel Value", "Cell Phone Allowed", "Cell Phone Exception", "Cell Phone Eligibility", "Cell Phone Other Date", "Cell Phone Assignment Date", "Cell Phone Age", "Cell Phone Name", "Cell Phone Model", "Cell Phone Entitlement Upto", "Laptop Allowed", "Laptop Exception", "Laptop Eligibility", "Laptop Other Date", "Laptop Vategory", "Laptop Assignment Date", "Laptop Age", "Laptop Name", "Laptop Model", "Laptop Value", "Vehicle Allowed", "Vehicle Exception", "Vehicle Eligibility", "Vehicle Other Date", "Vehicle Assignment Date", "Vehicle Age", "Vehicle Name", "Vehicle Model", "Vehicle Value", "2nd Vehicle Allowed", "2nd Vehicle Eligibility", "2nd Vehicle Other Date", "2nd Vehicle Assignment Date", "2nd Vehicle Age", "2nd Vehicle Name", "2nd Vehicle Model", "2nd Vehicle Value"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      Array.new(37).each_index do |index|
        sheet.column_info[index].width = 20
      end
      count = 0
      @employees.each do |employee|
        count = count + 1
        row_format = old_row_format

        if count.even? == true
          row_format = even_row_format
        else
          row_format = old_row_format
        end

        current_row_value = []
        current_row_style = []
        current_row_type = []

        current_row_value << count
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.employee_code.to_i
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.full_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.boolean_in_text_as_allowed(employee.fuel_allowed)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.boolean_in_text_as_allowed(employee.fuel_impact_allowed)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee.fuel_eligibility)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.fuel_other_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee.fuel_limit)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_float_to_dash(employee.fuel_value)
        current_row_style << row_format
        current_row_type << :float

        current_row_value << ReportFormat.boolean_in_text_as_allowed(employee.cell_phone_allowed)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.boolean_in_text_as_allowed(employee.cell_phone_impact_allowed)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee.cell_phone_eligibility)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.cell_phone_other_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.cell_assignment_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << "#{ReportFormat.employee_age(employee.cell_assignment_date)} years"
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee.cell_phone_name)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee.cell_phone_model)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_float_to_dash(employee.cell_phone_entitlement_upto)
        current_row_style << row_format
        current_row_type << :float

        current_row_value << ReportFormat.boolean_in_text_as_allowed(employee.laptop_allowed)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.boolean_in_text_as_allowed(employee.laptop_impact_allowed)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee.laptop_eligibility)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.laptop_other_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee.laptop_category)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.laptop_assignment_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << "#{ReportFormat.employee_age(employee.laptop_assignment_date)} years"
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee.laptop_name)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee.laptop_model)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_float_to_dash(employee.actual_laptop_value)
        current_row_style << row_format
        current_row_type << :float

        current_row_value << ReportFormat.boolean_in_text_as_allowed(employee.velicle_allowed)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.boolean_in_text_as_allowed(employee.velicle_impact_allowed)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee.velicle_eligibility)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.velicle_other_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.vehicle_assignment_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << "#{ReportFormat.employee_age(employee.vehicle_assignment_date)} years"
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee.vehicle_name)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee.vehicle_model)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_float_to_dash(employee.vehicle_value)
        current_row_style << row_format
        current_row_type << :float

        current_row_value << ReportFormat.boolean_in_text_as_allowed(employee.velicle_two_allowed)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee.velicle_two_eligibility)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.velicle_two_other_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.vehicle_two_assignment_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << "#{ReportFormat.employee_age(employee.vehicle_two_assignment_date)} years"
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee.vehicle_two_name)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee.vehicle_two_model)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_float_to_dash(employee.vehicle_two_value)
        current_row_style << row_format
        current_row_type << :float

        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
      file_name = "employee_asset_detail_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    elsif params[:report_type].to_i == 4
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Asset Detail Report')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Emp Code", "Name", "Department", "Designation", "Vehicle Name", "Vehicle Model", "Vehicle Assignment Date", "Vehicle Age", "Vehicle Value", "Motorbike Name", "Motorbike Model", "Motorbike Assignment Date", "Motorbike Age", "Motorbike Value", "Cell Phone Name", "Cell Phone Assignment Date", "Cell Phone Age", "Cell Phone Value", "Cell Phone Bill Limit", "Effective date of Cell Phone Bill"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')

      count = 0
      @employees.each do |employee|
        count = count + 1
        row_format = old_row_format

        if count.even? == true
          row_format = even_row_format
        else
          row_format = old_row_format
        end

        current_row_value = []
        current_row_style = []
        current_row_type = []

        current_row_value << count
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.employee_code.to_i
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.full_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.department_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.designation_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee.vehicle_name)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee.vehicle_model)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.vehicle_assignment_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << "#{ReportFormat.employee_age(employee.vehicle_assignment_date)} years"
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_float_to_dash(employee.vehicle_value)
        current_row_style << row_format
        current_row_type << :float

        current_row_value << "-"
        current_row_style << row_format
        current_row_type << :string

        current_row_value << "-"
        current_row_style << row_format
        current_row_type << :string

        current_row_value << "-"
        current_row_style << row_format
        current_row_type << :string

        current_row_value << "-"
        current_row_style << row_format
        current_row_type << :string

        current_row_value << "-"
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee.cell_phone_name)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee.cell_assignment_date)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << "#{ReportFormat.employee_age(employee.cell_assignment_date)} years"
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_text_to_dash(employee.cell_phone_bill_limit)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.non_float_to_dash(employee.cell_phone_bill_amount)
        current_row_style << row_format
        current_row_type << :float

        current_row_value << ReportFormat.date_format(employee.cell_phone_other_date)
        current_row_style << row_format
        current_row_type << :string

        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
      file_name = "employee_asset_detail_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    end
  end

  def cost_to_company
    if params[:company_id].present?
      @company = Company.find(params[:company_id])
      @employees = Employee.where(:company_id => params[:company_id], :is_active => true).order("department_id ASC")
      @year_wise_employees = []
      @year_wise_employees << Employee.where(:joining_date => ("1994-01-01".to_date).beginning_of_year..(Date.today).end_of_year, :company_id => params[:company_id])
      @year_wise_employees << Employee.where(:joining_date => ("1994-01-01".to_date).beginning_of_year..(Date.today - 1.year).end_of_year, :company_id => params[:company_id])
      @year_wise_employees << Employee.where(:joining_date => ("1994-01-01".to_date).beginning_of_year..(Date.today - 2.year).end_of_year, :company_id => params[:company_id])
    end
    if params[:location_ids].present?
      @employees = @employees.where(:location_id => params[:location_ids])
      @year_wise_employees = []
      @year_wise_employees << Employee.where(:joining_date => ("1994-01-01".to_date).beginning_of_year..(Date.today).end_of_year, :company_id => params[:company_id], :location_id => params[:location_ids])
      @year_wise_employees << Employee.where(:joining_date => ("1994-01-01".to_date).beginning_of_year..(Date.today - 1.year).end_of_year, :company_id => params[:company_id], :location_id => params[:location_ids])
      @year_wise_employees << Employee.where(:joining_date => ("1994-01-01".to_date).beginning_of_year..(Date.today - 2.year).end_of_year, :company_id => params[:company_id], :location_id => params[:location_ids])
    end
    if params[:department_id].present?
      @employees = @employees.where(:department_id => params[:department_id])
      @year_wise_employees = []
      @year_wise_employees << Employee.where(:joining_date => ("1994-01-01".to_date).beginning_of_year..(Date.today).end_of_year, :company_id => params[:company_id], :location_id => params[:location_ids], :department_id => params[:department_id])
      @year_wise_employees << Employee.where(:joining_date => ("1994-01-01".to_date).beginning_of_year..(Date.today - 1.year).end_of_year, :company_id => params[:company_id], :location_id => params[:location_ids], :department_id => params[:department_id])
      @year_wise_employees << Employee.where(:joining_date => ("1994-01-01".to_date).beginning_of_year..(Date.today - 2.year).end_of_year, :company_id => params[:company_id], :location_id => params[:location_ids], :department_id => params[:department_id])
    end
    if params[:sub_department_id].present?
      @employees = @employees.where(:sub_department_id => params[:sub_department_id])
      @year_wise_employees = []
      @year_wise_employees << Employee.where(:joining_date => ("1994-01-01".to_date).beginning_of_year..(Date.today).end_of_year, :company_id => params[:company_id], :location_id => params[:location_ids], :department_id => params[:department_id], :sub_department_id => params[:sub_department_id])
      @year_wise_employees << Employee.where(:joining_date => ("1994-01-01".to_date).beginning_of_year..(Date.today - 1.year).end_of_year, :company_id => params[:company_id], :location_id => params[:location_ids], :department_id => params[:department_id], :sub_department_id => params[:sub_department_id])
      @year_wise_employees << Employee.where(:joining_date => ("1994-01-01".to_date).beginning_of_year..(Date.today - 2.year).end_of_year, :company_id => params[:company_id], :location_id => params[:location_ids], :department_id => params[:department_id], :sub_department_id => params[:sub_department_id])
    end
    fuel_rate_item = PayitemExpression.where(:name => "Fuel Per Litre Price")
    if fuel_rate_item.present?
      fuel_rate = fuel_rate_item.last.expression_value.to_f
    else
      fuel_rate = 0.0
    end
    if params[:report_type].to_i == 2
      time = Time.now
      url_path = ""
      check_directory("#{Rails.public_path}/pdf")
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/web/reports/cost_to_company_reports/cost_to_company_report.pdf.erb"),
        footer: {content: render_to_string("api/v1/web/pdf_templates/footer.pdf.erb")},
        :margin => {
          :top      => '0.1in',
          :bottom   => '0.1in',
          :left     => '0.1in',
          :right    => '0.1in'
        },
        dpi: 300,
        orientation: 'Landscape'
      )
      file_name = "cost_to_company_list"
      url_path = save_pdf_file(pdf, file_name)

      render json: {message: "Pdf Created", path: url_path}
    elsif params[:report_type].to_i == 3
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Cost To Company Report')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      header_style1 = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Emp Code", "Emp Name", "Position Title", "location", "Department", "Line Manager","Sub Department", "Grade", "Date of Joining", "Basic Salary", "House Rent", "Utility", "Gross Salary", "OPD", "Fuel Liter", "Fuel Cost", "Travel Allowance", "Vehicle Allowance", "Performance Incentive", "Handset Allowance", "Maintenance Allowance", "Provident Fund", "Total CTC"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')

      count = 0
      grand_total_ctc = 0
      @employees.each do |employee|
        total_ctc = 0
        count = count + 1
        row_format = old_row_format

        if count.even? == true
          row_format = even_row_format
        else
          row_format = old_row_format
        end

        current_row_value = []
        current_row_style = []
        current_row_type = []

        current_row_value << count
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.employee_code.to_i
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << employee.full_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.job_title_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.location.name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.department_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.line_manager_name
        current_row_style << row_format
        current_row_type << :string

        if employee.sub_department_id.present?
          current_row_value << employee.sub_department.name
          current_row_style << row_format
          current_row_type << :string
        else
          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string
        end

        current_row_value << employee.grade.name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee.joining_date.to_date.strftime("%d-%B-%Y")
        current_row_style << row_format
        current_row_type << :string

        if employee.gross_salary > 0.0
          basic_salary = (employee.gross_salary*0.67).to_i
          house_rent = (basic_salary*0.45).to_i
          utility = (employee.gross_salary - basic_salary - house_rent).to_i

          current_row_value << basic_salary.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << house_rent.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << utility.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string
        else
          basic_salary = 0
          house_rent = 0
          utility = 0

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string
        end

        current_row_value << employee.gross_salary.to_i.to_s(:delimited)
        current_row_style << row_format
        current_row_type << :string

        if employee.department_name == "Retail Stores"
          opd = 0

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string
        else
          opd = (basic_salary*0.02).to_i

          current_row_value << opd.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string
        end

        if employee.fuel_allowed == true
          current_row_value << employee.fuel_value.to_i
          current_row_style << row_format
          current_row_type << :string
        else
          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string
        end

        if employee.fuel_allowed == true
          fuel_cost = (employee.fuel_value*fuel_rate).to_i

          current_row_value << fuel_cost.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string
        else
          fuel_cost = 0

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string
        end

        travel_allowance = FixedPayItem.where(:employee_id => employee.id, :pay_item_id => 14).last
        if travel_allowance.present?
          travel_allowance_value = travel_allowance.item_amount.to_i

          current_row_value << travel_allowance_value.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string
        else
          travel_allowance_value = 0

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string
        end

        vehicle_allowance = FixedPayItem.where(:employee_id => employee.id, :pay_item_id => 6).last
        if vehicle_allowance.present?
          vehicle_allowance_value = vehicle_allowance.item_amount.to_i

          current_row_value << vehicle_allowance_value.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string
        else
          vehicle_allowance_value = 0

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string
        end

        performance_incentive = FixedPayItem.where(:employee_id => employee.id, :pay_item_id => 19).last
        if performance_incentive.present?
          performance_incentive_value = performance_incentive.item_amount.to_i

          current_row_value << performance_incentive_value.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string
        else
          performance_incentive_value = 0

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string
        end

        if employee.cell_phone_allowed == true
          handset_allowance = (employee.cell_phone_entitlement_upto/24).to_i

          current_row_value << handset_allowance.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string
        else
          handset_allowance = 0

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string
        end

        maintenance_allowance = FixedPayItem.where(:pay_item_id => 27, :employee_id => employee.id).last
        if maintenance_allowance.present?
          maintenance_allowance_value = maintenance_allowance.item_amount.to_i

          current_row_value << maintenance_allowance_value.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string
        else
          maintenance_allowance_value = 0

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string
        end

        if employee.gross_salary > 0.0
          provident_fund = (basic_salary*0.0833).to_i

          current_row_value << provident_fund.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string
        else
          provident_fund = 0

          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string
        end

        if employee.gross_salary > 0.0
          total_ctc = (basic_salary.to_i + house_rent.to_i + utility.to_i + opd.to_i + fuel_cost.to_i + travel_allowance_value.to_i + vehicle_allowance_value.to_i + performance_incentive_value.to_i + handset_allowance.to_i + maintenance_allowance_value.to_i + provident_fund.to_i)

          current_row_value << total_ctc.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string
        else
          current_row_value << 0
          current_row_style << row_format
          current_row_type << :integer
        end

        grand_total_ctc = grand_total_ctc + total_ctc.to_i

        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
      sheet.add_row ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "Total CTC", "#{grand_total_ctc.to_s(:delimited)}"], :style => header_style1


      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Department Wise Summary')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      header_style1 = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')

      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ["", "", "", "", "", "", "", "", "", "Department Wise Summary", "", "", "", "", "", "", "", ""], :style => header_style
      sheet.add_row ["Sr #", "location", "Department", "Total Employees", "Basic Salary", "House Rent", "Utility", "Gross Salary", "OPD", "Fuel Liter", "Fuel Cost", "Travel Allowance", "Vehicle Allowance", "Performance Incentive", "Handset Allowance", "Maintenance Allowance", "Provident Fund", "Total CTC"], :style => header_style

      count = 0
      grand_total_ctc = 0
      @employees.pluck(:location_id).uniq.each do |location|
        location_employees = @employees.where(:location_id => location)
        location_employees.pluck(:department_id).uniq.each do |department|
          department_employees = location_employees.where(:department_id => department)
          total_basic_salary = 0
          total_house_rent = 0
          total_utility = 0
          total_gross_salary = 0
          total_opd = 0
          total_fuel_litter = 0
          total_travel_allowance = 0
          total_vehicle_allowance = 0
          total_performance_incentive = 0
          total_fuel_cost = 0
          total_provident_fund = 0
          total_handset_allowance = 0
          total_maintenance_allowance = 0
          total_ctc = 0
          department_employees.each do |emp|
            if emp.gross_salary > 0.0
              total_gross_salary = total_gross_salary + emp.gross_salary.to_i
              total_basic_salary = total_basic_salary + (emp.gross_salary * 0.67).to_i
              total_house_rent = total_house_rent + ((emp.gross_salary * 0.67).to_i * 0.45).to_i
              total_utility = total_utility + (emp.gross_salary - ((emp.gross_salary * 0.67).to_i) - (((emp.gross_salary * 0.67).to_i * 0.45).to_i)).to_i
              total_provident_fund = total_provident_fund + ((emp.gross_salary * 0.67).to_i * 0.0833).to_i
            end
            if emp.department_name != "Retail Stores"
              total_opd = total_opd + ((emp.gross_salary * 0.67).to_i * 0.02).to_i
            end
            if emp.fuel_allowed == true
              total_fuel_litter = total_fuel_litter + emp.fuel_value.to_i
              total_fuel_cost = total_fuel_cost + (emp.fuel_value * fuel_rate).to_i
            end

            travel_allowance = FixedPayItem.where(:employee_id => emp.id, :pay_item_id => 14).last
            if travel_allowance.present?
              total_travel_allowance = total_travel_allowance + travel_allowance.item_amount.to_i
            end

            vehicle_allowance = FixedPayItem.where(:employee_id => emp.id, :pay_item_id => 6).last
            if vehicle_allowance.present?
              total_vehicle_allowance = total_vehicle_allowance + vehicle_allowance.item_amount.to_i
            end

            performance_incentive = FixedPayItem.where(:employee_id => emp.id, :pay_item_id => 19).last
            if performance_incentive.present?
              total_performance_incentive = total_performance_incentive + performance_incentive.item_amount.to_i
            end

            if emp.cell_phone_allowed == true
              total_handset_allowance = total_handset_allowance + (emp.cell_phone_entitlement_upto/24).to_i
            end

            maintenance_allowance = FixedPayItem.where(:pay_item_id => 27, :employee_id => emp.id).last
            if maintenance_allowance.present?
              total_maintenance_allowance = total_maintenance_allowance + maintenance_allowance.item_amount.to_i
            end
          end
          total_ctc = total_maintenance_allowance + total_handset_allowance + total_performance_incentive + total_vehicle_allowance + total_travel_allowance + total_fuel_cost + total_opd + total_provident_fund + total_utility + total_house_rent + total_basic_salary
          count = count + 1
          row_format = old_row_format

          if count.even? == true
            row_format = even_row_format
          else
            row_format = old_row_format
          end

          current_row_value = []
          current_row_style = []
          current_row_type = []

          current_row_value << count
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << Location.find(location.to_i).name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << Department.find(department.to_i).name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << department_employees.count
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << total_basic_salary.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << total_house_rent.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << total_utility.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << total_gross_salary.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << total_opd.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << total_fuel_litter
          current_row_style << row_format
          current_row_type << :string

          current_row_value << total_fuel_cost.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << total_travel_allowance.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << total_vehicle_allowance.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << total_performance_incentive.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << total_handset_allowance.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << total_maintenance_allowance.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << total_provident_fund.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << total_ctc.to_s(:delimited)
          current_row_style << row_format
          current_row_type << :string

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
          grand_total_ctc = grand_total_ctc + total_ctc.to_i
        end
      end
      sheet.add_row ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "Total CTC", "#{grand_total_ctc.to_s(:delimited)}"], :style => header_style1


      # wb = book.workbook
      # sheet = wb.add_worksheet(name: 'Sub Department Wise Summary')
      # book.use_autowidth = false
      # sheet.sheet_view do |view|
      #   view.show_outline_symbols = true
      # end
      # book.use_autowidth = true
      # header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      # header_style1 = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      # bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      # cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
      #
      # old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      # even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')

      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ["", "", "", "", "", "", "", "", "", "Sub Department Wise Summary", "", "", "", "", "", "", "", "", ""], :style => header_style
      sheet.add_row ["Sr #", "location", "Department", "Sub Department", "Total Employees", "Basic Salary", "House Rent", "Utility", "Gross Salary", "OPD", "Fuel Liter", "Fuel Cost", "Travel Allowance", "Vehicle Allowance", "Performance Incentive", "Handset Allowance", "Maintenance Allowance", "Provident Fund", "Total CTC"], :style => header_style

      count = 0
      grand_total_ctc = 0
      @employees.pluck(:location_id).uniq.each do |location|
        location_employees = @employees.where(:location_id => location)
        location_employees.pluck(:department_id).uniq.each do |department|
          department_employees = location_employees.where(:department_id => department)
          department_employees.pluck(:sub_department_id).uniq.compact.each do |sub_department|
            sub_dept_employees = department_employees.where(:sub_department_id => sub_department)
            total_basic_salary = 0
            total_house_rent = 0
            total_utility = 0
            total_gross_salary = 0
            total_opd = 0
            total_fuel_litter = 0
            total_travel_allowance = 0
            total_vehicle_allowance = 0
            total_performance_incentive = 0
            total_fuel_cost = 0
            total_provident_fund = 0
            total_handset_allowance = 0
            total_maintenance_allowance = 0
            total_ctc = 0
            sub_dept_employees.each do |emp|
              if emp.gross_salary > 0.0
                total_gross_salary = total_gross_salary + emp.gross_salary.to_i
                total_basic_salary = total_basic_salary + (emp.gross_salary * 0.67).to_i
                total_house_rent = total_house_rent + ((emp.gross_salary * 0.67).to_i * 0.45).to_i
                total_utility = total_utility + (emp.gross_salary - ((emp.gross_salary * 0.67).to_i) - (((emp.gross_salary * 0.67).to_i * 0.45).to_i)).to_i
                total_provident_fund = total_provident_fund + ((emp.gross_salary * 0.67).to_i * 0.0833).to_i
              end
              if emp.department_name != "Retail Stores"
                total_opd = total_opd + ((emp.gross_salary * 0.67).to_i * 0.02).to_i
              end
              if emp.fuel_allowed == true
                total_fuel_litter = total_fuel_litter + emp.fuel_value.to_i
                total_fuel_cost = total_fuel_cost + (emp.fuel_value * fuel_rate).to_i
              end

              travel_allowance = FixedPayItem.where(:employee_id => emp.id, :pay_item_id => 14).last
              if travel_allowance.present?
                total_travel_allowance = total_travel_allowance + travel_allowance.item_amount.to_i
              end

              vehicle_allowance = FixedPayItem.where(:employee_id => emp.id, :pay_item_id => 6).last
              if vehicle_allowance.present?
                total_vehicle_allowance = total_vehicle_allowance + vehicle_allowance.item_amount.to_i
              end

              performance_incentive = FixedPayItem.where(:employee_id => emp.id, :pay_item_id => 19).last
              if performance_incentive.present?
                total_performance_incentive = total_performance_incentive + performance_incentive.item_amount.to_i
              end

              if emp.cell_phone_allowed == true
                total_handset_allowance = total_handset_allowance + (emp.cell_phone_entitlement_upto/24).to_i
              end

              maintenance_allowance = FixedPayItem.where(:pay_item_id => 27, :employee_id => emp.id).last
              if maintenance_allowance.present?
                total_maintenance_allowance = total_maintenance_allowance + maintenance_allowance.item_amount.to_i
              end
            end
            total_ctc = total_maintenance_allowance + total_handset_allowance + total_performance_incentive + total_vehicle_allowance + total_travel_allowance + total_fuel_cost + total_opd + total_provident_fund + total_utility + total_house_rent + total_basic_salary
            count = count + 1
            row_format = old_row_format

            if count.even? == true
              row_format = even_row_format
            else
              row_format = old_row_format
            end

            current_row_value = []
            current_row_style = []
            current_row_type = []

            current_row_value << count
            current_row_style << row_format
            current_row_type << :integer

            current_row_value << Location.find(location.to_i).name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << Department.find(department.to_i).name
            current_row_style << row_format
            current_row_type << :string

            sub = SubDepartment.find(sub_department.to_i)
            if sub.present?
              current_row_value << sub.name
              current_row_style << row_format
              current_row_type << :string
            else
              current_row_value << "-"
              current_row_style << row_format
              current_row_type << :string
            end


            current_row_value << sub_dept_employees.count
            current_row_style << row_format
            current_row_type << :integer

            current_row_value << total_basic_salary.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_house_rent.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_utility.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_gross_salary.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_opd.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_fuel_litter
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_fuel_cost.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_travel_allowance.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_vehicle_allowance.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_performance_incentive.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_handset_allowance.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_maintenance_allowance.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_provident_fund.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_ctc.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
            grand_total_ctc = grand_total_ctc + total_ctc.to_i
          end
        end
      end
      sheet.add_row ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "Total CTC", "#{grand_total_ctc.to_s(:delimited)}"], :style => header_style1

      file_name = "cost_to_company_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    elsif params[:report_type].to_i == 4
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Year Wise Summary')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      header_style1 = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Year", "Total Gross Salary", "Total Employees", "Total CTC"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')

      count = 0
      year = 2021
      grand_total_ctc = 0
      @year_wise_employees.each do |employees|
        total_basic_salary = 0
        total_house_rent = 0
        total_utility = 0
        total_gross_salary = 0
        total_opd = 0
        total_fuel_litter = 0
        total_travel_allowance = 0
        total_vehicle_allowance = 0
        total_performance_incentive = 0
        total_fuel_cost = 0
        total_provident_fund = 0
        total_handset_allowance = 0
        total_maintenance_allowance = 0
        total_ctc = 0
        if year == 2021
          employees.each do |emp|
            if emp.gross_salary > 0.0
              total_gross_salary = total_gross_salary + emp.gross_salary.to_i
              total_basic_salary = total_basic_salary + (emp.gross_salary * 0.67).to_i
              total_house_rent = total_house_rent + ((emp.gross_salary * 0.67).to_i * 0.45).to_i
              total_utility = total_utility + (emp.gross_salary - ((emp.gross_salary * 0.67).to_i) - (((emp.gross_salary * 0.67).to_i * 0.45).to_i)).to_i
              total_provident_fund = total_provident_fund + ((emp.gross_salary * 0.67).to_i * 0.0833).to_i
            end
            if emp.department_name != "Retail Stores"
              total_opd = total_opd + ((emp.gross_salary * 0.67).to_i * 0.02).to_i
            end
            if emp.fuel_allowed == true
              total_fuel_litter = total_fuel_litter + emp.fuel_value.to_i
              total_fuel_cost = total_fuel_cost + (emp.fuel_value * fuel_rate).to_i
            end

            travel_allowance = FixedPayItem.where(:employee_id => emp.id, :pay_item_id => 14).last
            if travel_allowance.present?
              total_travel_allowance = total_travel_allowance + travel_allowance.item_amount.to_i
            end

            vehicle_allowance = FixedPayItem.where(:employee_id => emp.id, :pay_item_id => 6).last
            if vehicle_allowance.present?
              total_vehicle_allowance = total_vehicle_allowance + vehicle_allowance.item_amount.to_i
            end

            performance_incentive = FixedPayItem.where(:employee_id => emp.id, :pay_item_id => 19).last
            if performance_incentive.present?
              total_performance_incentive = total_performance_incentive + performance_incentive.item_amount.to_i
            end

            if emp.cell_phone_allowed == true
              total_handset_allowance = total_handset_allowance + (emp.cell_phone_entitlement_upto/24).to_i
            end

            maintenance_allowance = FixedPayItem.where(:pay_item_id => 27, :employee_id => emp.id).last
            if maintenance_allowance.present?
              total_maintenance_allowance = total_maintenance_allowance + maintenance_allowance.item_amount.to_i
            end
          end
        else
          employees.each do |emp|
            pay_invoice = PayInvoice.find_by(employee_id: emp.id, pay_month: "November #{year}")
            if pay_invoice.present?
              pay_invoice_details = PayInvoiceDetail.where(pay_invoice_id: pay_invoice.id)
              if pay_invoice.payable_gross > 0.0
                total_gross_salary = total_gross_salary + pay_invoice.payable_gross.to_i
                if pay_invoice_details.where(item_name: "Basic Salary").present?
                  total_basic_salary = total_basic_salary + pay_invoice_details.where(item_name: "Basic Salary").last.amount.to_i
                end
                if pay_invoice_details.where(item_name: "House Rent").present?
                  total_house_rent = total_house_rent + pay_invoice_details.where(item_name: "House Rent").last.amount.to_i
                end
                if pay_invoice_details.where(item_name: "Utility Allowance").present?
                  total_utility = total_utility + pay_invoice_details.where(item_name: "Utility Allowance").last.amount.to_i
                end
                if pay_invoice_details.where(item_name: "Provident Fund").present?
                  total_provident_fund = total_provident_fund + pay_invoice_details.where(item_name: "Provident Fund").last.amount.to_i
                end
              end
              if emp.department_name != "Retail Stores" and pay_invoice_details.where(item_name: "Basic Salary").present?
                total_opd = total_opd + ((pay_invoice_details.where(item_name: "Basic Salary").last.amount).to_i * 0.02).to_i
              end
              if pay_invoice_details.where(item_name: "Fuel Allowance").present?
                total_fuel_cost = total_fuel_cost + pay_invoice_details.where(item_name: "Fuel Allowance").last.amount.to_i
              end
              if pay_invoice_details.where(item_name: "Travel Allowance").present?
                total_travel_allowance = total_travel_allowance + pay_invoice_details.where(item_name: "Travel Allowance").last.amount.to_i
              end
              if pay_invoice_details.where(item_name: "Vehicle Allowance").present?
                total_vehicle_allowance = total_vehicle_allowance + pay_invoice_details.where(item_name: "Vehicle Allowance").last.amount.to_i
              end
              # performance_incentive = FixedPayItem.where(:employee_id => emp.id, :pay_item_id => 19).last
              # if performance_incentive.present?
              #   total_performance_incentive = total_performance_incentive + performance_incentive.item_amount.to_i
              # end
              if pay_invoice_details.where(item_name: "Handset Allowance").present?
                total_handset_allowance = total_handset_allowance + pay_invoice_details.where(item_name: "Handset Allowance").last.amount.to_i
              end
              if pay_invoice_details.where(item_name: "Maintenance Allowance").present?
                total_maintenance_allowance = total_maintenance_allowance + pay_invoice_details.where(item_name: "Maintenance Allowance").last.amount.to_i
              end
            end
          end
        end

        total_ctc = total_maintenance_allowance + total_handset_allowance + total_performance_incentive + total_vehicle_allowance + total_travel_allowance + total_fuel_cost + total_opd + total_provident_fund + total_utility + total_house_rent + total_basic_salary

        count = count + 1
        row_format = old_row_format

        if count.even? == true
          row_format = even_row_format
        else
          row_format = old_row_format
        end

        current_row_value = []
        current_row_style = []
        current_row_type = []

        current_row_value << count
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << year
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << total_gross_salary.to_s(:delimited)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employees.count
        current_row_style << row_format
        current_row_type << :integer

        current_row_value << total_ctc.to_s(:delimited)
        current_row_style << row_format
        current_row_type << :string

        grand_total_ctc = grand_total_ctc + total_ctc
        year = year - 1
        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
      sheet.add_row ["", "", "", "Total CTC", "#{grand_total_ctc.to_s(:delimited)}"], :style => header_style1

      year = 2021

      @year_wise_employees.each do |employees|
        sheet.add_row ['']
        sheet.add_row ['']
        sheet.add_row ['']
        sheet.add_row ['']
        sheet.add_row ['']
        sheet.add_row ['']
        sheet.add_row ['']
        sheet.add_row ['']
        sheet.add_row ["", "", "", "", "", "", "", "", "", "Department Wise Summary For Year #{year}", "", "", "", "", "", "", "", ""], :style => header_style
        sheet.add_row ["Sr #", "location", "Department", "Total Employees", "Basic Salary", "House Rent", "Utility", "Gross Salary", "OPD", "Fuel Liter", "Fuel Cost", "Travel Allowance", "Vehicle Allowance", "Performance Incentive", "Handset Allowance", "Maintenance Allowance", "Provident Fund", "Total CTC"], :style => header_style
        grand_total_ctc = 0
        count = 0
        employees.pluck(:location_id).uniq.each do |location|
          location_employees = employees.where(:location_id => location)
          location_employees.pluck(:department_id).uniq.each do |department|
            department_employees = location_employees.where(:department_id => department)
            total_basic_salary = 0
            total_house_rent = 0
            total_utility = 0
            total_gross_salary = 0
            total_opd = 0
            total_fuel_litter = 0
            total_travel_allowance = 0
            total_vehicle_allowance = 0
            total_performance_incentive = 0
            total_fuel_cost = 0
            total_provident_fund = 0
            total_handset_allowance = 0
            total_maintenance_allowance = 0
            total_ctc = 0
            if year == 2021
              department_employees.each do |emp|
                if emp.gross_salary > 0.0
                  total_gross_salary = total_gross_salary + emp.gross_salary.to_i
                  total_basic_salary = total_basic_salary + (emp.gross_salary * 0.67).to_i
                  total_house_rent = total_house_rent + ((emp.gross_salary * 0.67).to_i * 0.45).to_i
                  total_utility = total_utility + (emp.gross_salary - ((emp.gross_salary * 0.67).to_i) - (((emp.gross_salary * 0.67).to_i * 0.45).to_i)).to_i
                  total_provident_fund = total_provident_fund + ((emp.gross_salary * 0.67).to_i * 0.0833).to_i
                end
                if emp.department_name != "Retail Stores"
                  total_opd = total_opd + ((emp.gross_salary * 0.67).to_i * 0.02).to_i
                end
                if emp.fuel_allowed == true
                  total_fuel_litter = total_fuel_litter + emp.fuel_value.to_i
                  total_fuel_cost = total_fuel_cost + (emp.fuel_value * fuel_rate).to_i
                end

                travel_allowance = FixedPayItem.where(:employee_id => emp.id, :pay_item_id => 14).last
                if travel_allowance.present?
                  total_travel_allowance = total_travel_allowance + travel_allowance.item_amount.to_i
                end

                vehicle_allowance = FixedPayItem.where(:employee_id => emp.id, :pay_item_id => 6).last
                if vehicle_allowance.present?
                  total_vehicle_allowance = total_vehicle_allowance + vehicle_allowance.item_amount.to_i
                end

                performance_incentive = FixedPayItem.where(:employee_id => emp.id, :pay_item_id => 19).last
                if performance_incentive.present?
                  total_performance_incentive = total_performance_incentive + performance_incentive.item_amount.to_i
                end

                if emp.cell_phone_allowed == true
                  total_handset_allowance = total_handset_allowance + (emp.cell_phone_entitlement_upto/24).to_i
                end

                maintenance_allowance = FixedPayItem.where(:pay_item_id => 27, :employee_id => emp.id).last
                if maintenance_allowance.present?
                  total_maintenance_allowance = total_maintenance_allowance + maintenance_allowance.item_amount.to_i
                end
              end
            else
              department_employees.each do |emp|
                pay_invoice = PayInvoice.find_by(employee_id: emp.id, pay_month: "November #{year}")
                if pay_invoice.present?
                  pay_invoice_details = PayInvoiceDetail.where(pay_invoice_id: pay_invoice.id)
                  if pay_invoice.payable_gross > 0.0
                    total_gross_salary = total_gross_salary + pay_invoice.payable_gross.to_i
                    if pay_invoice_details.where(item_name: "Basic Salary").present?
                      total_basic_salary = total_basic_salary + pay_invoice_details.where(item_name: "Basic Salary").last.amount.to_i
                    end
                    if pay_invoice_details.where(item_name: "House Rent").present?
                      total_house_rent = total_house_rent + pay_invoice_details.where(item_name: "House Rent").last.amount.to_i
                    end
                    if pay_invoice_details.where(item_name: "Utility Allowance").present?
                      total_utility = total_utility + pay_invoice_details.where(item_name: "Utility Allowance").last.amount.to_i
                    end
                    if pay_invoice_details.where(item_name: "Provident Fund").present?
                      total_provident_fund = total_provident_fund + pay_invoice_details.where(item_name: "Provident Fund").last.amount.to_i
                    end
                  end
                  if emp.department_name != "Retail Stores" and pay_invoice_details.where(item_name: "Basic Salary").present?
                    total_opd = total_opd + ((pay_invoice_details.where(item_name: "Basic Salary").last.amount).to_i * 0.02).to_i
                  end
                  if pay_invoice_details.where(item_name: "Fuel Allowance").present?
                    total_fuel_cost = total_fuel_cost + pay_invoice_details.where(item_name: "Fuel Allowance").last.amount.to_i
                  end
                  if pay_invoice_details.where(item_name: "Travel Allowance").present?
                    total_travel_allowance = total_travel_allowance + pay_invoice_details.where(item_name: "Travel Allowance").last.amount.to_i
                  end
                  if pay_invoice_details.where(item_name: "Vehicle Allowance").present?
                    total_vehicle_allowance = total_vehicle_allowance + pay_invoice_details.where(item_name: "Vehicle Allowance").last.amount.to_i
                  end
                  # performance_incentive = FixedPayItem.where(:employee_id => emp.id, :pay_item_id => 19).last
                  # if performance_incentive.present?
                  #   total_performance_incentive = total_performance_incentive + performance_incentive.item_amount.to_i
                  # end
                  if pay_invoice_details.where(item_name: "Handset Allowance").present?
                    total_handset_allowance = total_handset_allowance + pay_invoice_details.where(item_name: "Handset Allowance").last.amount.to_i
                  end
                  if pay_invoice_details.where(item_name: "Maintenance Allowance").present?
                    total_maintenance_allowance = total_maintenance_allowance + pay_invoice_details.where(item_name: "Maintenance Allowance").last.amount.to_i
                  end
                end
              end
            end

            total_ctc = total_maintenance_allowance + total_handset_allowance + total_performance_incentive + total_vehicle_allowance + total_travel_allowance + total_fuel_cost + total_opd + total_provident_fund + total_utility + total_house_rent + total_basic_salary
            count = count + 1
            row_format = old_row_format

            if count.even? == true
              row_format = even_row_format
            else
              row_format = old_row_format
            end

            current_row_value = []
            current_row_style = []
            current_row_type = []

            current_row_value << count
            current_row_style << row_format
            current_row_type << :integer

            current_row_value << Location.find(location.to_i).name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << Department.find(department.to_i).name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << department_employees.count
            current_row_style << row_format
            current_row_type << :integer

            current_row_value << total_basic_salary.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_house_rent.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_utility.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_gross_salary.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_opd.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_fuel_litter
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_fuel_cost.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_travel_allowance.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_vehicle_allowance.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_performance_incentive.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_handset_allowance.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_maintenance_allowance.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_provident_fund.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            current_row_value << total_ctc.to_s(:delimited)
            current_row_style << row_format
            current_row_type << :string

            grand_total_ctc = grand_total_ctc + total_ctc
            count = count + 1
            sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
          end
        end
        sheet.add_row ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "Total CTC", "#{grand_total_ctc.to_s(:delimited)}"], :style => header_style1
        year = year - 1
      end
      file_name = "year_wise_summary"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    elsif params[:report_type].to_i == 5
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Turn Over Report')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr No.", "Location", "Department", "Year", "Prev Year Employees", "New Joiner Employees", "Total Resigned Employees", "Total Employees", "Percentage"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      Array.new(6).each_index do |index|
        sheet.column_info[index].width = 20
      end
      count = 0
      years = [2019, 2020, 2021]
      years.each do |year|
        sheet.add_row ["", "", "", "", "", "For Year #{year}", "", "", ""], :style => header_style
        @employees.pluck(:location_id).uniq.each do |location|
          location_employees = @employees.where(:location_id => location)
          location_employees.pluck(:department_id).uniq.each do |department|
            department_employees = location_employees.where(:department_id => department)
            count = count + 1
            row_format = old_row_format

            if count.even? == true
              row_format = even_row_format
            else
              row_format = old_row_format
            end

            current_row_value = []
            current_row_style = []
            current_row_type = []

            current_row_value << count
            current_row_style << row_format
            current_row_type << :integer

            current_row_value << Location.find(location.to_i).name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << Department.find(department.to_i).name
            current_row_style << row_format
            current_row_type << :string

            current_row_value << year
            current_row_style << row_format
            current_row_type << :string

            prev_year_emp = department_employees.where(:joining_date => Employee.order("joining_date ASC").pluck(:joining_date).uniq.first..("#{year}-01-01".to_date - 1.year).end_of_year)
            current_row_value <<  prev_year_emp.count
            current_row_style << row_format
            current_row_type << :string

            joined_emp = department_employees.where(:joining_date => ("#{year}-01-01".to_date).beginning_of_year..("#{year}-01-01".to_date).end_of_year)
            current_row_value <<  joined_emp.count
            current_row_style << row_format
            current_row_type << :string

            emp_resign = EmployeeTransactionHistory.where(:transaction_type => "End of Employment", :employee_id => joined_emp.pluck(:id))
            emp_resign_transaction_date = emp_resign.where(:transaction_date => ("#{year}-01-01".to_date).beginning_of_year..("#{year}-01-01".to_date).end_of_year)
            current_row_value << emp_resign_transaction_date.count
            current_row_style << row_format
            current_row_type << :string

            total = (prev_year_emp.count + joined_emp.count) - emp_resign_transaction_date.count
            current_row_value <<  total
            current_row_style << row_format
            current_row_type << :string

            avg = ((prev_year_emp.count + total)/2).to_f
            per = ((emp_resign_transaction_date.count/avg)*100).to_f.round(2)

            current_row_value <<  per
            current_row_style << row_format
            current_row_type << :float

            sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
          end
        end
      end
      file_name = "turnover_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    end
  end

  private

  def delete_pdf_reports
    files = Dir.glob(File.join("#{Rails.public_path}/pdf", '**', '*')).select { |file| File.file?(file) }
    if files.count > 0
      files.each do |aFile|
        File.delete(aFile)
      end
    end
  end

  def delete_excel_reports
    files = Dir.glob(File.join("#{Rails.public_path}/excel", '**', '*')).select { |file| File.file?(file) }
    if files.count > 0
      files.each do |aFile|
        File.delete(aFile)
      end
    end
  end

  def check_directory(dir_path)
    unless File.directory?(dir_path)
      Dir.mkdir(dir_path)
    end
  end


  def srl_employee_profile_report
    time = Time.now
    book = Axlsx::Package.new
    check_directory("#{Rails.public_path}/excel")
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'Employee Profile Detail')
    book.use_autowidth = false
    sheet.sheet_view do |view|
      view.show_outline_symbols = true
    end
    book.use_autowidth = true
    header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
    bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

    sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']

    sheet.add_row ['Personal Information', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '','','', '', '', '', '', '', '', '', '', '', '','','','','','','','Present Address', '', '', '', '', '', '', '', 'Permanent Address', '', '', '', '', '', '', '','','','','Employment Information', '', '', '', '', '', '', '', '', '', 'User Account', '', '', 'Emergency Contact', '', '', '', 'Attendance Information', '', '', '', '', '', '', '', '', '', '', '', '', '', 'Salary Information ', 'Salary Information', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 'Benefits Information', 'Benefits Information', 'Benefits Information', 'Benefits Information', 'Benefits Information', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 'Other Information', 'Other Information','','',''], :style => header_style
    sheet.merge_cells Axlsx::cell_r(0, 5) + ':' + Axlsx::cell_r(41, 5)
    sheet.merge_cells Axlsx::cell_r(42, 5) + ':' + Axlsx::cell_r(49, 5)
    sheet.merge_cells Axlsx::cell_r(50, 5) + ':' + Axlsx::cell_r(60, 5)
    sheet.merge_cells Axlsx::cell_r(61, 5) + ':' + Axlsx::cell_r(70, 5)
    sheet.merge_cells Axlsx::cell_r(71, 5) + ':' + Axlsx::cell_r(73, 5)
    sheet.merge_cells Axlsx::cell_r(74, 5) + ':' + Axlsx::cell_r(77, 5)
    sheet.merge_cells Axlsx::cell_r(78, 5) + ':' + Axlsx::cell_r(92, 5)
    sheet.merge_cells Axlsx::cell_r(93, 5) + ':' + Axlsx::cell_r(110, 5)
    sheet.merge_cells Axlsx::cell_r(111, 5) + ':' + Axlsx::cell_r(129, 5)
    sheet.merge_cells Axlsx::cell_r(130, 5) + ':' + Axlsx::cell_r(134, 5)
    sheet.add_row ["Sr #", "Emp Code", "Name", "Salutation", "First Name", "Last Name", "Father Name", "Mother Name","Spouse Name", "Location Type", "Location", "Department", "Sub Department", "Grade", "Designation", "Job Title","Categories","Salary Unit", "Cost Center", "Employee Type", "Official Email Address", "Personal Email Address", "Official Mobile #", "Personal Mobile #","Whats App #","LinkedIn Profile URL", "DOB", "Age", "Gender", "Blood Group","Marriage Date","Marital Status","Vaccinated","Disability/Special Needs","Disability/Special Needs","Criminal Record","Passport Number","Passport Expiry","License Number","License Expiry", "CNIC No.", "Expiry date of CNIC", "File Number", "Family Number", "Tags", "NTN #", "Religion", "Religion Sect", "Present Address", "Country", "State/Province", "City" , "Union Council", "Police Station", "Permanent Address", "Country", "State/Province", "City", "Union Council", "Police Station","Languages","Languages Level","Skills/Software","Skills/Software Level","DOJ", "Old Joining Date", "Date of Transfer", "Contract Start Date", "Contract End Date", "Confirmation Due Date", "Confirmation Date", "Previous Employee Code", "Is Line Manager ?", "Line Manager", "User Account", "Role", "Email", "Emergency Contact Name", "Emergency Contact Relation", "Emergency Contact Email", "Emergency Contact Phone", "Request Exempted", "Attendance Exception", "Overtime (Regular Working Day)", "Overtime (Rest Day)", "Off Day Working", "Quota Encashment (Regular Working Day)", "Quota Encashment (Rest Day)", "CPL (Regular Working Day)", "CPL (Rest/Public Day)", "", "Late Exempted", "Attendance Exempted", "Approval Based Overtime", "Exempted From Reports", "-", "Payment Method", "Gross Salary", "Salary Exempted", "Hold Salary", "Back Date EOBI", "Back Date Allowance", "Back Date Provident Fund", "-", "Medical Allowance (Restriction)", "-", "-", "-", "-", "Bank Name", "Branch Name", "Branch Code", "Account Title", "Account #", "Social Security", "Group Life Insurance", "Health Insurance", "Cellphone Bill", "Fuel Reimbursement", "Cell Phone", "Laptop", "Vehicle", "Provident Fund", "EOBI", "Gratuity", "House Allowance", "LFA", "Vehicle Allowance", "Maintenance", "Travel Allowance", "Eid-ul-fitr Bonus", "Eid-ul-Azha Bonus", "Annual Bonus", "Total # of Experience before Sapphire", "Total # of Experience with Sapphire", "Fuel Value", "Cell Phone Entitlement Upto", "Mobile Bill Allowance", "Mobile Allowance Fixed", "Vehicle Allowance", "Vehicle Allowance Fixed", "Status"], :style => header_style

    old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
    even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
    Array.new(28).each_index do |index|
      sheet.column_info[index].width = 20
    end
    count = 0
    @employees.each do |employee|
      count = count + 1
      row_format = old_row_format

      if count.even? == true
        row_format = even_row_format
      else
        row_format = old_row_format
      end

      current_row_value = []
      current_row_style = []
      current_row_type = []

      current_row_value << count
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << employee.employee_code.to_i
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << employee.full_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.salutation
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.first_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.last_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.father_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << "-"
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.spouse_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.location_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.branch_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.department_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.sub_department_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.grade_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.designation_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.job_title_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.category
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.salary_unit_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.cost_center_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.employee_type_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.official_email
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.personal_email
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.phone_format(employee.official_mobile_number)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.phone_format(employee.personal_number)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.phone_format(employee.whatsapp_number)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.linkedln_url
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(employee.date_of_birth)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.employee_age(employee.date_of_birth)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.gender
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.blood_group
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(employee.marriage_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.martial_status
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.vaccinated)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.disability)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.disability_needs
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.criminal_record
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.passport_number
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(employee.passport_expiry)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.license_number
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(employee.license_expiry)
      current_row_style << row_format
      current_row_type << :string


      current_row_value << ReportFormat.cnic_format(employee.cnic_number)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(employee.cnic_expiry_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.file_number
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.family_number
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.tags
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.ntn_number
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.religion_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.religion_sect_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.permanent_address
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.permanent_country_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.permanent_state_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.permanent_city_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << "-"
      current_row_style << row_format
      current_row_type << :string

      current_row_value << "-"
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.current_address
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.country_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.state_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.city_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << "-"
      current_row_style << row_format
      current_row_type << :string

      current_row_value << "-"
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.languages
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.languages_level
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.skills_software
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.skills_level
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(employee.joining_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << "-"
      current_row_style << row_format
      current_row_type << :string

      current_row_value << "-"
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(employee.contract_start_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(employee.contract_end_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(employee.confimration_due_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(employee.confirmation_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.prev_employee_code
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.is_line_manager)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.line_manager_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.create_login)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.role_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.user_account_email
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.emergency_contact_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.relationship_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.emergency_contact_email
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.phone_format(employee.emergency_contact_phone)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << "-"
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.attendance_impact_allowed)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.is_overtime)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.is_holiday_overtime)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.is_off_day_working)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.regular_quota_encashment)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.regular_quota_encashment)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.is_regular_cpl)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.is_cpl)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << "-"
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.late_exempted)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.attendance_exempted)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.approval_base_overtime)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.excluded_from_reports)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << "-"
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.payment_method
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.gross_salary
      current_row_style << row_format
      current_row_type << :float

      current_row_value << ReportFormat.boolean_in_text(employee.salary_exempted)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.hold_salary)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.back_date_eobi_impact)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.back_date_allowance_impact)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.back_date_pf_impact)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << "-"
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.is_medical_allowance)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << "-"
      current_row_style << row_format
      current_row_type << :string

      current_row_value << "-"
      current_row_style << row_format
      current_row_type << :string

      current_row_value << "-"
      current_row_style << row_format
      current_row_type << :string

      current_row_value << "-"
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.bank_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.bank_branch_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.bank_branch_code
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.bank_account_title
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.bank_account_number
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.social_security_allowed)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.life_insurance_allowed)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.health_insurance_allowed)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.cell_phone_bill_allowed)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.fuel_allowed)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.cell_phone_allowed)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.laptop_allowed)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.velicle_allowed)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.provident_fund_allowed)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.eobi_allowed)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << "-"
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.house_allowance_allowed)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.lfa_allowed)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.vehicle_allowance_allowed)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.maintenance_allowed)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.travel_allowance_allowed)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.bonus1_allowed)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.bonus2_allowed)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.bonus3_allowed)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.employee_previous_experince(employee)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.employee_current_experince(employee)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.fuel_value
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.cell_phone_entitlement_upto
      current_row_style << row_format
      current_row_type << :string

      ["Mobile Bill Allowance", "Mobile Allowance Fixed", "Vehicle Allowance", "Vehicle Allowance Fixed"].each do |pay_item|
        item_id = PayItem.where(:name => pay_item, :item_type => "Earning", :is_active => true).pluck(:id)
        allowance = employee.fixed_pay_items.where(:pay_item_id => item_id)
        if allowance.present?
          current_row_value << allowance.sum(:item_amount)
          current_row_style << row_format
          current_row_type << :string
        else
          current_row_value << "0"
          current_row_style << row_format
          current_row_type << :string
        end
      end

      current_row_value << ReportFormat.boolean_in_text(employee.is_active)
      current_row_style << row_format
      current_row_type << :string

      sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

    end
    file_name = "employee_profile_detail_report"
    url_path = save_excel_file(book, file_name)
    render json: {message: "Excel Created", path: url_path}
  end

  def document_checklist
    time = Time.now
    book = Axlsx::Package.new
    check_directory("#{Rails.public_path}/excel")
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'Membership Affiliations Detail')
    book.use_autowidth = false
    sheet.sheet_view do |view|
      view.show_outline_symbols = true
    end
    book.use_autowidth = true
    header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
    bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

    sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']

    sheet.add_row ["Sr #", "Emp Code","Employee Name", "Location", "Branch", "Department","Document Name", "Remarks"], :style => header_style
    old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
    even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
    Array.new(7).each_index do |index|
      sheet.column_info[index].width = 25
    end
    count = 0
    @documents = EmployeeDocument.where(:employee_id => @employees.collect(&:id))

    @documents.each do |employee|

      count = count + 1
      row_format = old_row_format

      if count.even? == true
        row_format = even_row_format
      else
        row_format = old_row_format
      end
      current_row_value = []
      current_row_style = []
      current_row_type = []

      current_row_value << count
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << employee.employee_code.to_i
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << employee.employee_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.employee.location_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.employee.branch_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.employee.department_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.document_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.document_remarks
      current_row_style << row_format
      current_row_type << :string


      sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
    end
    file_name = "employee_profile_detail_report"
    url_path = save_excel_file(book, file_name)
    render json: {message: "Excel Created", path: url_path}
  end

  def srl_employee_list_details
    time = Time.now
    book = Axlsx::Package.new
    check_directory("#{Rails.public_path}/excel")
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'Employee List')
    book.use_autowidth = false
    sheet.sheet_view do |view|
      view.show_outline_symbols = true
    end
    book.use_autowidth = true
    header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
    bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

    sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']

    sheet.add_row ["Sr #", "Emp Code", "Salutation", "Name", "Father Name", "Mother Name","Spouse Name", "Grade", "Designation", "Location", "Branch", "Department", "Sub Department", "Job Title","Profile Picture","Categories", "Employee Type", "Hiring Shift", "Employment Status", "CNIC", "CNIC Expiry Date", "DOB", "DOJ", "DOC", "Contract Start Date", "Contract End Date", "Date Of Retirement","Vaccinated","Official Email", "Official Number", "Personal Number","WhatsApp #","Emergency Contact Number","LinkedIn Profile URL","Languages","Language Level","Skills/Software","Skills/Software Level","Current Address", "Permanent Address", "Service Tenure", "Experience", "Blood Group","Marriage Date","Marital Status","Disability","Disability/Special Needs","Criminal Record","Passport Number","Passport Expiry","License Number","License Expiry","Gross Salary", "Incentive", "Line Manager", "Line Manager Employee Code"], :style => header_style
    old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
    date_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :format_code => 'yyyy-mm-dd', :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
    even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
    Array.new(31).each_index do |index|
      sheet.column_info[index].width = 20
    end
    count = 0
    @employees.each do |employee|
      count = count + 1
      row_format = old_row_format

      if count.even? == true
        row_format = even_row_format
      else
        row_format = old_row_format
      end

      current_row_value = []
      current_row_style = []
      current_row_type = []

      current_row_value << count
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << employee.employee_code.to_i
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << employee.salutation
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.full_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.father_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.mother_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.spouse_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.grade_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.designation_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.location_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.branch_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.department_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.sub_department_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.job_title_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.avatar_file_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.category
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.employee_type_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.hiring_shift
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text_as_confirmed(employee.on_probation)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.cnic_format(employee.cnic_number)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.cnic_expiry_date.try(:to_date)
      current_row_style << date_format
      current_row_type << :date

      current_row_value << employee.date_of_birth.try(:to_date)
      current_row_style << date_format
      current_row_type << :date

      current_row_value << employee.joining_date.try(:to_date)
      current_row_style << date_format
      current_row_type << :date

      current_row_value << employee.confirmation_date.try(:to_date)
      current_row_style << date_format
      current_row_type << :date

      current_row_value << ReportFormat.date_format(employee.contract_start_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(employee.contract_end_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << "-"
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.vaccinated)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.official_email
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.phone_format(employee.official_mobile_number)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.phone_format(employee.personal_number)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.phone_format(employee.whatsapp_number)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.phone_format(employee.emergency_contact_phone)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.linkedln_url
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.languages
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.languages_level
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.skills_software
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.skills_level
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.current_address
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.permanent_address
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_in_human_readable(employee.joining_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.employee_experince(employee.joining_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.blood_group
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(employee.marriage_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.martial_status
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.boolean_in_text(employee.disability)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.disability_needs
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.criminal_record
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.passport_number
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(employee.passport_expiry)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.license_number
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(employee.license_expiry)
      current_row_style << row_format
      current_row_type << :string

      if @show_salary == true
        if employee.gross_salary.present?
          current_row_value << employee.gross_salary.round
          current_row_style << row_format
          current_row_type << :float
        else
          current_row_value << "-"
          current_row_style << row_format
          current_row_type << :string
        end
      else
        current_row_value << "-"
        current_row_style << row_format
        current_row_type << :string
      end

      current_row_value << employee.incentives
      current_row_style << row_format
      current_row_type << :float

      current_row_value << employee.line_manager_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee.line_manager_employee_code.to_i
      current_row_style << row_format
      current_row_type << :integer

      sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
    end
    file_name = "employee_list_report"
    url_path = save_excel_file(book, file_name)
    render json: {message: "Excel Created", path: url_path}
  end
  def srl_employee_experience_report
    time = Time.now
    book = Axlsx::Package.new
    check_directory("#{Rails.public_path}/excel")
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'Employee Experience Detail')
    book.use_autowidth = false
    sheet.sheet_view do |view|
      view.show_outline_symbols = true
    end
    book.use_autowidth = true
    header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
    bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

    sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']

    sheet.add_row ["Sr #", "Emp Code", "Name", "Organization", "Job Title","Department","Other Benefits","Left Reason", "Salary", "Start Date", "End Date", "Total Previous Experince"], :style => header_style
    old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
    even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
    Array.new(12).each_index do |index|
      sheet.column_info[index].width = 20
    end
    count = 0
    @employee_experiences.order('employee_id ASC').each do |employee_experience|
      count = count + 1
      row_format = old_row_format

      if count.even? == true
        row_format = even_row_format
      else
        row_format = old_row_format
      end

      current_row_value = []
      current_row_style = []
      current_row_type = []

      current_row_value << count
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << employee_experience.employee_code.to_i
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << employee_experience.employee_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.non_text_to_dash(employee_experience.organization)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.non_text_to_dash(employee_experience.job_title)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.non_text_to_dash(employee_experience.department)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.non_text_to_dash(employee_experience.other_benefits)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.non_text_to_dash(employee_experience.left_reason)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.non_float_to_dash(employee_experience.salary)
      current_row_style << row_format
      current_row_type << :float

      current_row_value << ReportFormat.date_format(employee_experience.start_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(employee_experience.end_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.employee_previous_experince_in_years(employee_experience.employee)
      current_row_style << row_format
      current_row_type << :string

      sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
    end
    file_name = "employee_experience_detail_report"
    url_path = save_excel_file(book, file_name)
    render json: {message: "Excel Created", path: url_path}
  end
  def srl_employee_membership
    time = Time.now
    book = Axlsx::Package.new
    check_directory("#{Rails.public_path}/excel")
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'Membership Affiliations Detail')
    book.use_autowidth = false
    sheet.sheet_view do |view|
      view.show_outline_symbols = true
    end
    book.use_autowidth = true
    header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
    bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

    sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']

    sheet.add_row ["Sr #", "Emp Code", "Name", "Position Title", "Institute Name","Start Date", "End Date", "Remarks"], :style => header_style
    old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
    even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
    Array.new(8).each_index do |index|
      sheet.column_info[index].width = 20
    end
    count = 0
    @employee_membership.order('employee_id ASC').each do |employee_membership|

      count = count + 1
      row_format = old_row_format

      if count.even? == true
        row_format = even_row_format
      else
        row_format = old_row_format
      end
      current_row_value = []
      current_row_style = []
      current_row_type = []

      current_row_value << count
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << employee_membership.employee_code.to_i
      current_row_style << row_format
      current_row_type << :integer

      current_row_value << employee_membership.employee_name
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.non_text_to_dash(employee_membership.position_title)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.non_text_to_dash(employee_membership.institute_name)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(employee_membership.start_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << ReportFormat.date_format(employee_membership.end_date)
      current_row_style << row_format
      current_row_type << :string

      current_row_value << employee_membership.remarks
      current_row_style << row_format
      current_row_type << :string


      sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
    end
    file_name = "Membership Affiliations_detail_report"
    url_path = save_excel_file(book, file_name)
    render json: {message: "Excel Created", path: url_path}
  end
  def srl_employee_relative
    time = Time.now
    book = Axlsx::Package.new
    check_directory("#{Rails.public_path}/excel")
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'Employee Relative Detail')
    book.use_autowidth = false
    sheet.sheet_view do |view|
      view.show_outline_symbols = true
    end
    book.use_autowidth = true
    header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
    bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

    sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ['']
    sheet.add_row ["Emp Code", "Name", "Relationship Name", "Email", "Contact Number", "Date of Birth", "Date of Enrollment", "Gender", "CNIC","Marital Status","Is Dependent", "Insurance Allowed","Alive/Deceased","Same as Employee Current Address", "Same as Employee Permanent Address","Covid-19 Vaccination","Insurance Plan", "Address", "Relative Age"], :style => header_style

    old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
    even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
    count = 0
    ids = @employee_relatives.collect(&:employee_id).uniq
    Employee.where(:id => ids).each do |employee_id|
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      relative_count = 0
      @employee_relatives.where(employee_id: employee_id.id).order('employee_id ASC').each do |employee_relative|
        count = count + 1
        row_format = old_row_format

        if count.even? == true
          row_format = even_row_format
        else
          row_format = old_row_format
        end

        current_row_value = []
        current_row_style = []
        current_row_type = []


        relative_count = relative_count + 1

        if relative_count == 1

          current_row_value << employee_relative.employee_code.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employee_relative.employee_name
          current_row_style << row_format
          current_row_type << :string
          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type

        end

      end
      @employee_relatives.where(employee_id: employee_id.id).order('employee_id ASC').each do |employee_relative|

        count = count + 1
        row_format = old_row_format

        if count.even? == true
          row_format = even_row_format
        else
          row_format = old_row_format
        end
        current_row_value = []
        current_row_style = []
        current_row_type = []

        current_row_value << ""
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_relative.relative_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_relative.relationship_name
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_relative.email
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.phone_format(employee_relative.contact_number)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee_relative.date_of_birth)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.date_format(employee_relative.date_of_enrollment)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_relative.gender
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.cnic_format(employee_relative.cnic_number)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_relative.martial_status
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.boolean_in_text(employee_relative.is_dependent)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.boolean_in_text(employee_relative.insurance_allowed)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.boolean_in_text(employee_relative.deceased)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.boolean_in_text(employee_relative.same_as_employee_address)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.boolean_in_text(employee_relative.same_as_employee_address)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << ReportFormat.boolean_in_text(employee_relative.covid_vaccination)
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_relative.employee.health_insurance_plan
        current_row_style << row_format
        current_row_type << :string

        current_row_value << employee_relative.address
        current_row_style << row_format
        current_row_type << :string

        if employee_relative.date_of_birth.nil?
          current_row_value <<  0
          current_row_style << row_format
          current_row_type << :integer
        else
          current_row_value << Time.now.year - employee_relative.date_of_birth.year
          current_row_style << row_format
          current_row_type << :integer
        end
        sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      end
    end

    file_name = "employee_relative_detail_report"
    url_path = save_excel_file(book, file_name)
    render json: {message: "Excel Created", path: url_path}
  end



  def number_to_delimeter(number)
    num_groups = number.to_s.chars.to_a.reverse.each_slice(3)
    num_groups.map(&:join).join(',').reverse
  end
end