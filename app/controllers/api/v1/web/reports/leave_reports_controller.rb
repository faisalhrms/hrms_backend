class Api::V1::Web::Reports::LeaveReportsController < ApplicationController

	def leave_balance

		is_active = true
    if params[:is_active] == "Active"
      is_active = true
    else
      is_active = false
    end

    @company = Company.find (params[:company_id])
    date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}   
    @employees = Employee.where(:company_id => params[:company_id], :is_active => is_active, :excluded_from_reports => false).order('id DESC')
    @location_name = ""
    @branch_name = ""
    @department_name = ""
    @grade_name = ""
    @salary_unit_name = ""

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
      else
        @employees = Employee.where(:id => current_user.employee.id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
      end
    end
    #################### Hierarchical Permission ####################

    @employees = Employee.multiple_branch_data(@employees, current_user)

    if not params[:location_id].blank?
      @location_name = Location.find(params[:location_id]).name
      @employees = Employee.location_related_employee(@employees, params[:location_id].to_i)
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
      @grade_name = Grade.find(params[:grade_id]).name
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @salary_unit_name = SalaryUnit.find(params[:salary_unit_id]).name
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end
    @leave_allocations = LeaveAllocation.where(:employee_id => @employees.ids, :is_active => is_active, created_at: params[:start_date].to_date..params[:end_date].to_date).order('employee_id ASC')

    if @leave_allocations.count > 0

      if params[:report_type].to_i == 1
        render status:200, template: 'api/v1/web/reports/leave_reports/leave_balance'
      elsif params[:report_type].to_i == 2
        time = Time.now
        url_path = ""
        check_directory("#{Rails.public_path}/pdf")
        pdf = WickedPdf.new.pdf_from_string(
          render_to_string("api/v1/web/reports/leave_reports/leave_balance", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
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
        file_name = "leave_balance"
        url_path = save_pdf_file(pdf, file_name)

        render json: {message: "Pdf Created", path: url_path}
      elsif params[:report_type].to_i == 3
        time = Time.now
        book = Axlsx::Package.new
        check_directory("#{Rails.public_path}/excel")
        wb = book.workbook
        sheet = wb.add_worksheet(name: 'Leave Balance')
        book.use_autowidth = false
        sheet.sheet_view do |view|
          view.show_outline_symbols = true
        end
        book.use_autowidth = true

        header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
        bold_column_format = wb.styles.add_style(:bg_color => "e5e7e4", :fg_color=> "000000", :sz => 14, :height => 20, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
        old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
        even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
        row_count = 0
        sheet.add_row ["Sr #", "Emp Code", "NAME", "Grade", "Designation", "Department", "Job Title", "Leave Year", "Leave Type", "Allocated Balance", "Used Balance", "Remaining Balance", "Location", "Branch"], :style => header_style

        count = 0

        @leave_allocations.each do |leave_allocation|            
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

          current_row_value << leave_allocation.employee_code.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << leave_allocation.employee_name
          current_row_style << row_format
          current_row_type << :string
          
          current_row_value << leave_allocation.grade_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << leave_allocation.designation_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << leave_allocation.department_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << leave_allocation.job_title_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << leave_allocation.leave_year_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << leave_allocation.leave_type_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << leave_allocation.allocated_quota
          current_row_style << row_format
          current_row_type << :float

          current_row_value << leave_allocation.used_quota
          current_row_style << row_format
          current_row_type << :float

          current_row_value << leave_allocation.remaining_quota
          current_row_style << row_format
          current_row_type << :float

          current_row_value << leave_allocation.location_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << leave_allocation.branch_name
          current_row_style << row_format
          current_row_type << :string

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
        end

        file_name = "leave_balance"
        url_path = save_excel_file(book, file_name)
        render json: {message: "Excel Created", path: url_path}
      end
     else
      render json: {errors: "No Record Found"}, status: :unprocessable_entity
    end
  end

  def leave_history

    is_active = true
    if params[:is_active] == "Active"
      is_active = true
    else
      is_active = false
    end

    @company = Company.find (params[:company_id])
    date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
    @employees = Employee.where(:company_id => params[:company_id], :is_active => is_active, :excluded_from_reports => false).order('id DESC')
    @location_name = ""
    @branch_name = ""
    @department_name = ""
    @grade_name = ""
    @salary_unit_name = ""

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
      else
        @employees = Employee.where(:id => current_user.employee.id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
      end
    end
    #################### Hierarchical Permission ####################

    @employees = Employee.multiple_branch_data(@employees, current_user)

    if not params[:location_id].blank?
      @location_name = Location.find(params[:location_id]).name
      @employees = Employee.location_related_employee(@employees, params[:location_id].to_i)
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
      @grade_name = Grade.find(params[:grade_id]).name
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @salary_unit_name = SalaryUnit.find(params[:salary_unit_id]).name
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end
    if params[:leave_type_id].present?
      leave_type_names = LeaveType.where(:id => params[:leave_type_id]).pluck(:short_name).uniq
    else
      leave_type_names = LeaveType.all.pluck(:short_name).uniq
    end

    if @employees.count > 0

      if params[:report_type].to_i == 1
        render status:200, template: 'api/v1/web/reports/leave_reports/leave_balance'
      elsif params[:report_type].to_i == 2
        time = Time.now
        url_path = ""
        check_directory("#{Rails.public_path}/pdf")
        pdf = WickedPdf.new.pdf_from_string(
          render_to_string("api/v1/web/reports/leave_reports/leave_balance", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
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
        file_name = "leave_balance"
        url_path = save_pdf_file(pdf, file_name)

        render json: {message: "Pdf Created", path: url_path}
      elsif params[:report_type].to_i == 3
        time = Time.now
        book = Axlsx::Package.new
        check_directory("#{Rails.public_path}/excel")
        wb = book.workbook
        sheet = wb.add_worksheet(name: 'Leave Balance')
        book.use_autowidth = false
        sheet.sheet_view do |view|
          view.show_outline_symbols = true
        end
        book.use_autowidth = true

        header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
        bold_column_format = wb.styles.add_style(:bg_color => "e5e7e4", :fg_color=> "000000", :sz => 14, :height => 20, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
        old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
        even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
        row_count = 0
        result = (params[:start_date].to_date..params[:end_date].to_date).map { |x| Date::MONTHNAMES[x.to_date.strftime("%m").to_i].to_s + " Used" }.uniq
        sheet.add_row ["Sr #", "Emp Code", "NAME", "Grade", "Designation", "Department", "Job Title", "Location", "Branch", "Leave Type"] + ["Total Allocation"] + result + ["Total Used"], :style => header_style
        months = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date.strftime("%m-%Y")}.uniq
        count = 0
        @employees.each do |employee|

          row_format = old_row_format

          if count.even? == true
            row_format = even_row_format
          else
            row_format = old_row_format
          end
          leave_type_names.each do |short_name|
            leave_type_ids = LeaveType.where(:short_name => short_name).pluck(:id).uniq
             count = count + 1

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

                current_row_value << employee.department_name
                current_row_style << row_format
                current_row_type << :string

                current_row_value << employee.job_title_name
                current_row_style << row_format
                current_row_type << :string

                current_row_value << employee.location_name
                current_row_style << row_format
                current_row_type << :string

                current_row_value << employee.branch_name
                current_row_style << row_format
                current_row_type << :string

                current_row_value << LeaveType.where(:short_name => short_name).last.name
                current_row_style << row_format
                current_row_type << :string

            total_allocation = 0.0
              if short_name == "CPL"
                leave_history = LeaveTransactionHistory.where(:employee_id => employee.id, :leave_type_id => leave_type_ids, :transaction_date => params[:start_date].to_date..params[:end_date].to_date , :transaction_type => "Earned")
                if leave_history.present?
                  total_allocation = total_allocation + leave_history.sum(:quota_transaction)
                else
                  total_allocation = total_allocation + 0.0
                end
              else
                leave_allocation_data = LeaveAllocation.where(:employee_id => employee.id, :leave_type_id => leave_type_ids, :is_active => true)
                if leave_allocation_data.present?
                  total_allocation = total_allocation + leave_allocation_data.sum(:allocated_quota)
                else
                  total_allocation = total_allocation + 0.0
                end
              end

            current_row_value << total_allocation
            current_row_style << row_format
            current_row_type << :string

             total = 0.0
                months.each do |month|
                  leave_request = LeaveRequest.where(:employee_id => employee.id, :leave_type_id => leave_type_ids, :start_date => "01-#{month}".to_date.beginning_of_month.."01-#{month}".to_date.end_of_month, :request_status => "Availed")
                  if leave_request.present?
                    total = total + leave_request.sum(:request_count)
                    current_row_value << leave_request.sum(:request_count)
                    current_row_style << row_format
                    current_row_type << :float
                  else
                    current_row_value << 0.0
                    current_row_style << row_format
                    current_row_type << :float
                  end
                end

             current_row_value << total
             current_row_style << row_format
             current_row_type << :string

                sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
          end
        end
        #
        # sheet = wb.add_worksheet(name: 'Leave Allocation')
        # book.use_autowidth = false
        # sheet.sheet_view do |view|
        #   view.show_outline_symbols = true
        # end
        # book.use_autowidth = true
        #
        # header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
        # bold_column_format = wb.styles.add_style(:bg_color => "e5e7e4", :fg_color=> "000000", :sz => 14, :height => 20, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
        # old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
        # even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
        # row_count = 0
        # result = (params[:start_date].to_date..params[:end_date].to_date).map { |x| Date::MONTHNAMES[x.to_date.strftime("%m").to_i] }.uniq
        # sheet.add_row ["Sr #", "Emp Code", "NAME", "Grade", "Designation", "Department", "Job Title", "Location", "Branch", "Leave Type"] + result + ["Total"], :style => header_style
        # months = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date.strftime("%m")}.uniq
        # count1 = 0
        # @employees.each do |employee|
        #
        #   row_format = old_row_format
        #
        #   if count1.even? == true
        #     row_format = even_row_format
        #   else
        #     row_format = old_row_format
        #   end
        #   leave_type_names.each do |short_name|
        #     leave_type_ids = LeaveType.where(:short_name => short_name).pluck(:id).uniq
        #     if leave_type_ids.present?
        #       count1 = count1 + 1
        #
        #       current_row_value = []
        #       current_row_style = []
        #       current_row_type = []
        #
        #       current_row_value << count1
        #       current_row_style << row_format
        #       current_row_type << :integer
        #
        #       current_row_value << employee.employee_code.to_i
        #       current_row_style << row_format
        #       current_row_type << :integer
        #
        #       current_row_value << employee.full_name
        #       current_row_style << row_format
        #       current_row_type << :string
        #
        #       current_row_value << employee.grade_name
        #       current_row_style << row_format
        #       current_row_type << :string
        #
        #       current_row_value << employee.designation_name
        #       current_row_style << row_format
        #       current_row_type << :string
        #
        #       current_row_value << employee.department_name
        #       current_row_style << row_format
        #       current_row_type << :string
        #
        #       current_row_value << employee.job_title_name
        #       current_row_style << row_format
        #       current_row_type << :string
        #
        #       current_row_value << employee.location_name
        #       current_row_style << row_format
        #       current_row_type << :string
        #
        #       current_row_value << employee.branch_name
        #       current_row_style << row_format
        #       current_row_type << :string
        #
        #       current_row_value << LeaveType.where(:short_name => short_name).last.name
        #       current_row_style << row_format
        #       current_row_type << :string
        #
        #       total = 0.0
        #       months.each do |month|
        #         leave_request = LeaveTransactionHistory.where(:employee_id => employee.id, :leave_type_id => leave_type_ids, :transaction_date => "01-#{month}-#{params[:start_date].to_date.strftime("%Y")}".to_date.beginning_of_month.."01-#{month}-#{params[:start_date].to_date.strftime("%Y")}".to_date.end_of_month, :transaction_type => "Earned")
        #         if leave_request.present?
        #           total = total + leave_request.sum(:quota_transaction)
        #           current_row_value << leave_request.sum(:quota_transaction)
        #           current_row_style << row_format
        #           current_row_type << :float
        #         else
        #           current_row_value << 0.0
        #           current_row_style << row_format
        #           current_row_type << :float
        #         end
        #       end
        #
        #       current_row_value << total
        #       current_row_style << row_format
        #       current_row_type << :string
        #
        #       sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
        #     end
        #   end
        # end

        file_name = "leave_history"
        url_path = save_excel_file(book, file_name)
        render json: {message: "Excel Created", path: url_path}
      end
    else
      render json: {errors: "No Record Found"}, status: :unprocessable_entity
    end
  end

  def leave_balance_detail

    @is_active = true
    if params[:is_active] == "Active"
      @is_active = true
    else
      @is_active = false
    end

    @company = Company.find (params[:company_id])
    date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}   
    @employees = Employee.where(:company_id => params[:company_id], :is_active => @is_active, :excluded_from_reports => false).order('id DESC')
    @location_name = ""
    @branch_name = ""
    @department_name = ""
    @grade_name = ""
    @salary_unit_name = ""

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => @is_active, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => @is_active, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => @is_active, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => @is_active, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => @is_active, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => @is_active, :excluded_from_reports => false).order('id DESC')
      else
        @employees = Employee.where(:id => current_user.employee.id, :is_active => @is_active, :excluded_from_reports => false).order('id DESC')
      end
    end

    @employees = Employee.multiple_branch_data(@employees, current_user)

    #################### Hierarchical Permission ####################

    if not params[:location_id].blank?
      @location_name = Location.find(params[:location_id]).name
      @employees = Employee.location_related_employee(@employees, params[:location_id].to_i)
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
      @grade_name = Grade.find(params[:grade_id]).name
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @salary_unit_name = SalaryUnit.find(params[:salary_unit_id]).name
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end

    if @employees.count > 0
      if params[:report_type].to_i == 1
        render status:200, template: 'api/v1/web/reports/leave_reports/leave_balance_detail'
      elsif params[:report_type].to_i == 3
        time = Time.now
        book = Axlsx::Package.new
        check_directory("#{Rails.public_path}/excel")
        wb = book.workbook
        sheet = wb.add_worksheet(name: 'Leave Balance')
        book.use_autowidth = false
        sheet.sheet_view do |view|
          view.show_outline_symbols = true
        end
        book.use_autowidth = true

        header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
        bold_column_format = wb.styles.add_style(:bg_color => "e5e7e4", :fg_color=> "000000", :sz => 14, :height => 20, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
        old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
        even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
        row_count = 0

        sheet.add_row ["Sr #", "Emp Code", "Name", "Grade", "Designation", "Department", "Location", "Branch", "DOJ", "Sick", "Casual", "Annual", "Leave Encashment Balance", "Availed Leaves", "Leave Quota", "CPL Quota", "CPL Availed", "CPL Balance"], :style => header_style

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

          current_row_value << employee.department_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.location_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << employee.branch_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(employee.joining_date)
          current_row_style << row_format
          current_row_type << :string

          leave_types     = LeaveType.where(:is_active => true, :is_composite => false).order('sort_order ASC')
          sick_leaves     = leave_types.where(:short_name => "SL")
          casual_leaves   = leave_types.where(:short_name => "CL")
          annual_leaves   = leave_types.where(:short_name => "AL")
          cpl_leaves      = leave_types.where(:short_name => "CPL")

          sick_leave_allocation 	= LeaveAllocation.find_by(:employee_id => employee.id, :is_active => @is_active, :leave_type_id => sick_leaves.collect(&:id))
          casual_leave_allocation = LeaveAllocation.find_by(:employee_id => employee.id, :is_active => @is_active, :leave_type_id => casual_leaves.collect(&:id))
          annual_leave_allocation = LeaveAllocation.find_by(:employee_id => employee.id, :is_active => @is_active, :leave_type_id => annual_leaves.collect(&:id))
          cpl_leave_allocation 		= LeaveAllocation.find_by(:employee_id => employee.id, :is_active => @is_active, :leave_type_id => cpl_leaves.collect(&:id))

          if not sick_leave_allocation.nil?
            sick_balance          = sick_leave_allocation.remaining_quota
            sick_used_quota       = sick_leave_allocation.used_quota
            sick_allocated_quota  = sick_leave_allocation.allocated_quota
          else
            sick_balance          = 0
            sick_used_quota       = 0
            sick_allocated_quota  = 0
          end

          if not casual_leave_allocation.nil?
            casual_balance          = casual_leave_allocation.remaining_quota
            casual_used_quota       = casual_leave_allocation.used_quota
            casual_allocated_quota  = casual_leave_allocation.allocated_quota
          else
            casual_balance          = 0
            casual_used_quota       = 0
            casual_allocated_quota  = 0
          end

          if not annual_leave_allocation.nil?
            annual_balance          = annual_leave_allocation.remaining_quota
            annual_used_quota       = annual_leave_allocation.used_quota
            annual_allocated_quota  = annual_leave_allocation.allocated_quota
          else
            annual_balance          = 0
            annual_used_quota       = 0
            annual_allocated_quota  = 0
          end

          if not cpl_leave_allocation.nil?
            cpl_quota   = cpl_leave_allocation.allocated_quota
            cpl_availed = cpl_leave_allocation.used_quota
            cpl_balance = cpl_leave_allocation.remaining_quota
          else
            cpl_quota   = 0
            cpl_availed = 0
            cpl_balance = 0
          end

          total_availed_leaves  = sick_used_quota + casual_used_quota + annual_used_quota
          total_allocated_quota = sick_allocated_quota + casual_allocated_quota + annual_allocated_quota
          
          leave_encashment_balance = 0
          if not sick_leave_allocation.nil?
            if sick_leave_allocation.leave_type.encashment == true
              leave_encashment_balance = leave_encashment_balance + sick_leave_allocation.remaining_quota
            end
          end

          if not casual_leave_allocation.nil?
            if casual_leave_allocation.leave_type.encashment == true
              leave_encashment_balance = leave_encashment_balance + casual_leave_allocation.remaining_quota
            end
          end

          if not annual_leave_allocation.nil?
            if annual_leave_allocation.leave_type.encashment == true
              leave_encashment_balance = leave_encashment_balance + annual_leave_allocation.remaining_quota
            end
          end

          current_row_value << sick_balance.round(2)
          current_row_style << row_format
          current_row_type << :float

          current_row_value << casual_balance.round(2)
          current_row_style << row_format
          current_row_type << :float

          current_row_value << annual_balance.round(2)
          current_row_style << row_format
          current_row_type << :float

          current_row_value << leave_encashment_balance.round(2)
          current_row_style << row_format
          current_row_type << :float

          current_row_value << total_availed_leaves.round(2)
          current_row_style << row_format
          current_row_type << :float

          current_row_value << total_allocated_quota.round(2)
          current_row_style << row_format
          current_row_type << :float

          current_row_value << cpl_quota.round(2)
          current_row_style << row_format
          current_row_type << :float

          current_row_value << cpl_availed.round(2)
          current_row_style << row_format
          current_row_type << :float

          current_row_value << cpl_balance.round(2)
          current_row_style << row_format
          current_row_type << :float

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
        end

        file_name = "leave_balance"
        url_path = save_excel_file(book, file_name)
        render json: {message: "Excel Created", path: url_path}
      end
     else
      render json: {errors: "No Record Found"}, status: :unprocessable_entity
    end
  end

  def leave_encashment

  	is_active = true
    if params[:is_active] == "Active"
      is_active = true
    else
      is_active = false
    end

    @company = Company.find (params[:company_id])
    date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}   
    @employees = Employee.where(:company_id => params[:company_id], :is_active => is_active, :excluded_from_reports => false).order('id DESC')
    @location_name = ""
    @branch_name = ""
    @department_name = ""
    @grade_name = ""
    @salary_unit_name = ""

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
      else
        @employees = Employee.where(:id => current_user.employee.id, :is_active => is_active, :excluded_from_reports => false).order('id DESC')
      end
    end

    @employees = Employee.multiple_branch_data(@employees, current_user)

    #################### Hierarchical Permission ####################

    if not params[:location_id].blank?
      @location_name = Location.find(params[:location_id]).name
      @employees = Employee.location_related_employee(@employees, params[:location_id].to_i)
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
      @grade_name = Grade.find(params[:grade_id]).name
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].to_i)
    end
    if not params[:salary_unit_id].blank?
      @salary_unit_name = SalaryUnit.find(params[:salary_unit_id]).name
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
    end

    leave_types = LeaveType.where(:encashment => true, :is_active => true)
    @leave_allocations = LeaveAllocation.where(:employee_id => @employees.collect(&:id).uniq, :leave_type_id => leave_types.collect(&:id).uniq, :is_active => is_active).order('employee_id ASC')

    if @leave_allocations.count > 0
      if params[:report_type].to_i == 1
        render status:200, template: 'api/v1/web/reports/leave_reports/leave_encashment'
      elsif params[:report_type].to_i == 2
        time = Time.now
        url_path = ""
        check_directory("#{Rails.public_path}/pdf")
        pdf = WickedPdf.new.pdf_from_string(
          render_to_string("api/v1/web/reports/leave_reports/leave_encashment", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
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
        file_name = "leave_encashment"
        url_path = save_pdf_file(pdf, file_name)

        render json: {message: "Pdf Created", path: url_path}
      elsif params[:report_type].to_i == 3
        time = Time.now
        book = Axlsx::Package.new
        check_directory("#{Rails.public_path}/excel")
        wb = book.workbook
        sheet = wb.add_worksheet(name: 'Leave Encashment')
        book.use_autowidth = false
        sheet.sheet_view do |view|
          view.show_outline_symbols = true
        end
        book.use_autowidth = true

        header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
        bold_column_format = wb.styles.add_style(:bg_color => "e5e7e4", :fg_color=> "000000", :sz => 14, :height => 20, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
        old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
        even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
        row_count = 0
        sheet.add_row ["Sr #", "Emp Code", "NAME", "Grade", "Designation", "Department", "Job Title", "DOJ", "Leave Type", "Encashment", "Location", "Branch"], :style => header_style

        count = 0

        @leave_allocations.each do |leave_allocation|            
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

          if leave_allocation.employee.on_probation == false
            if leave_allocation.employee.employee_type_name != "Contractual"
              current_row_value << leave_allocation.employee_code.to_i
              current_row_style << row_format
              current_row_type << :integer

              current_row_value << leave_allocation.employee_name
              current_row_style << row_format
              current_row_type << :string
              
              current_row_value << leave_allocation.grade_name
              current_row_style << row_format
              current_row_type << :string

              current_row_value << leave_allocation.designation_name
              current_row_style << row_format
              current_row_type << :string

              current_row_value << leave_allocation.department_name
              current_row_style << row_format
              current_row_type << :string

              current_row_value << leave_allocation.job_title_name
              current_row_style << row_format
              current_row_type << :string

              current_row_value << ReportFormat.date_format(leave_allocation.employee.joining_date)
              current_row_style << row_format
              current_row_type << :string

              current_row_value << leave_allocation.leave_type_name
              current_row_style << row_format
              current_row_type << :string

              current_row_value << leave_allocation.remaining_quota
              current_row_style << row_format
              current_row_type << :float

              current_row_value << leave_allocation.location_name
              current_row_style << row_format
              current_row_type << :string

              current_row_value << leave_allocation.branch_name
              current_row_style << row_format
              current_row_type << :string

              sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
            end
          end            
        end

        file_name = "leave_encashment"
        url_path = save_excel_file(book, file_name)
        render json: {message: "Excel Created", path: url_path}
      end
     else
      render json: {errors: "No Record Found"}, status: :unprocessable_entity
    end
  end

  def leave_ledger

    @is_active = true
    if params[:is_active] == "Active"
      @is_active = true
    else
      @is_active = false
    end

    @company = Company.find (params[:company_id])
    date_range = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}   
    @leave_requests = LeaveRequest.where(:company_id => params[:company_id], :created_at => params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day).order('id ASC')
    @employees = Employee.where(:company_id => params[:company_id], :is_active => @is_active, :excluded_from_reports => false).order('id DESC')
    @location_name = ""
    @branch_name = ""
    @department_name = ""
    @grade_name = ""
    @salary_unit_name = ""
    @view_date_range  = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
    @months = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date.strftime("%B")}.uniq
    @years = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date.strftime("%B-%Y")}.uniq

    @year_date_ranges = []
    Array.new(@years.count).each_index do |index|
      if index == 0
        new_start_date  = params[:start_date].to_date.beginning_of_year.end_of_day
        new_end_date    = params[:end_date].to_date.beginning_of_year.end_of_month
        new_date_range  = (new_start_date.to_date..new_end_date.to_date).to_a.map{|x| x.to_date}
        @year_date_ranges << new_date_range
      else
        new_start_date  = (params[:start_date].to_date.beginning_of_year + index.month).beginning_of_month
        new_end_date    = (params[:end_date].to_date.beginning_of_year + index.month).end_of_month
        new_date_range  = (new_start_date.to_date..new_end_date.to_date).to_a.map{|x| x.to_date}
        @year_date_ranges << new_date_range
      end
    end

    #################### Hierarchical Permission ####################
    if current_user.is_location_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :is_active => @is_active, :excluded_from_reports => false).order('id DESC')
      @leave_requests = @leave_requests.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.is_branch_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :is_active => @is_active, :excluded_from_reports => false).order('id DESC')
      @leave_requests = @leave_requests.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.is_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :is_active => @is_active, :excluded_from_reports => false).order('id DESC')
      @leave_requests = @leave_requests.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.all_company_department == true
      @employees = Employee.where(:company_id => current_user.company_id, :department_id => current_user.employee.department_id, :is_active => @is_active, :excluded_from_reports => false).order('id DESC')
      @leave_requests = @leave_requests.where(:employee_id => @employees.collect(&:id).uniq)
    elsif current_user.is_sub_department_head == true
      @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :is_active => @is_active, :excluded_from_reports => false).order('id DESC')
      @leave_requests = @leave_requests.where(:employee_id => @employees.collect(&:id).uniq)
    elsif not current_user.employee.nil?
      if current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq, :is_active => @is_active, :excluded_from_reports => false).order('id DESC')
        @leave_requests = @leave_requests.where(:employee_id => @employees.collect(&:id).uniq)
      else
        @employees = Employee.where(:id => current_user.employee.id, :is_active => @is_active, :excluded_from_reports => false).order('id DESC')
        @leave_requests = @leave_requests.where(:employee_id => @employees.collect(&:id).uniq) 
      end
    end

    @employees = Employee.multiple_branch_data(@employees, current_user)
    
    #################### Hierarchical Permission ####################

    if not params[:location_id].blank?
      @location_name = Location.find(params[:location_id]).name
      @employees = Employee.location_related_employee(@employees, params[:location_id].to_i)
      @leave_requests = @leave_requests.where(:employee_id => @employees.collect(&:id).uniq)
    end
    if not params[:branch_id].blank?
      @branch_name = Branch.find(params[:branch_id]).name
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
      @leave_requests = @leave_requests.where(:employee_id => @employees.collect(&:id).uniq)
    end
    if not params[:department_id].blank?
      @department_name = Department.find(params[:department_id]).name
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
      @leave_requests = @leave_requests.where(:employee_id => @employees.collect(&:id).uniq)
    end
    if not params[:designation_id].blank?
      @employees = Employee.designation_related_employee(@employees, params[:designation_id].to_i)
      @leave_requests = @leave_requests.where(:employee_id => @employees.collect(&:id).uniq)
    end
    if not params[:job_title_id].blank?
      @employees = Employee.job_title_related_employee(@employees, params[:job_title_id].to_i)
      @leave_requests = @leave_requests.where(:employee_id => @employees.collect(&:id).uniq)
    end
    if not params[:grade_id].blank?
      @grade_name = Grade.find(params[:grade_id]).name
      @employees = Employee.grade_related_employee(@employees, params[:grade_id].to_i)
      @leave_requests = @leave_requests.where(:employee_id => @employees.collect(&:id).uniq)
    end
    if not params[:salary_unit_id].blank?
      @salary_unit_name = SalaryUnit.find(params[:salary_unit_id]).name
      @employees = Employee.salary_unit_related_employee(@employees, params[:salary_unit_id].to_i)
      @leave_requests = @leave_requests.where(:employee_id => @employees.collect(&:id).uniq)
    end
    if not params[:cost_center_id].blank?
      @employees = Employee.cost_center_related_employee(@employees, params[:cost_center_id].to_i)
      @leave_requests = @leave_requests.where(:employee_id => @employees.collect(&:id).uniq)
    end

    if @leave_requests.count > 0
      if params[:report_type].to_i == 1
        render status:200, template: 'api/v1/web/reports/leave_reports/leave_ledger'
      elsif params[:report_type].to_i == 2
        time = Time.now
        url_path = ""
        check_directory("#{Rails.public_path}/pdf")
        pdf = WickedPdf.new.pdf_from_string(
          render_to_string("api/v1/web/reports/leave_reports/leave_ledger", formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf]), formats: [:pdf, :html], layout: false, handlers: [:raw, :erb, :html, :builder, :ruby, :pdf],
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
        file_name = "leave_ledger"
        url_path = save_pdf_file(pdf, file_name)

        render json: {message: "Pdf Created", path: url_path}
      elsif params[:report_type].to_i == 3
        time = Time.now
        book = Axlsx::Package.new
        check_directory("#{Rails.public_path}/excel")
        wb = book.workbook
        sheet = wb.add_worksheet(name: 'Leave Ledger')
        book.use_autowidth = false
        sheet.sheet_view do |view|
          view.show_outline_symbols = true
        end
        book.use_autowidth = true

        header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
        bold_column_format = wb.styles.add_style(:bg_color => "e5e7e4", :fg_color=> "000000", :sz => 14, :height => 20, :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
        old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
        even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
        row_count = 0
        sheet.add_row ["Sr #", "Emp Code", "NAME", "Grade", "Designation", "Department", "Job Title", "Apply Date", "From Date", "To Date", "Leave Type", "Total Leaves", "Leave Category", "Status", "Location", "Branch"], :style => header_style

        count = 0

        @leave_requests.each do |leave_request|
          count = count + 1
          row_format = old_row_format 
          
          current_row_value = []
          current_row_style = []
          current_row_type = []

          current_row_value << count
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << leave_request.employee_code.to_i
          current_row_style << row_format
          current_row_type << :integer

          current_row_value << leave_request.employee_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << leave_request.grade_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << leave_request.designation_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << leave_request.department_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << leave_request.job_title_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(leave_request.created_at)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(leave_request.start_date)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << ReportFormat.date_format(leave_request.end_date)
          current_row_style << row_format
          current_row_type << :string

          current_row_value << leave_request.leave_type_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << leave_request.request_count
          current_row_style << row_format
          current_row_type << :float

          current_row_value << leave_request.leave_category
          current_row_style << row_format
          current_row_type << :string

          current_row_value << leave_request.request_status
          current_row_style << row_format
          current_row_type << :string

          current_row_value << leave_request.location_name
          current_row_style << row_format
          current_row_type << :string

          current_row_value << leave_request.branch_name
          current_row_style << row_format
          current_row_type << :string

          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
          row_count = row_count + 1
        end

        file_name = "leave_ledger"
        url_path = save_excel_file(book, file_name)
        render json: {message: "Excel Created", path: url_path}
      end
     else
      render json: {errors: "No Record Found"}, status: :unprocessable_entity
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