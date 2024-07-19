class Api::V1::Web::Reports::PerformanceManagementReportsController < ApplicationController

  def objective_list
    @objective_settings = ObjectiveSetting.all
    if params[:report_type].to_i == 1
      employee = Employee.find(@objective_settings.first.employee_id)
      @company = Company.find(employee.company_id)
      time = Time.now
      url_path = ""
      check_directory("#{Rails.public_path}/pdf")
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/web/reports/performance_management_reports/objective_list", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
        footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
        :margin => {
          :top      => '0.1in',
          :bottom   => '0.1in',
          :left     => '0.1in',
          :right    => '0.1in'
        },
        dpi: 300,
        orientation: 'Landscape'
      )
      file_name = "objective_setting"
      url_path = save_pdf_file(pdf, file_name)

      render json: {message: "Pdf Created", path: url_path}
    elsif params[:report_type].to_i == 2
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Objective Setting')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 12,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Emp Code", "Name", "Department", "Branch", "Employment Status", "Date of Joining", "Line Manager Emp Code", "Line Manager Name", "HOD Emp Code", "HOD Name", "Email ID", "Employee Objective Setting Submit Status", "Line Manager Objective Setting Approval Status", "Total Weight", "Weight Consumed"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      date_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :format_code => 'yyyy-mm-dd', :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      pending_row_format = wb.styles.add_style(:bg_color => "ffff00", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      Array.new(16).each_index do |index|
        sheet.column_info[index].width = 16
      end
      count = 0
      total_weight = 100
      @objective_settings.each do |objective|
        employees = Employee.where(:id => objective.employee_id)
        if employees.present?
          employees = employees.last
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

          current_row_value << employees.employee_code.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employees.full_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employees.department_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employees.branch_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text_as_confirmed(employees.on_probation)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(employees.joining_date)
          current_row_style << row_format
          current_row_type << :string

          if employees.line_manager_id.present?
            line_manager = Employee.where(:id => employees.line_manager_id)
            if line_manager.present?
              line_manager = line_manager.last
            else
              line_manager = ""
            end
          else
            line_manager = ""
          end
          if employees.hod_id.present?
            hod = Employee.where(:id => employees.hod_id)
            if hod.present?
              hod = hod.last
            else
              hod = ""
            end
          else
            hod = ""
          end

          if line_manager.present?
            current_row_value << line_manager.employee_code
            current_row_style << row_format
            current_row_type << :string
          else
            current_row_value << "-"
            current_row_style << row_format
            current_row_type << :string
          end

          if line_manager.present?
            current_row_value << line_manager.full_name
            current_row_style << row_format
            current_row_type << :string
          else
            current_row_value << "-"
            current_row_style << row_format
            current_row_type << :string
          end

          if hod.present?
            current_row_value << hod.employee_code
            current_row_style << row_format
            current_row_type << :string
          else
            current_row_value << "-"
            current_row_style << row_format
            current_row_type << :string
          end

          if hod.present?
            current_row_value << hod.full_name
            current_row_style << row_format
            current_row_type << :string
          else
            current_row_value << "-"
            current_row_style << row_format
            current_row_type << :string
          end

          current_row_value << employees.official_email
          current_row_style << row_format
          current_row_type << :string

          if objective.line_manager_approval == "Approved"
            current_row_value << "Submitted"
            current_row_style << row_format
            current_row_type << :string
          else
            current_row_value << objective.line_manager_approval
            current_row_style << pending_row_format
            current_row_type << :string
          end

          if objective.status == "Approved"
            current_row_value << objective.status
            current_row_style << row_format
            current_row_type << :string
          else
            current_row_value << objective.status
            current_row_style << pending_row_format
            current_row_type << :string
          end

          task = objective.task_ids.split(',')
          weight_consumed = 0
          Task.where(:id => task).each do |t|
            weight_consumed = weight_consumed + t.weight.to_i
          end
          # task.each do |t|
          #   byebug
          #   weight = Task.find(t.to_i)
          #   if weight.present?
          #
          #   end
          # end

          current_row_value << total_weight.to_s + "%"
          current_row_style << row_format
          current_row_type << :string

          current_row_value << weight_consumed.to_s + "%"
          current_row_style << row_format
          current_row_type << :string

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
        end
      end
      file_name = "objective_setting_report"
      url_path = save_excel_file(book, file_name)
      render json: {message: "Excel Created", path: url_path}
    end
  end

  def appraisal_list
    @objective_settings = ObjectiveSetting.all
    fiscal_year_id = FiscalYear.where(:is_active => true).first.id
    if params[:report_type].to_i == 1
      employee = Employee.find(@objective_settings.first.employee_id)
      @company = Company.find(employee.company_id)
      time = Time.now
      url_path = ""
      check_directory("#{Rails.public_path}/pdf")
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string("api/v1/web/reports/performance_management_reports/appraisal_list", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
        footer: {content: render_to_string("api/v1/web/pdf_templates/footer", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]},
        :margin => {
          :top      => '0.1in',
          :bottom   => '0.1in',
          :left     => '0.1in',
          :right    => '0.1in'
        },
        dpi: 300,
        orientation: 'Landscape'
      )
      file_name = "appraisal"
      url_path = save_pdf_file(pdf, file_name)

      render json: {message: "Pdf Created", path: url_path}
    elsif params[:report_type].to_i == 2
      time = Time.now
      book = Axlsx::Package.new
      check_directory("#{Rails.public_path}/excel")
      wb = book.workbook
      sheet = wb.add_worksheet(name: 'Appraisal')
      book.use_autowidth = false
      sheet.sheet_view do |view|
        view.show_outline_symbols = true
      end
      book.use_autowidth = true
      header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 12, :height => 15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
      bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 12,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
      cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'

      sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']
      sheet.add_row ['']

      sheet.add_row ["Sr #", "Objective ID", "Emp Code", "Name", "Department", "Branch", "Employment Status", "Date of Joining", "Line Manager Emp Code", "Line Manager Name", "HOD Emp Code", "HOD Name", "Email ID", "Employee Appraisal Submit Status", "Line Manager Appraisal Approval Status", "HOD Appraisal Approval Status", "Employee Comments", "Line Manager Comments", "Development Need Functional", "Leadership & Soft Skills", "Career Aspiration", "Employee Objective Net Score", "Employee Behaviour Net Score", 'Employee Net Score', "Employee Rating Scale", "Line Manager Objective Net Score", "Line Manager Behaviour Net Score", "Line Manager Net Score", "Line Manager Rating Scale"], :style => header_style
      old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      date_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :format_code => 'yyyy-mm-dd', :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      pending_row_format = wb.styles.add_style(:bg_color => "ffff00", :fg_color=> "000000", :sz => 8, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :font_name => 'Tahoma')
      Array.new(21).each_index do |index|
        sheet.column_info[index].width = 21
      end
      count = 0
      @objective_settings.each do |objective|
        employees = Employee.where(:id => objective.employee_id)
        if employees.present?
          employees = employees.last
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

          current_row_value << objective.id
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employees.employee_code.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << employees.full_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employees.department_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employees.branch_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.boolean_in_text_as_confirmed(employees.on_probation)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(employees.joining_date)
          current_row_style << row_format
          current_row_type << :string

          if employees.line_manager_id.present?
            line_manager = Employee.where(:id => employees.line_manager_id)
            if line_manager.present?
              line_manager = line_manager.last
            else
              line_manager = ""
            end
          else
            line_manager = ""
          end
          if employees.hod_id.present?
            hod = Employee.where(:id => employees.hod_id)
            if hod.present?
              hod = hod.last
            else
              hod = ""
            end
          else
            hod = ""
          end

          if line_manager.present?
            current_row_value << line_manager.employee_code
            current_row_style << row_format
            current_row_type << :string
          else
            current_row_value << "-"
            current_row_style << row_format
            current_row_type << :string
          end

          if line_manager.present?
            current_row_value << line_manager.full_name
            current_row_style << row_format
            current_row_type << :string
          else
            current_row_value << "-"
            current_row_style << row_format
            current_row_type << :string
          end

          if hod.present?
            current_row_value << hod.employee_code
            current_row_style << row_format
            current_row_type << :string
          else
            current_row_value << "-"
            current_row_style << row_format
            current_row_type << :string
          end

          if hod.present?
            current_row_value << hod.full_name
            current_row_style << row_format
            current_row_type << :string
          else
            current_row_value << "-"
            current_row_style << row_format
            current_row_type << :string
          end

          current_row_value << employees.official_email
          current_row_style << row_format
          current_row_type << :string

          if objective.line_manager_appraisal_approval == "Approved"
            current_row_value << "Submitted"
            current_row_style << row_format
            current_row_type << :string
          else
            current_row_value << objective.line_manager_appraisal_approval
            current_row_style << pending_row_format
            current_row_type << :string
          end

          if objective.appraisal_status == "Approved"
            current_row_value << objective.appraisal_status
            current_row_style << row_format
            current_row_type << :string
          else
            current_row_value << objective.appraisal_status
            current_row_style << pending_row_format
            current_row_type << :string
          end

          if objective.hod_approval_status == "Approved"
            current_row_value << objective.hod_approval_status
            current_row_style << row_format
            current_row_type << :string
          else
            current_row_value << objective.hod_approval_status
            current_row_style << pending_row_format
            current_row_type << :string
          end

          appraisal = AppraisalComment.where(:employee_id => employees.id).last

          if appraisal.present?
            current_row_value << appraisal.employee_comments
            current_row_style << row_format
            current_row_type << :string

            current_row_value << appraisal.line_manager_comments
            current_row_style << row_format
            current_row_type << :string

            current_row_value << appraisal.functional
            current_row_style << row_format
            current_row_type << :string

            current_row_value << appraisal.leadership
            current_row_style << row_format
            current_row_type << :string

            current_row_value << appraisal.career_aspiration
            current_row_style << row_format
            current_row_type << :string
          else
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
          end

          total_emp_obj_avg_score = 0
          emp_obj_net_score = 0
          total_line_obj_avg_score = 0
          line_obj_net_score = 0
          Task.where(:id => objective.task_ids.try(:split, ',')).each do |t|
            total_emp_obj_avg_score = total_emp_obj_avg_score + (((t.weight.to_f)/100)*t.employee_rating.to_i)
            total_line_obj_avg_score = total_line_obj_avg_score + (((t.weight.to_f)/100)*t.line_manager_rating.to_i)
          end
          if total_emp_obj_avg_score > 5.0
            total_emp_obj_avg_score = 5.0
          end
          if total_line_obj_avg_score > 5.0
            total_line_obj_avg_score = 5.0
          end

          if employees.department_name == "Retail Stores"
            emp_obj_net_score = (total_emp_obj_avg_score).round(2)
            line_obj_net_score = (total_line_obj_avg_score).round(2)
          else
            emp_obj_net_score = (total_emp_obj_avg_score * 0.80).round(2)
            line_obj_net_score = (total_line_obj_avg_score * 0.80).round(2)
          end

          total_competency = Competency.all.count
          total_emp_comp_rating = 0
          emp_comp_net_score = 0
          total_line_comp_rating = 0
          line_comp_net_score = 0
          appraisals = []
          appraisal = Appraisal.where(:employee_id => employees.id, :fiscal_year_id => fiscal_year_id)
          appraisal.pluck(:title).uniq.each do |title|
            check = appraisal.where(:title => title)
            if check.count > 1
              appraisals << check.first
            else
              appraisals << check
            end
          end
          appraisals = appraisals.flatten
          appraisals.each do |t|
            total_emp_comp_rating = total_emp_comp_rating + t.line_manager_rating.to_i
            total_line_comp_rating = total_line_comp_rating + t.line_manager_rating.to_i
          end

          emp_comp_net_score = ((total_emp_comp_rating.to_f / total_competency)).round(2)
          line_comp_net_score = ((total_line_comp_rating.to_f / total_competency)).round(2)

          if emp_comp_net_score > 5.0
            emp_comp_net_score = 5.0
          end
          if line_comp_net_score > 5.0
            line_comp_net_score = 5.0
          end

          if employees.department_name == "Retail Stores"
            emp_comp_net_score = 0.0
            line_comp_net_score = 0.0
          else
            emp_comp_net_score = (emp_comp_net_score * 0.20).round(2)
            line_comp_net_score = (line_comp_net_score * 0.20).round(2)
          end

          total_emp_net_score = (emp_comp_net_score + emp_obj_net_score).round(2)
          total_line_net_score = (line_comp_net_score + line_obj_net_score).round(2)

          current_row_value << emp_obj_net_score
          current_row_style << row_format
          current_row_type << :string

          current_row_value << emp_comp_net_score
          current_row_style << row_format
          current_row_type << :string

          current_row_value << total_emp_net_score
          current_row_style << row_format
          current_row_type << :string

          emp_rating_scale = ""
          if total_emp_net_score > 0.0 && total_emp_net_score < 1.5
            emp_rating_scale = "Unsatisfactory (U)"
          elsif total_emp_net_score > 1.5 && total_emp_net_score < 2.5
            emp_rating_scale = "Needs Improvment (NI)"
          elsif total_emp_net_score > 2.5 && total_emp_net_score < 3.5
            emp_rating_scale = "Strong Performance (SP)"
          elsif total_emp_net_score > 3.5 && total_emp_net_score < 4.5
            emp_rating_scale = "Excellent Performance (EP)"
          else
            emp_rating_scale = "Outstanding Performance (OP)"
          end

          current_row_value << emp_rating_scale
          current_row_style << row_format
          current_row_type << :string

          current_row_value << line_obj_net_score
          current_row_style << row_format
          current_row_type << :string

          current_row_value << line_comp_net_score
          current_row_style << row_format
          current_row_type << :string

          current_row_value << total_line_net_score
          current_row_style << row_format
          current_row_type << :string

          line_rating_scale = ""
          if total_line_net_score < 1.5
            line_rating_scale = "Unsatisfactory (U)"
          elsif total_line_net_score > 1.5 && total_line_net_score < 2.5
            line_rating_scale = "Needs Improvment (NI)"
          elsif total_line_net_score > 2.5 && total_line_net_score < 3.5
            line_rating_scale = "Strong Performance (SP)"
          elsif total_line_net_score > 3.5 && total_line_net_score < 4.5
            line_rating_scale = "Excellent Performance (EP)"
          else
            line_rating_scale = "Outstanding Performance (OP)"
          end

          current_row_value << line_rating_scale
          current_row_style << row_format
          current_row_type << :string

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
        end

      end
      file_name = "appraisal_report"
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

end
