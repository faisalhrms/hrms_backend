Rails.application.routes.draw do

  get 'tax_certificates/filter_data'

  mount Apidoco::Engine, at: "/docs"

  devise_for :users, path: '/api/users', controllers: {
    sessions: 'api/v1/custom_devise/sessions'
  }
  namespace :api, defaults: {format: 'json'} do
    scope module: :v1 do
      namespace :web, defaults: {format: 'json'} do

        post 'send_emails' => 'notifications#send_shopify_emails'
        ################# Admin Tool #################
        scope module: :admin_tool do
          resources :roles,            :except => [:new, :edit] do
            collection do
              get   :filter_data
            end
          end
          resources :email_configrations,            :except => [:new, :edit] do
            collection do
              get   :filter_data
            end
          end
          resources :email_templates,                :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :manual_email_template
            end
          end
          resources :email_executions,            :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :execute_email
            end
          end
          resources :sms_configrations,            :except => [:new, :edit] do
            collection do
              get   :filter_data
            end
          end
          resources :sms_templates,            :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :manual_sms_template
            end
          end
          resources :sms_executions,            :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :execute_sms
            end
          end
          resources :system_settings,                :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :arrear_setting
              get   :leave_request_setting
              get   :get_confirmation_due_date
            end
          end
          resources :holiday_managements, :except => [:new, :edit] do
            collection do
              get   :filter_data
            end
          end
          resources :documents, :except => [:new, :edit] do
            collection do
              get   :filter_data
              post  :upload_file
            end
          end
          resources :request_flows, :except => [:new, :edit] do
            collection do
              get     :filter_data
              delete  :destroy_request_flow_detail
            end
          end
          resources :activity_streams, except: [:new, :edit, :index, :show, :update, :destroy, :create] do
            collection do
              get :create_log
              get :selected_activity_stream
            end
          end
        end

        ################# Employee Management #################
        scope module: :employee_management do
          resources :employees,            :except => [:new, :edit, :index, :destroy] do
            collection do
              get     :fetch_employees
              get     :fetch_companies
              get     :fetch_locations
              get     :fetch_departments
              get     :fetch_designations
              get     :filter_data
              get     :filter_langguage_date
              get     :get_employees
              get     :fetch_employee
              get     :fetch_location
              get     :filter_location_data
              get     :filter_combine_data
              get     :filter_permanent_data
              get     :filter_branch_data
              get     :filter_department_data
              get     :filter_incharge_data
              get     :download_sample_csv_file
              get     :get_subordinate_employees
              get     :filter_subordinate_employee
              get     :employee_combine_information
              get     :get_updated_confimration_due_date
              post    :upload_logo
              post    :save_training
              post    :save_relative
              post    :save_reference
              post    :save_experience
              post    :save_membership
              post    :save_document
              post    :save_next_of_kin
              post    :current_employee
              post    :download_employee_cards
              post    :archive_employee
              post    :line_manager_list
              post    :head_of_department_list
              post    :save_certification
              post    :save_qualification
              post    :combine_filter_data
              post    :subordinate_employee
              post    :bulk_import_employee
              post    :employee_change_list
              post    :upload_training_attachment
              post    :download_employee_info_file
              post    :upload_experience_attachment
              post    :upload_qualification_attachment
              post    :upload_vaccine
              post    :upload_certification_attachment
              post    :upload_membership_attachment
              post    :upload_documents_attachment
              delete  :remove_training
              delete  :remove_relative
              delete  :remove_reference
              delete  :remove_experience
              delete  :remove_next_of_kin
              delete  :remove_qualification
              delete  :remove_certification
              delete  :remove_membership
              delete  :remove_document
            end
          end
          resources :temporary_staffs, :except => [:new, :edit, :index, :destroy] do
            collection do
              get      :download_temp_staff
              get      :converted_to_employee
              post     :save_attendance
              post     :fetch_attendance
              post     :temporary_staff_index
            end
          end
          resources :internees, :except => [:new, :edit, :index, :destroy] do
            collection do
              get      :converted_to_employee
              post     :internee_index
            end
          end
          resources :employee_transactions,  :except => [:new, :create, :edit, :update, :delete] do
            collection do
              post    :save_employee_change
            end
          end
        end

        ################# General Setting #################

        scope module: :general_setting do
          resources :restrict_leaves, except: :edit
          resources :asset_types,         :except => [:new, :edit] do
            collection do
              get   :active_list
            end
          end
          resources :qualification_programs,         :except => [:new, :edit] do
            collection do
              get   :active_list
            end
          end
          resources :employee_types,         :except => [:new, :edit] do
            collection do
              get   :active_list
            end
          end
          resources :certification_types, :except => [:new, :edit] do
            collection do
              get   :active_list
            end
          end
          resources :qualfication_types,  :except => [:new, :edit] do
            collection do
              get   :active_list
            end
          end
          resources :relationships,       :except => [:new, :edit] do
            collection do
              get   :active_list
            end
          end
          resources :training_types,      :except => [:new, :edit] do
            collection do
              get   :active_list
            end
          end
          resources :specializations,     :except => [:new, :edit] do
            collection do
              get   :active_list
            end
          end
          resources :left_reasons,        :except => [:new, :edit] do
            collection do
              get   :active_list
            end
          end
          resources :religion_sects,      :except => [:new, :edit]
          resources :religions,           :except => [:new, :edit]
          resources :general_types, :except => [:new, :edit] do
            collection do
              get   :filter_data
            end
          end
        end

        ################# Administrative Structure #################

        scope module: :administrative_structure do
          resources :divisions,         :except => [:new, :edit] do
            collection do
              get     :filter_data
            end
          end
          resources :districts,         :except => [:new, :edit] do
            collection do
              get     :filter_data
            end
          end
          resources :tehsils,           :except => [:new, :edit] do
            collection do
              get     :filter_data
            end
          end
        end

        ################# Leave Management #################

        scope module: :leave_management do
          resources :leave_approval_requests,   :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :cancel_request
              get   :approved_request
              post   :syed_talal_leave_request
              get   :syed_talal_leave_request
            end
          end
          resources :leave_requests,            :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :cancel_request
              get   :revert_request
              get   :approved_request
              get   :employee_leave_quota
              post  :bulk_index
              post  :bulk_save
              post  :bulk_export
              post  :calculate_leave
            end
          end
          resources :cpl_earnings,            :except => [:new, :edit] do
            collection do
              get   :get_cpl_earning
              get   :filter_data
              get   :cancel_request
              get   :revert_request
              get   :approved_request
              post  :bulk_index
            end
          end
          resources :leave_types,         :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :non_composite
              get   :inactive_leave_years
              get   :filter_location_data
              get   :filter_employee_leave_type
            end
          end
          resources :leave_years,         :except => [:new, :edit] do
            collection do
              get   :filter_data
            end
          end
          resources :leave_allocations,   :except => [:new, :edit, :update] do
            collection do
              get   :filter_data
              get   :activate_leave
              get   :deactivate_leave
              get   :employee_leave_ledger
              get   :allocated_monthly_leave
              post  :bulk_export
              post  :adjust_leave_balance
              post  :leave_allocation_list
              post  :activate_allocated_leaves
              post  :save_bulk_leave_allocation
              post  :deactivate_allocated_leaves
            end
          end
        end

        ################# Official Duty Management #################

        scope module: :official_duty_management do
          resources :official_duty_approval_requests,   :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :cancel_request
              get   :approved_request
            end
          end
          resources :official_duty_requests,            :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :filter_data1
              get   :cancel_request
              get   :revert_request
              get   :approved_request
              post  :bulk_index
              post  :bulk_export
              post  :calculate_official_duty
              post  :calculate_bulk_official_duty
              post  :save_bulk_official_duty
            end
          end
        end

        ################# Roster Management #################

        scope module: :roster_management do
          resources :time_slots,   :except => [:new, :edit] do
            collection do
              get       :filter_data
              get       :branch_related_time_slots
              get       :location_related_time_slots
              get       :employee_related_time_slots
              get       :flexi_branch_related_time_slots
              post      :bulk_save
              delete    :destroy_break_time
            end
          end
          resources :sub_time_slots,   :except => [:new, :edit] do
            collection do
              get       :filter_data
              get       :branch_related_sub_time_slots
              get       :location_related_sub_time_slots
              post      :bulk_save
            end
          end
          resources :rosters,   :except => [:new, :edit, :index, :update] do
            collection do
              get       :filter_data
              get       :get_employee_roster
              post      :roster_index
              post      :bulk_update
              post      :bulk_destroy
              post      :single_update
              post      :bulk_deletion
              post      :export_roster
              post      :save_single_restday
              post      :save_bulk_hiring_shift
              post      :save_roster_rest_day
              post      :generate_roster_detail
              post      :subordinate_roster_index
              post      :generate_restday_roster_detail
            end
          end
        end

        ################# Incentive Management #################
        scope module: :incentive_management do
          resources :sale_entries,   :except => [:new, :edit] do
            collection do
              get       :filter_data
              get     :download_sample_csv_file
              post    :bulk_import_sale
              get     :incentive_sample_csv_file
              post    :bulk_import_employee_incentive
            end
          end
          resources :incentive_policies,   :except => [:new, :edit] do
            collection do
              get       :filter_data
              delete    :destroy_incentive_slab
            end
          end
          resources :incentive_executions,   :except => [:new, :edit, :index, :create, :update, :show, :destroy] do
            collection do
              post      :incentive_employee_list
              post      :sale_incentive
            end
          end
        end

        ################# PayRoll Management #################
        scope module: :payroll_management do
          resources :piece_slabs,   :except => [:new, :edit] do
            collection do
              get       :filter_data
              delete    :destroy_piece_slab_detail
            end
          end
          resources :tax_slabs,   :except => [:new, :edit] do
            collection do
              get       :filter_data
              delete    :destroy_tax_slab_detail
            end
          end
          resources :custom_tax_slabs,   :except => [:new, :edit] do
            collection do
              get       :filter_data
              delete    :destroy_custom_tax_slab_detail
            end
          end
          resources :fiscal_years,   :except => [:new, :edit] do
            collection do
              get       :filter_data
              get       :filter_data_is_active
            end
          end
          resources :eobis,   :except => [:new, :edit] do
            collection do
              get       :filter_data
            end
          end
          resources :payitem_expressions,   :except => [:new, :edit] do
            collection do
              get       :filter_data
            end
          end
          resources :pay_items,   :except => [:new, :edit] do
            collection do
              get       :filter_data
              get       :filter_pay_item
              get       :fixed_pay_items
              get       :non_static_pay_items
            end
          end
          resources :fixed_pay_items,   :except => [:new, :edit] do
            collection do
              get     :filter_data
              get     :download_sample_csv_file
              post    :deactive_item
              post    :bulk_deletion
              post    :bulk_import_items
            end
          end
          resources :fuel_card_details,   :except => [:new, :edit] do
            collection do
              get     :filter_data
              get     :download_sample_csv_file
              post    :bulk_import
            end
          end
          resources :provident_funds,   :except => [:new, :edit] do
            collection do
              get     :filter_data
            end
          end
          resources :pay_executions,   :except => [:new, :edit] do
            collection do
              get     :filter_data
              get     :locked_payroll
              get     :generate_payroll
              get     :regenerate_payroll
              get     :bulk_download_slip
              get     :bulk_download_slip_all
              get     :download_tax_working
            end
          end
          resources :benefit_structures,   :except => [:new, :edit] do
            collection do
              get     :filter_data
              get     :benefit_structure_allocation
            end
          end
          resources :employee_loans, except: [:new, :edit] do
            collection do
              get    :filter_data
              get    :get_pay_back_date
              post   :employee_loan_detail
            end
          end
          resources :employee_advances, except: [:new, :edit] do
            collection do
              get    :filter_data
            end
          end
          resources :pay_invoices, except: [:new, :edit] do
            collection do
              get     :regenerate
              get     :download_slip
              get     :locked_pay_invoice
              post    :my_salary_slip_list
              post    :current_pay_invoices
              post    :update_tax_adjustment
              post    :subordinate_pay_invoices
            end
          end
          resources :employee_tax_credits, except: [:new, :edit] do
            collection do
              get    :filter_data
            end
          end
          resources :employee_tax_adjustments, except: [:new, :edit] do
            collection do
              get    :filter_data
            end
          end
          resources :employee_tax_details, except: [:new, :edit] do
            collection do
              get     :download_sample_csv_file
              post    :bulk_import_employee_cpr
            end
          end
        end

        ################# Employee Request #################

        scope module: :employee_request do
          resources :approval_requests,   :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :cancel_request
              get   :approved_request
              get   :approve_by_email
              get   :reject_by_email
              post  :execute_bulk_approval
              post  :bulk_index
            end
          end
        end

        ################# Attendance Management #################

        scope module: :attendance_management do
          resources :over_strength_requests,            :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :cancel_request
              get   :approved_request
              post  :bulk_index
              post  :verify_over_strength_request
            end
          end
          resources :attendance_cutoffs,   :except => [:new, :edit] do
            collection do
              get     :filter_data
              get     :branch_filter_data
              get     :locaiton_filter_data
              get     :check_cutoff_month
              get     :cut_off_employee_list
              get     :salary_unit_filter_data
              get     :cut_off_adjustment_list
              get     :execute_attendance_cut_off
              get     :download_attendance_cutoff
              post    :bulk_save
              post    :save_cut_off_adjustment
              post    :bulk_execute_attendance_cut_off
              post    :bulk_download_attendance_cutoff
            end
          end
          resources :attendance_relaxations,   :except => [:new, :edit] do
            collection do
              get       :filter_data
              delete    :destroy_relaxation_slab
            end
          end
          resources :attendance_overtimes,   :except => [:new, :edit] do
            collection do
              get       :filter_data
              delete    :destroy_overtime_slab
            end
          end
          resources :early_lefts,   :except => [:new, :edit] do
            collection do
              get       :filter_data
              delete    :destroy_early_left_slab
            end
          end
          resources :absent_policies,   :except => [:new, :edit] do
            collection do
              get       :filter_data
            end
          end
          resources :missing_punches,   :except => [:new, :edit] do
            collection do
              get       :filter_data
            end
          end
          resources :attendance_deductions,   :except => [:new, :edit] do
            collection do
              get   :filter_data
            end
          end
          resources :attendance_earnings,   :except => [:new, :edit] do
            collection do
              get   :filter_data
            end
          end
          resources :attendance_exceptions,   :except => [:new, :edit] do
            collection do
              get   :filter_data
            end
          end
          resources :attendance_types,   :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :request_enabled
              get   :employee_related_request_enabled
            end
          end
          resources :relaxation_approval_requests,   :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :cancel_request
              get   :approved_request
            end
          end
          resources :relaxation_requests,            :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :cancel_request
              get   :approved_request
              post  :bulk_index
              post  :bulk_export
              post  :calculate_relaxation
              post  :save_bulk_relaxation
            end
          end
          resources :attendance_structures,   :except => [:new, :edit] do
            collection do
              get   :filter_data
              post  :bulk_department_allocation
            end
          end
          resources :attendance_devices,   :except => [:new, :edit] do
            collection do
              get   :filter_data
              post  :fetch_device_data
              post  :bulk_fetch_device_data
            end
          end
          resources :attendance_executions,   :except => [:new, :edit] do
            collection do
              get    :download_sample_csv_file
              get    :download_second_sample_csv_file
              post   :employee_time_card
              post   :download_time_card
              post   :bulk_approved_overtime
              post   :bulk_import_attendance
              post   :fetch_employee_attendance
              post   :save_multi_day_attendance
              post   :download_multiple_time_card
              post   :bulk_import_second_attendance
              post   :reverse_bulk_approved_overtime
              post   :bulk_execute_employee_attendance
              post   :fetch_overtime_employee_attendance
              post   :execute_single_employee_attendance
              post   :bulk_salary_unit_execute_employee_attendance
            end
          end
          resources :employee_arrears,   :except => [:new, :edit, :destroy] do
            collection do
              get    :disabled_employee_arrear
            end
          end
          resources :employee_deductions,   :except => [:new, :edit, :destroy] do
            collection do
              get    :disabled_employee_deduction
            end
          end
        end

        ################# Organization #################

        scope module: :organization do
          resources :companies,           :except => [:new, :edit] do
            collection do
              get   :org_chart
              get   :complete_list
              get   :employee_code_prefix
              post  :upload_logo
            end
          end
          resources :locations,           :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :hris_dashboard_filter
              get   :salary_dashboard_filter
              get   :attendance_dashboard_filter
            end
          end
          resources :branches,            :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :multi_filter_data
              get   :company_filter_data
            end
          end
          resources :departments,         :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :salary_dashboard_filters
            end
          end
          resources :department_allocations, :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :fetch_department_data
            end
          end
          resources :sub_departments,     :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :department_related_data
            end
          end
          resources :piecerates,     :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :department_related_data
              get   :floor_data
              get   :line_data
              get   :incharge_data
              get   :category_data
              get   :group_data
            end
          end
          resources :designations,        :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :multi_filter_data
              get   :grade_related_designations
            end
          end
          resources :job_titles,          :except => [:new, :edit] do
            collection do
              get   :filter_data
            end
          end
          resources :cost_centers,        :except => [:new, :edit] do
            collection do
              get   :filter_data
            end
          end
          resources :salary_units,        :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :filter_data_user
            end
          end
          resources :grades,              :except => [:new, :edit] do
            collection do
              get   :filter_data
            end
          end
          resources :asset_details,       :except => [:new, :edit] do
            collection do
              get   :filter_data
            end
          end
          resources :grade_allocations, :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :fetch_grade_data
            end
          end
        end

        ################# Performance Management #################

        scope module: :performance_management do
          resources :objective_approvals,   :except => [:new, :edit] do
            member do
              get :comments
              get :appraisal_comments
            end
            collection do
              get   :filter_data
              get   :filter_approvals
              post  :bulk_department_allocation
              post   :export_objective_setting_report
              get  :export_objective_setting_report
              post  :export_appraisal_report
              get   :export_appraisal_report
              get   :update_approval
              post   :update_approval
              get    :update_appraisal_approval
              post    :update_appraisal_approval
              get    :update_hod_approval
              post    :update_hod_approval
            end
          end
          resources :appraisal_approvals,   :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :filter_approvals
              get   :appraisal_approval
              post  :bulk_department_allocation
              post   :export_objective_setting_report
              get  :export_objective_setting_report
              post  :export_appraisal_report
              get   :export_appraisal_report
              post  :export_annual_appraisal_report
              get   :export_annual_appraisal_report
              get   :index3
            end
          end
          resources :objective_settings,   :except => [:new, :edit] do
            collection do
              get   :filter_approvals
              get   :filter_appraisal_approvals
              get   :filter_hod_approvals
              get   :filter_data
              get   :employee_data
              post  :bulk_department_allocation
              post  :export_objective_setting_report
              get   :export_objective_setting_report
              get   :get_employee
              get   :update_approval
              post  :update_approval
            end
          end
          resources :tasks,           :except => [:new, :edit] do
            collection do
              get   :org_chart
              get   :complete_list_task
              get   :index2
              get   :index3
            end
          end
          resources :appraisals,           :except => [:new, :edit] do
            collection do
              get   :org_chart
              get   :index2
              get   :index3
              get   :complete_list_task
              post  :save_data
              post  :save_manager_data
              get  :save_competency_data
              get  :save_competency_data_m
              post  :save_appraisal_approval
              get   :save_appraisal_approval
              post  :export_appraisal_report
              get   :export_appraisal_report
              get   :filter_competency_data
            end
          end
          resources :competencies,           :except => [:new, :edit] do
            collection do
              get   :org_chart
              get   :complete_list_task
            end
          end
          resources :sub_tasks,           :except => [:new, :edit] do
            collection do
              get   :filter_data
              get   :filter_task_data
              get   :filter_sub_task_data
              get   :submit_for_approval
              get   :submit_for_approval_appraisal
              get   :index_approval
              get   :index_appraisal_approval
              post  :save_comments
              post  :save_comments_m
            end
          end
        end

        ################# Geo Graphical #################

        scope module: :geographical do
          resources :countries,           :except => [:new, :edit]
          resources :states,              :except => [:new, :edit] do
            collection do
              get :filter_data
            end
          end
          resources :cities,              :except => [:new, :edit] do
            collection do
              get :filter_data
            end
          end
        end

        ################# Reports #################

        scope module: :reports do
          resources :employee_reports,         :except => [:new, :create, :edit, :update, :delete, :show, :index] do
            collection do
              post     :joiner_detail
              post     :leaver_detail
              post     :employee_list
              post     :cost_to_company
              post     :benefit_detail
              post     :transfer_detail
              post     :probation_detail
              post     :line_manager_detail
              post     :employee_bank_detail
              post     :employee_asset_detail
              post     :health_insurance_report
              post     :employee_contact_detail
              post     :employee_profile_detail
              post     :employee_relative_detail
              post     :employee_last_experience
              post     :employee_first_experience
              post     :employee_reference_detail
              post     :employee_experience_detail
              post     :employee_next_of_kin_detail
              post     :employee_qualification_detail
              post     :employee_last_qualification_detail
            end
          end
          resources :performance_management_reports,         :except => [:new, :create, :edit, :update, :delete, :show, :index] do
            collection do
              post     :objective_list
              post     :appraisal_list
            end
          end
          resources :attendance_reports,         :except => [:new, :create, :edit, :update, :delete, :show, :index] do
            collection do
              post     :attendance_log
              post     :detail_overtime
              post     :daily_attendance
              post     :attendance_detail
              post     :attendance_summary
              post     :attendance_register
              post     :attendance_execution_log
              post     :attendance_register_detail
              post     :attendance_summary_detail
            end
          end
          resources :incentive_reports,         :except => [:new, :create, :edit, :update, :delete, :show, :index] do
            collection do
              post     :sale_incentive_report
            end
          end
          resources :payroll_reports,           :except => [:new, :create, :edit, :update, :delete, :show, :index] do
            collection do
              post     :tax_report
              post     :export_tax_certificate
              get      :tax_certificate_filter_data
              post     :eobi_report
              post     :pessi_report
              post     :salary_sheet
              post     :salary_letter
              post     :tax_structure
              post     :salary_register
              post     :payment_register
              post     :comman_staff_report
              post     :multi_salary_register
              post     :provident_fund_report
              post     :social_security_report
              post     :salary_register_month_wise
            end
          end
          resources :leave_reports,         :except => [:new, :create, :edit, :update, :delete, :show, :index] do
            collection do
              post     :leave_ledger
              post     :leave_balance
              post     :leave_history
              post     :leave_register
              post     :leave_encashment
              post     :leave_balance_detail
            end
          end
          resources :official_duty_reports,         :except => [:new, :create, :edit, :update, :delete, :show, :index] do
            collection do
              post     :od_register
            end
          end
        end

        ################# Dashboard #################

        resources :dashboards, :except => [:new, :edit, :create, :update, :destroy, :show, :index] do
          collection do
            get :main_dashboard
            post  :hris_dashboard
            post  :salary_dashboard
            post  :attendance_dashboard
            get :company_wise_dashboard
          end
        end

        ################# User Token Verifcation #################

        resources :tokens, :except => [:new, :edit, :create, :update, :destroy, :show] do
          collection do
            get :validate
          end
        end

        ################# Notification #################

        resources :notifications, :except => [:new, :edit, :create, :destroy, :show] do
          collection do
            get :mark_as_read
            get :get_lastest_notifications
          end
        end

      end

      ################# User/Memeber #################

      resources :members, :except => [:new, :edit] do
        collection do
          get  :filter_data
          post :bulk_action
          post :reset_password
          post :update_password
          post :user_update_password
          post :update_password_by_token
        end
      end

    end
  end
end
