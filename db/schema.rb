# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_03_09_090000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "absent_policies", force: :cascade do |t|
    t.integer "company_id"
    t.integer "attendance_deduction_id"
    t.integer "fallback_id"
    t.string "name"
    t.string "code"
    t.boolean "is_active", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attendance_deduction_id"], name: "index_absent_policies_on_attendance_deduction_id"
    t.index ["company_id"], name: "index_absent_policies_on_company_id"
    t.index ["fallback_id"], name: "index_absent_policies_on_fallback_id"
  end

  create_table "appraisal_approvals", force: :cascade do |t|
    t.integer "objective_id"
    t.integer "employee_id"
    t.float "net_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.string "comments"
  end

  create_table "appraisal_comments", force: :cascade do |t|
    t.integer "employee_id"
    t.integer "fiscal_year_id"
    t.string "employee_comments"
    t.string "functional"
    t.string "leadership"
    t.string "career_aspiration"
    t.string "line_manager_approval", default: "Pending"
    t.string "status", default: "Pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "total_emp_task_score"
    t.float "total_emp_competency_score"
    t.string "line_manager_comments"
    t.float "total_line_manager_task_score"
    t.float "total_line_manager_competency_score"
  end

  create_table "appraisals", force: :cascade do |t|
    t.integer "competency_id"
    t.integer "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "employee_rating"
    t.integer "fiscal_year_id"
    t.string "title"
    t.string "description"
    t.string "line_manager_rating"
  end

  create_table "approval_requests", force: :cascade do |t|
    t.integer "company_id"
    t.integer "request_sender_id"
    t.integer "request_receiver_id"
    t.integer "request_flow_id"
    t.string "approval_request_status"
    t.boolean "is_approved", default: false
    t.string "requestable_type"
    t.bigint "requestable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token"
    t.boolean "is_hod_approved", default: false
    t.boolean "is_hod_submitted", default: false
    t.index ["company_id"], name: "index_approval_requests_on_company_id"
    t.index ["request_flow_id"], name: "index_approval_requests_on_request_flow_id"
    t.index ["request_receiver_id"], name: "index_approval_requests_on_request_receiver_id"
    t.index ["request_sender_id"], name: "index_approval_requests_on_request_sender_id"
    t.index ["requestable_type", "requestable_id"], name: "index_approval_requests_on_requestable"
  end

  create_table "asset_details", force: :cascade do |t|
    t.integer "company_id"
    t.string "item_name"
    t.string "item_type"
    t.string "item_model"
    t.datetime "purchase_date"
    t.datetime "expiry_date"
    t.float "item_amount", default: 0.0
    t.string "maturity_period"
    t.string "engine_capacity"
    t.string "engine_number"
    t.string "chase_number"
    t.string "sim_number"
    t.string "emi_number"
    t.string "telecom_name"
    t.float "card_limit", default: 0.0
    t.string "card_number"
    t.boolean "is_active", default: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_asset_details_on_company_id"
  end

  create_table "asset_types", force: :cascade do |t|
    t.string "name"
    t.boolean "is_active", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "attendance_cutoffs", force: :cascade do |t|
    t.integer "company_id"
    t.integer "location_id"
    t.integer "branch_id"
    t.string "name"
    t.datetime "start_date"
    t.datetime "end_date"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_executed", default: false
    t.integer "salary_unit_id"
    t.boolean "salary_unit_wise", default: false
    t.index ["branch_id"], name: "index_attendance_cutoffs_on_branch_id"
    t.index ["company_id"], name: "index_attendance_cutoffs_on_company_id"
    t.index ["location_id"], name: "index_attendance_cutoffs_on_location_id"
  end

  create_table "attendance_deductions", force: :cascade do |t|
    t.integer "company_id"
    t.integer "attendance_type_id"
    t.string "name"
    t.string "deduction_from"
    t.string "deduction_type"
    t.float "exempted_in_month", default: 0.0
    t.float "deduction_value", default: 0.0
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attendance_type_id"], name: "index_attendance_deductions_on_attendance_type_id"
    t.index ["company_id"], name: "index_attendance_deductions_on_company_id"
  end

  create_table "attendance_devices", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.integer "company_id"
    t.boolean "is_active", default: false
    t.integer "device_id"
    t.string "device_type"
    t.string "device_url"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "auto_fetch_allowed", default: false
    t.index ["company_id"], name: "index_attendance_devices_on_company_id"
  end

  create_table "attendance_earnings", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.string "earning_from"
    t.string "earning_type"
    t.float "multiplex", default: 1.0
    t.float "earning_value", default: 0.0
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "multiplex_allowed", default: false
    t.text "holiday_ids"
    t.boolean "upper_cap", default: false
    t.float "upper_cap_limit", default: 0.0
    t.string "working_days"
    t.boolean "rest_upper_cap", default: false
    t.boolean "regular_upper_cap", default: false
    t.float "rest_upper_cap_limit", default: 0.0
    t.float "regular_upper_cap_limit", default: 0.0
    t.index ["company_id"], name: "index_attendance_earnings_on_company_id"
  end

  create_table "attendance_exceptions", force: :cascade do |t|
    t.integer "company_id"
    t.integer "location_id"
    t.integer "branch_id"
    t.string "name"
    t.string "attendance_exception_type"
    t.float "grace_time", default: 0.0
    t.datetime "start_date"
    t.datetime "end_date"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "salary_unit_id"
    t.boolean "salary_unit_wise", default: false
    t.index ["branch_id"], name: "index_attendance_exceptions_on_branch_id"
    t.index ["company_id"], name: "index_attendance_exceptions_on_company_id"
    t.index ["location_id"], name: "index_attendance_exceptions_on_location_id"
  end

  create_table "attendance_execution_transactions", force: :cascade do |t|
    t.integer "company_id"
    t.integer "location_id"
    t.integer "branch_id"
    t.string "company_name"
    t.string "location_name"
    t.string "branch_name"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "execution_start_time"
    t.datetime "execution_end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "department_id", default: ""
    t.text "department_name", default: ""
    t.index ["branch_id"], name: "index_attendance_execution_transactions_on_branch_id"
    t.index ["company_id"], name: "index_attendance_execution_transactions_on_company_id"
    t.index ["location_id"], name: "index_attendance_execution_transactions_on_location_id"
  end

  create_table "attendance_machine_logs", force: :cascade do |t|
    t.string "employee_full_name"
    t.string "employee_code"
    t.string "machine_name"
    t.datetime "attendance_datetime"
    t.datetime "attendance_date"
    t.string "actual_attendance_date"
    t.integer "formatted_hour"
    t.integer "formatted_minute"
    t.integer "formatted_second"
    t.string "log_id"
    t.integer "company_id"
    t.integer "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "device_id", default: ""
    t.index ["company_id"], name: "index_attendance_machine_logs_on_company_id"
    t.index ["employee_id"], name: "index_attendance_machine_logs_on_employee_id"
  end

  create_table "attendance_overtime_slabs", force: :cascade do |t|
    t.integer "attendance_overtime_id"
    t.integer "attendance_earning_id"
    t.float "min_minute", default: 0.0
    t.float "max_minute", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attendance_earning_id"], name: "index_attendance_overtime_slabs_on_attendance_earning_id"
    t.index ["attendance_overtime_id"], name: "index_attendance_overtime_slabs_on_attendance_overtime_id"
  end

  create_table "attendance_overtimes", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.string "code"
    t.boolean "is_active", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "overtime_after_office_end", default: false
    t.index ["company_id"], name: "index_attendance_overtimes_on_company_id"
  end

  create_table "attendance_relaxation_slabs", force: :cascade do |t|
    t.integer "attendance_relaxation_id"
    t.integer "attendance_deduction_id"
    t.integer "fallback_id"
    t.float "start_minute", default: 0.0
    t.float "end_minute", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attendance_deduction_id"], name: "index_attendance_relaxation_slabs_on_attendance_deduction_id"
    t.index ["attendance_relaxation_id"], name: "index_attendance_relaxation_slabs_on_attendance_relaxation_id"
    t.index ["fallback_id"], name: "index_attendance_relaxation_slabs_on_fallback_id"
  end

  create_table "attendance_relaxations", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.string "code"
    t.boolean "is_active", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_attendance_relaxations_on_company_id"
  end

  create_table "attendance_structures", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.integer "company_id"
    t.boolean "is_active", default: false
    t.integer "location_id"
    t.integer "branch_id"
    t.integer "department_id"
    t.integer "grade_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "absent_policy_id"
    t.integer "attendance_overtime_id"
    t.integer "attendance_relaxation_id"
    t.integer "early_left_id"
    t.integer "missing_punch_id"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "department_ids", default: ""
    t.boolean "special_rule", default: false
    t.boolean "is_flexi", default: false
    t.float "serve_minutes", default: 0.0
    t.float "total_working_minutes", default: 0.0
    t.float "addional_minutes", default: 0.0
    t.boolean "regular_overtime_exception", default: false
    t.float "regular_min_salary", default: 0.0
    t.float "regular_max_salary", default: 0.0
    t.integer "regular_overtime_id"
    t.boolean "holiday_overtime_exception", default: false
    t.float "holiday_min_salary", default: 0.0
    t.float "holiday_max_salary", default: 0.0
    t.integer "holiday_overtime_id"
    t.boolean "is_flexi_in_early_gone", default: false
    t.float "early_gone_total_working_minute", default: 0.0
    t.index ["absent_policy_id"], name: "index_attendance_structures_on_absent_policy_id"
    t.index ["attendance_overtime_id"], name: "index_attendance_structures_on_attendance_overtime_id"
    t.index ["attendance_relaxation_id"], name: "index_attendance_structures_on_attendance_relaxation_id"
    t.index ["branch_id"], name: "index_attendance_structures_on_branch_id"
    t.index ["company_id"], name: "index_attendance_structures_on_company_id"
    t.index ["department_id"], name: "index_attendance_structures_on_department_id"
    t.index ["early_left_id"], name: "index_attendance_structures_on_early_left_id"
    t.index ["grade_id"], name: "index_attendance_structures_on_grade_id"
    t.index ["location_id"], name: "index_attendance_structures_on_location_id"
    t.index ["missing_punch_id"], name: "index_attendance_structures_on_missing_punch_id"
  end

  create_table "attendance_types", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.string "code"
    t.boolean "is_active", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sort_order", default: 0
    t.boolean "request_enable", default: false
    t.index ["company_id"], name: "index_attendance_types_on_company_id"
  end

  create_table "benefit_structures", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.integer "company_id"
    t.integer "location_id"
    t.integer "grade_id"
    t.integer "employee_type_id"
    t.boolean "is_active", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "social_security_allowed", default: false
    t.string "social_security_eligibility"
    t.float "social_security_joining_salary", default: 0.0
    t.boolean "life_insurance_allowed", default: false
    t.string "life_insurance_eligibility"
    t.float "life_insurance_value", default: 0.0
    t.boolean "cell_phone_bill_allowed", default: false
    t.string "cell_phone_bill_eligibility"
    t.string "cell_phone_bill_limit"
    t.float "cell_phone_bill_amount", default: 0.0
    t.boolean "fuel_allowed", default: false
    t.string "fuel_eligibility"
    t.string "fuel_limit"
    t.float "fuel_value", default: 0.0
    t.boolean "cell_phone_allowed", default: false
    t.string "cell_phone_eligibility"
    t.float "cell_phone_entitlement_upto", default: 0.0
    t.boolean "laptop_allowed", default: false
    t.string "laptop_eligibility"
    t.float "laptop_entitlement_upto", default: 0.0
    t.boolean "velicle_allowed", default: false
    t.string "velicle_eligibility"
    t.boolean "provident_fund_allowed", default: false
    t.string "provident_fund_eligibility"
    t.boolean "eobi_allowed", default: false
    t.string "eobi_eligibility"
    t.boolean "incentive_allowed", default: false
    t.string "incentive_eligibility"
    t.boolean "vehicle_allowance_allowed", default: false
    t.string "vehicle_allowance_eligibility"
    t.float "vehicle_allowance_entitlement_upto", default: 0.0
    t.boolean "maintenance_allowed", default: false
    t.string "maintenance_eligibility"
    t.float "maintenance_entitlement_upto", default: 0.0
    t.boolean "travel_allowance_allowed", default: false
    t.string "travel_allowance_eligibility"
    t.float "travel_allowance_entitlement_upto", default: 0.0
    t.boolean "attendance_allowed", default: false
    t.boolean "overtime_allowed", default: false
    t.boolean "cpl_allowed", default: false
    t.boolean "off_day_allowed", default: false
    t.boolean "bonus1_allowed", default: false
    t.string "bonus1_eligibility"
    t.boolean "bonus2_allowed", default: false
    t.string "bonus2_eligibility"
    t.boolean "bonus3_allowed", default: false
    t.string "bonus3_eligibility"
    t.boolean "health_insurance_allowed", default: false
    t.string "health_insurance_plan"
    t.string "health_insurance_eligibility"
    t.string "laptop_category"
    t.boolean "gratuity_allowed", default: false
    t.string "gratuity_eligibility"
    t.boolean "lfa_allowed", default: false
    t.string "lfa_eligibility"
    t.boolean "house_allowance_allowed", default: false
    t.string "house_allowance_eligibility"
    t.boolean "regular_quota_encashment", default: false
    t.boolean "holiday_quota_encashment", default: false
    t.boolean "is_regular_cpl", default: false
    t.boolean "is_holiday_overtime", default: false
    t.boolean "approval_base_overtime", default: false
    t.index ["company_id"], name: "index_benefit_structures_on_company_id"
    t.index ["employee_type_id"], name: "index_benefit_structures_on_employee_type_id"
    t.index ["grade_id"], name: "index_benefit_structures_on_grade_id"
    t.index ["location_id"], name: "index_benefit_structures_on_location_id"
  end

  create_table "branches", force: :cascade do |t|
    t.integer "company_id"
    t.integer "location_id"
    t.string "name"
    t.string "code"
    t.text "description"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "country_id"
    t.integer "state_id"
    t.integer "city_id"
    t.float "employee_code_prefix", default: 0.0
    t.integer "shop_id"
    t.index ["company_id"], name: "index_branches_on_company_id"
    t.index ["location_id"], name: "index_branches_on_location_id"
  end

  create_table "break_times", force: :cascade do |t|
    t.integer "time_slot_id"
    t.string "name"
    t.string "code"
    t.string "actual_start_time"
    t.string "actual_end_time"
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean "excluded", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["time_slot_id"], name: "index_break_times_on_time_slot_id"
  end

  create_table "certification_types", force: :cascade do |t|
    t.string "name"
    t.boolean "is_active", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.integer "state_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state_id"], name: "index_cities_on_state_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "short_name"
    t.text "address"
    t.text "description"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "employee_code_prefix", default: 0.0
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean "effective_gross"
    t.text "ntn_number"
  end

  create_table "competencies", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.integer "rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "composite_leave_types", force: :cascade do |t|
    t.integer "leave_type_id"
    t.integer "merge_leave_type_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cost_centers", force: :cascade do |t|
    t.integer "company_id"
    t.integer "salary_unit_id"
    t.string "name"
    t.boolean "is_active", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_cost_centers_on_company_id"
    t.index ["salary_unit_id"], name: "index_cost_centers_on_salary_unit_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "sortname"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cpl_earnings", force: :cascade do |t|
    t.bigint "employee_id"
    t.bigint "employee_attendance_id"
    t.integer "status", default: 0
    t.string "approval_name", default: "-"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_attendance_id"], name: "index_cpl_earnings_on_employee_attendance_id"
    t.index ["employee_id"], name: "index_cpl_earnings_on_employee_id"
  end

  create_table "custom_tax_slab_details", force: :cascade do |t|
    t.integer "custom_tax_slab_id"
    t.float "lower_limit", default: 0.0
    t.float "upper_limit", default: 0.0
    t.float "tax_percentage", default: 0.0
    t.float "fixed_amount", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "custom_tax_slabs", force: :cascade do |t|
    t.integer "company_id"
    t.boolean "is_active", default: false
    t.string "name"
    t.string "code"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "department_allocation_details", force: :cascade do |t|
    t.integer "department_allocation_id"
    t.integer "department_id"
    t.boolean "is_selected", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_allocation_id"], name: "idx_on_department_allocation_id_e654cee0ee"
    t.index ["department_id"], name: "index_department_allocation_details_on_department_id"
  end

  create_table "department_allocations", force: :cascade do |t|
    t.integer "company_id"
    t.integer "location_id"
    t.integer "branch_id"
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_department_allocations_on_branch_id"
    t.index ["company_id"], name: "index_department_allocations_on_company_id"
    t.index ["location_id"], name: "index_department_allocations_on_location_id"
  end

  create_table "departments", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.string "code"
    t.text "description"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_departments_on_company_id"
  end

  create_table "designations", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.string "code"
    t.text "description"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "grade_id"
    t.index ["company_id"], name: "index_designations_on_company_id"
  end

  create_table "districts", force: :cascade do |t|
    t.integer "division_id"
    t.integer "country_id"
    t.integer "state_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_districts_on_country_id"
    t.index ["division_id"], name: "index_districts_on_division_id"
    t.index ["state_id"], name: "index_districts_on_state_id"
  end

  create_table "divisions", force: :cascade do |t|
    t.integer "country_id"
    t.integer "state_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_divisions_on_country_id"
    t.index ["state_id"], name: "index_divisions_on_state_id"
  end

  create_table "documents", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.string "code"
    t.text "description"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_documents_on_company_id"
  end

  create_table "early_left_slabs", force: :cascade do |t|
    t.integer "early_left_id"
    t.integer "attendance_deduction_id"
    t.integer "fallback_id"
    t.float "start_minute", default: 0.0
    t.float "end_minute", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attendance_deduction_id"], name: "index_early_left_slabs_on_attendance_deduction_id"
    t.index ["early_left_id"], name: "index_early_left_slabs_on_early_left_id"
    t.index ["fallback_id"], name: "index_early_left_slabs_on_fallback_id"
  end

  create_table "early_lefts", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.string "code"
    t.boolean "is_active", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_early_lefts_on_company_id"
  end

  create_table "email_configrations", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.string "user_name"
    t.string "email"
    t.string "password"
    t.string "outgoing_server_address"
    t.string "outgoing_server_port"
    t.string "domain"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_email_configrations_on_company_id"
  end

  create_table "email_executions", force: :cascade do |t|
    t.integer "company_id"
    t.integer "location_id"
    t.integer "branch_id"
    t.integer "grade_id"
    t.string "name"
    t.integer "email_template_id"
    t.string "trigger"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "no_of_days", default: 0.0
    t.index ["branch_id"], name: "index_email_executions_on_branch_id"
    t.index ["company_id"], name: "index_email_executions_on_company_id"
    t.index ["email_template_id"], name: "index_email_executions_on_email_template_id"
    t.index ["grade_id"], name: "index_email_executions_on_grade_id"
    t.index ["location_id"], name: "index_email_executions_on_location_id"
  end

  create_table "email_outbounds", force: :cascade do |t|
    t.integer "company_id"
    t.integer "email_configration_id"
    t.integer "email_template_id"
    t.string "from_address", default: ""
    t.string "to_address", default: ""
    t.string "cc_address", default: ""
    t.string "subject"
    t.string "server_user_name"
    t.string "server_email"
    t.string "server_password"
    t.string "server_address"
    t.string "server_port"
    t.string "server_domain"
    t.boolean "is_cc", default: false
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_email_outbounds_on_company_id"
    t.index ["email_configration_id"], name: "index_email_outbounds_on_email_configration_id"
    t.index ["email_template_id"], name: "index_email_outbounds_on_email_template_id"
  end

  create_table "email_templates", force: :cascade do |t|
    t.integer "company_id"
    t.integer "email_configration_id"
    t.string "name"
    t.string "subject"
    t.string "trigger"
    t.string "cc_address"
    t.boolean "is_cc", default: false
    t.text "message"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_exempted", default: false
    t.text "exempted_address", default: ""
    t.index ["company_id"], name: "index_email_templates_on_company_id"
    t.index ["email_configration_id"], name: "index_email_templates_on_email_configration_id"
  end

  create_table "employee_advances", force: :cascade do |t|
    t.integer "company_id"
    t.integer "employee_id"
    t.float "gross_salary", default: 0.0
    t.float "advance_amount", default: 0.0
    t.float "advance_percentage", default: 0.0
    t.datetime "advance_date"
    t.datetime "pay_back_date"
    t.string "pay_back_month"
    t.boolean "is_cleared", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_employee_advances_on_company_id"
    t.index ["employee_id"], name: "index_employee_advances_on_employee_id"
  end

  create_table "employee_arrears", force: :cascade do |t|
    t.integer "employee_id"
    t.integer "offical_duty_id"
    t.integer "leave_request_id"
    t.float "arrear_days", default: 0.0
    t.string "arrear_type"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "arrears_month"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "status", default: false
    t.integer "company_id"
    t.string "arrear_kind", default: "Other"
    t.index ["employee_id"], name: "index_employee_arrears_on_employee_id"
    t.index ["leave_request_id"], name: "index_employee_arrears_on_leave_request_id"
    t.index ["offical_duty_id"], name: "index_employee_arrears_on_offical_duty_id"
  end

  create_table "employee_attendances", force: :cascade do |t|
    t.integer "employee_id"
    t.integer "company_id"
    t.integer "location_id"
    t.integer "branch_id"
    t.integer "department_id"
    t.integer "sub_department_id"
    t.integer "grade_id"
    t.integer "job_title_id"
    t.integer "designation_id"
    t.integer "salary_unit_id"
    t.integer "cost_center_id"
    t.integer "roster_id"
    t.string "employee_full_name"
    t.string "employee_code"
    t.string "company_name"
    t.string "location_name"
    t.string "branch_name"
    t.string "department_name"
    t.string "sub_department_name"
    t.string "grade_name"
    t.string "job_title_name"
    t.string "designation_name"
    t.string "salary_unit_name"
    t.string "cost_center_name"
    t.string "attendance_status"
    t.string "early_left_status"
    t.datetime "attendance_date"
    t.datetime "office_start_time"
    t.datetime "office_end_time"
    t.datetime "in_time"
    t.datetime "out_time"
    t.datetime "office_in_time"
    t.datetime "office_out_time"
    t.datetime "buffer_office_in_time"
    t.datetime "buffer_office_out_time"
    t.float "checkin_deduction", default: 0.0
    t.float "over_time_seconds", default: 0.0
    t.float "over_time_hours", default: 0.0
    t.float "off_days_payment_days", default: 0.0
    t.float "no_of_cpl", default: 0.0
    t.float "office_start_hour", default: 0.0
    t.float "office_start_min", default: 0.0
    t.float "office_end_hour", default: 0.0
    t.float "office_end_min", default: 0.0
    t.float "start_buffer", default: 0.0
    t.float "end_buffer", default: 0.0
    t.float "buffer_office_start_hour", default: 0.0
    t.float "buffer_office_start_min", default: 0.0
    t.float "buffer_office_end_hour", default: 0.0
    t.float "buffer_office_end_min", default: 0.0
    t.boolean "is_rest_day", default: false
    t.boolean "is_public_holiday", default: false
    t.boolean "mark_as_manual", default: false
    t.boolean "roster_exist", default: false
    t.boolean "is_finalize", default: false
    t.boolean "is_on_leave", default: false
    t.boolean "is_overtime", default: false
    t.boolean "is_off_day_working", default: false
    t.boolean "is_cpl", default: false
    t.boolean "attendance_exempted", default: false
    t.text "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_flexi", default: false
    t.boolean "incentive_verified", default: false
    t.boolean "is_official_duty", default: false
    t.boolean "is_relaxation", default: false
    t.float "checkout_deduction", default: 0.0
    t.boolean "deduction_from_quota", default: false
    t.boolean "deduction_from_salary", default: false
    t.float "over_time_minutes", default: 0.0
    t.boolean "quota_earned", default: false
    t.float "pay_deduction", default: 0.0
    t.boolean "is_finalized", default: false
    t.boolean "prev_finalized", default: false
    t.float "minute_deducted", default: 0.0
    t.float "minute_earned", default: 0.0
    t.boolean "is_leave_without_pay", default: false
    t.boolean "late_exempted", default: false
    t.float "gross_salary", default: 0.0
    t.float "encashable_quota", default: 0.0
    t.boolean "regular_quota_encashment", default: false
    t.boolean "holiday_quota_encashment", default: false
    t.boolean "is_regular_cpl", default: false
    t.boolean "is_holiday_overtime", default: false
    t.string "other_remarks", default: ""
    t.float "approved_overtime", default: 0.0
    t.float "approved_overtime_hours", default: 0.0
    t.float "approved_overtime_minutes", default: 0.0
    t.float "actual_overtime_hours", default: 0.0
    t.float "actual_overtime_minutes", default: 0.0
    t.boolean "approval_base_overtime", default: false
    t.boolean "is_ot_approved", default: false
    t.integer "time_slot_id"
    t.integer "sub_time_slot_id"
    t.boolean "in_strength", default: false
    t.boolean "over_strength", default: false
    t.boolean "gazetted", default: false
    t.index ["branch_id"], name: "index_employee_attendances_on_branch_id"
    t.index ["company_id"], name: "index_employee_attendances_on_company_id"
    t.index ["cost_center_id"], name: "index_employee_attendances_on_cost_center_id"
    t.index ["department_id"], name: "index_employee_attendances_on_department_id"
    t.index ["designation_id"], name: "index_employee_attendances_on_designation_id"
    t.index ["employee_id"], name: "index_employee_attendances_on_employee_id"
    t.index ["grade_id"], name: "index_employee_attendances_on_grade_id"
    t.index ["job_title_id"], name: "index_employee_attendances_on_job_title_id"
    t.index ["location_id"], name: "index_employee_attendances_on_location_id"
    t.index ["roster_id"], name: "index_employee_attendances_on_roster_id"
    t.index ["salary_unit_id"], name: "index_employee_attendances_on_salary_unit_id"
    t.index ["sub_department_id"], name: "index_employee_attendances_on_sub_department_id"
  end

  create_table "employee_certifications", force: :cascade do |t|
    t.integer "employee_id"
    t.string "certification_authority"
    t.string "name"
    t.datetime "start_date"
    t.datetime "end_date"
    t.float "percentage", default: 0.0
    t.string "certification_type"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_employee_certifications_on_employee_id"
  end

  create_table "employee_deductions", force: :cascade do |t|
    t.integer "employee_id"
    t.float "deduction_days", default: 0.0
    t.string "deduction_type"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "deductions_month"
    t.boolean "status", default: false
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employee_documents", force: :cascade do |t|
    t.integer "employee_id"
    t.string "document_name"
    t.string "document_remarks"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employee_experiences", force: :cascade do |t|
    t.integer "employee_id"
    t.string "organization"
    t.string "job_title"
    t.string "left_reason"
    t.float "salary", default: 0.0
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "department"
    t.string "other_benefits"
    t.index ["employee_id"], name: "index_employee_experiences_on_employee_id"
  end

  create_table "employee_loan_details", force: :cascade do |t|
    t.integer "employee_loan_id"
    t.datetime "installment_date"
    t.float "opening_balance", default: 0.0
    t.float "installment_amount", default: 0.0
    t.float "closing_balance", default: 0.0
    t.float "principle_installment_amount", default: 0.0
    t.float "loan_interest_amount", default: 0.0
    t.boolean "is_cleared", default: false
    t.string "status"
    t.text "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "formated_month"
    t.index ["employee_loan_id"], name: "index_employee_loan_details_on_employee_loan_id"
  end

  create_table "employee_loans", force: :cascade do |t|
    t.integer "company_id"
    t.integer "employee_id"
    t.string "loan_type"
    t.float "gross_salary", default: 0.0
    t.float "loan_amount", default: 0.0
    t.float "no_of_installment", default: 0.0
    t.float "monthly_installment", default: 0.0
    t.float "principle_loan_amount", default: 0.0
    t.float "annual_interest_rate", default: 0.0
    t.boolean "is_taxable", default: false
    t.datetime "loan_start_date"
    t.datetime "pay_back_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_cleared", default: false
    t.index ["company_id"], name: "index_employee_loans_on_company_id"
    t.index ["employee_id"], name: "index_employee_loans_on_employee_id"
  end

  create_table "employee_memberships", force: :cascade do |t|
    t.integer "employee_id"
    t.string "position_title"
    t.string "institute_name"
    t.string "remarks"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employee_next_of_kins", force: :cascade do |t|
    t.integer "employee_id"
    t.integer "employee_relative_id"
    t.integer "relationship_id"
    t.float "relative_age", default: 0.0
    t.float "percentage", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "guardian_id"
    t.index ["employee_id"], name: "index_employee_next_of_kins_on_employee_id"
    t.index ["employee_relative_id"], name: "index_employee_next_of_kins_on_employee_relative_id"
    t.index ["relationship_id"], name: "index_employee_next_of_kins_on_relationship_id"
  end

  create_table "employee_qualifications", force: :cascade do |t|
    t.integer "employee_id"
    t.string "institute_name"
    t.string "program_name"
    t.string "specialization_name"
    t.string "status"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "status_text"
    t.float "gpa_or_percentage", default: 0.0
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "qualification_level"
    t.integer "qualfication_type_id"
    t.integer "qualification_program_id"
    t.integer "specialization_id"
    t.index ["employee_id"], name: "index_employee_qualifications_on_employee_id"
  end

  create_table "employee_references", force: :cascade do |t|
    t.integer "employee_id"
    t.string "reference_type"
    t.string "name"
    t.string "email"
    t.string "contact_number"
    t.string "organization"
    t.string "designation"
    t.text "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_employee_references_on_employee_id"
  end

  create_table "employee_relatives", force: :cascade do |t|
    t.integer "employee_id"
    t.string "relative_name"
    t.integer "relationship_id"
    t.string "email"
    t.string "contact_number"
    t.datetime "date_of_birth"
    t.string "gender"
    t.string "cnic_number"
    t.boolean "is_dependent", default: false
    t.text "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date_of_enrollment"
    t.boolean "same_as_employee_address", default: false
    t.boolean "same_as_employee_permanent_address", default: false
    t.boolean "insurance_allowed", default: false
    t.string "martial_status"
    t.boolean "deceased", default: false
    t.boolean "covid_vaccination", default: false
    t.index ["employee_id"], name: "index_employee_relatives_on_employee_id"
    t.index ["relationship_id"], name: "index_employee_relatives_on_relationship_id"
  end

  create_table "employee_rosters", force: :cascade do |t|
    t.integer "employee_id"
    t.integer "time_slot_id"
    t.integer "company_id"
    t.integer "location_id"
    t.integer "branch_id"
    t.integer "department_id"
    t.integer "grade_id"
    t.datetime "joining_date"
    t.datetime "roster_date"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "employee_code"
    t.string "employee_name"
    t.string "location_name"
    t.string "branch_name"
    t.string "department_name"
    t.string "grade_name"
    t.boolean "is_flexi", default: false
    t.boolean "is_rest_day", default: false
    t.boolean "is_transfer", default: false
    t.string "formated_start_time"
    t.string "formated_end_time"
    t.float "start_buffer", default: 0.0
    t.float "end_buffer", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_edited", default: false
    t.integer "sub_department_id"
  end

  create_table "employee_sale_incentives", force: :cascade do |t|
    t.integer "company_id"
    t.integer "location_id"
    t.integer "branch_id"
    t.integer "employee_id"
    t.string "employee_code"
    t.string "employee_name"
    t.float "month_days", default: 0.0
    t.float "gross_salary", default: 0.0
    t.float "per_day_salary", default: 0.0
    t.float "present_days", default: 0.0
    t.float "propionate", default: 0.0
    t.float "incentive_amount", default: 0.0
    t.float "present_day_salary", default: 0.0
    t.float "sale_value", default: 0.0
    t.float "loss_value", default: 0.0
    t.float "profit_value", default: 0.0
    t.float "total_incentive", default: 0.0
    t.datetime "incentive_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "target_value", default: 0.0
    t.float "incentive_percentage", default: 0.0
    t.float "incentive_payable", default: 0.0
    t.float "incentive_thirty", default: 0.0
    t.float "incentive_ten", default: 0.0
    t.index ["branch_id"], name: "index_employee_sale_incentives_on_branch_id"
    t.index ["company_id"], name: "index_employee_sale_incentives_on_company_id"
    t.index ["employee_id"], name: "index_employee_sale_incentives_on_employee_id"
    t.index ["location_id"], name: "index_employee_sale_incentives_on_location_id"
  end

  create_table "employee_tax_adjustments", force: :cascade do |t|
    t.integer "employee_id"
    t.integer "company_id"
    t.datetime "tax_adjustment_month"
    t.string "tax_adjustment_formatted_month"
    t.float "amount", default: 0.0
    t.boolean "is_active", default: false
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_employee_tax_adjustments_on_company_id"
    t.index ["employee_id"], name: "index_employee_tax_adjustments_on_employee_id"
  end

  create_table "employee_tax_credits", force: :cascade do |t|
    t.integer "employee_id"
    t.integer "company_id"
    t.integer "fiscal_year_id"
    t.datetime "tax_credit_month"
    t.string "tax_credit_formatted_month"
    t.float "tax_credit_amount", default: 0.0
    t.string "tax_credit_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_employee_tax_credits_on_company_id"
    t.index ["employee_id"], name: "index_employee_tax_credits_on_employee_id"
    t.index ["fiscal_year_id"], name: "index_employee_tax_credits_on_fiscal_year_id"
  end

  create_table "employee_taxable_incomes", force: :cascade do |t|
    t.integer "employee_id"
    t.integer "company_id"
    t.integer "fiscal_year_id"
    t.integer "pay_invoice_id"
    t.integer "pay_execution_id"
    t.float "current_taxable_amount", default: 0.0
    t.float "prev_taxable_amount", default: 0.0
    t.float "predicated_taxable_amount", default: 0.0
    t.float "taxable_amount_to_date", default: 0.0
    t.float "prev_incentive_amount", default: 0.0
    t.float "current_incentive_amount", default: 0.0
    t.float "loan_interest_amount", default: 0.0
    t.float "gross_salary", default: 0.0
    t.float "total_taxable_amount", default: 0.0
    t.float "yearly_total_tax", default: 0.0
    t.float "monthly_tax_amount", default: 0.0
    t.float "total_paid_tax", default: 0.0
    t.float "remaing_tax_to_be_paid", default: 0.0
    t.boolean "status", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "encashable_quota", default: 0.0
    t.float "predition_amount", default: 0.0
    t.text "predition_item_amounts", default: ""
    t.text "predition_item_ids", default: ""
    t.text "predition_item_names", default: ""
    t.float "current_month_vehicle_tax", default: 0.0
    t.float "predicted_vehicle_tax", default: 0.0
    t.float "employeer_pf_value", default: 0.0
    t.float "predicted_pf_value", default: 0.0
    t.float "pf_tax_value", default: 0.0
    t.float "employeer_eobi_value", default: 0.0
    t.float "prev_vehicle_tax", default: 0.0
    t.float "employer_yearly_contribution", default: 0.0
    t.float "employer_contribution_before_tax_on_tax", default: 0.0
    t.float "tax_on_tax", default: 0.0
    t.float "total_tax_on_tax", default: 0.0
    t.float "annualize_predicated_taxable_amount", default: 0.0
    t.datetime "cpr_date"
    t.string "cpr_number"
    t.index ["company_id"], name: "index_employee_taxable_incomes_on_company_id"
    t.index ["employee_id"], name: "index_employee_taxable_incomes_on_employee_id"
    t.index ["fiscal_year_id"], name: "index_employee_taxable_incomes_on_fiscal_year_id"
    t.index ["pay_execution_id"], name: "index_employee_taxable_incomes_on_pay_execution_id"
    t.index ["pay_invoice_id"], name: "index_employee_taxable_incomes_on_pay_invoice_id"
  end

  create_table "employee_trainings", force: :cascade do |t|
    t.integer "employee_id"
    t.string "organization"
    t.string "name"
    t.string "training_type"
    t.float "percentage", default: 0.0
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_employee_trainings_on_employee_id"
  end

  create_table "employee_transaction_histories", force: :cascade do |t|
    t.integer "employee_id"
    t.string "transaction_type"
    t.string "old_employee_status", default: ""
    t.string "new_employee_status", default: ""
    t.float "old_gross_salary", default: 0.0
    t.float "new_gross_salary", default: 0.0
    t.string "old_employment_status", default: ""
    t.string "new_employment_status", default: ""
    t.datetime "transaction_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "transfer_type"
    t.integer "old_location_id"
    t.integer "new_location_id"
    t.integer "old_branch_id"
    t.integer "new_branch_id"
    t.integer "old_department_id"
    t.integer "new_department_id"
    t.integer "old_line_manager_id"
    t.integer "new_line_manager_id"
    t.boolean "hold_salary", default: false
    t.string "left_type"
    t.text "left_reason"
    t.integer "old_grade_id"
    t.integer "new_grade_id"
    t.integer "old_designation_id"
    t.integer "new_designation_id"
    t.integer "old_job_title_id"
    t.integer "new_job_title_id"
    t.integer "old_salary_unit_id"
    t.integer "new_salary_unit_id"
    t.integer "old_cost_center_id"
    t.integer "new_cost_center_id"
    t.string "new_employee_code"
    t.string "old_employee_code"
    t.text "remarks", default: ""
    t.integer "old_sub_department_id"
    t.integer "new_sub_department_id"
    t.integer "old_employee_type_id"
    t.integer "new_employee_type_id"
    t.float "probation_extension_days", default: 0.0
    t.datetime "old_confimration_due_date"
    t.datetime "new_confimration_due_date"
    t.datetime "old_joining_date"
    t.datetime "new_joining_date"
    t.string "action_performed"
    t.boolean "is_struck_off", default: false
    t.integer "old_hod_id"
    t.integer "new_hod_id"
    t.date "resign_date"
    t.index ["employee_id"], name: "index_employee_transaction_histories_on_employee_id"
  end

  create_table "employee_types", force: :cascade do |t|
    t.string "name"
    t.boolean "is_active", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employees", force: :cascade do |t|
    t.string "salutation"
    t.string "first_name"
    t.string "last_name"
    t.string "father_name"
    t.string "official_email"
    t.string "official_mobile_number"
    t.datetime "date_of_birth"
    t.string "gender"
    t.string "cnic_number"
    t.string "blood_group"
    t.string "martial_status"
    t.integer "company_id"
    t.integer "location_id"
    t.integer "branch_id"
    t.integer "department_id"
    t.integer "designation_id"
    t.integer "job_title_id"
    t.integer "grade_id"
    t.integer "salary_unit_id"
    t.integer "cost_center_id"
    t.datetime "joining_date"
    t.string "employee_code"
    t.string "prev_employee_code"
    t.boolean "on_probation", default: true
    t.boolean "is_line_manager", default: false
    t.boolean "is_active", default: true
    t.boolean "create_login", default: false
    t.integer "relationship_id"
    t.integer "user_id"
    t.string "payment_method"
    t.boolean "tax_exempted", default: false
    t.boolean "salary_exempted", default: false
    t.string "bank_name"
    t.string "bank_branch_name"
    t.string "bank_branch_code"
    t.string "bank_account_title"
    t.string "bank_account_number"
    t.float "gross_salary", default: 0.0
    t.boolean "is_admin", default: false
    t.boolean "custom_right", default: false
    t.integer "role_id"
    t.boolean "is_company_head", default: false
    t.boolean "is_location_head", default: false
    t.boolean "is_branch_head", default: false
    t.boolean "is_department_head", default: false
    t.string "user_account_email"
    t.string "user_account_password"
    t.string "emergency_contact_name"
    t.string "emergency_contact_email"
    t.string "emergency_contact_phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.text "current_address"
    t.integer "current_country_id"
    t.integer "current_state_id"
    t.integer "current_city_id"
    t.datetime "confirmation_date"
    t.integer "line_manager_id"
    t.boolean "hold_salary", default: false
    t.string "left_type"
    t.text "left_reason"
    t.integer "current_division_id"
    t.integer "current_district_id"
    t.integer "current_tehsil_id"
    t.integer "religion_sect_id"
    t.integer "religion_id"
    t.string "personal_email"
    t.string "personal_number"
    t.integer "sub_department_id"
    t.boolean "is_overtime", default: false
    t.boolean "is_off_day_working", default: false
    t.boolean "is_cpl", default: false
    t.boolean "attendance_exempted", default: false
    t.integer "employee_type_id"
    t.boolean "social_security_allowed", default: false
    t.string "social_security_eligibility"
    t.float "social_security_joining_salary", default: 0.0
    t.boolean "life_insurance_allowed", default: false
    t.string "life_insurance_eligibility"
    t.float "life_insurance_value", default: 0.0
    t.boolean "cell_phone_bill_allowed", default: false
    t.string "cell_phone_bill_eligibility"
    t.string "cell_phone_bill_limit"
    t.float "cell_phone_bill_amount", default: 0.0
    t.boolean "fuel_allowed", default: false
    t.string "fuel_eligibility"
    t.string "fuel_limit"
    t.float "fuel_value", default: 0.0
    t.boolean "cell_phone_allowed", default: false
    t.string "cell_phone_eligibility"
    t.float "cell_phone_entitlement_upto", default: 0.0
    t.boolean "laptop_allowed", default: false
    t.string "laptop_eligibility"
    t.float "laptop_entitlement_upto", default: 0.0
    t.boolean "velicle_allowed", default: false
    t.string "velicle_eligibility"
    t.boolean "provident_fund_allowed", default: false
    t.string "provident_fund_eligibility"
    t.boolean "eobi_allowed", default: false
    t.string "eobi_eligibility"
    t.boolean "incentive_allowed", default: false
    t.string "incentive_eligibility"
    t.boolean "vehicle_allowance_allowed", default: false
    t.string "vehicle_allowance_eligibility"
    t.float "vehicle_allowance_entitlement_upto", default: 0.0
    t.boolean "maintenance_allowed", default: false
    t.string "maintenance_eligibility"
    t.float "maintenance_entitlement_upto", default: 0.0
    t.boolean "travel_allowance_allowed", default: false
    t.string "travel_allowance_eligibility"
    t.float "travel_allowance_entitlement_upto", default: 0.0
    t.boolean "social_security_impact_allowed", default: false
    t.boolean "life_insurance_impact_allowed", default: false
    t.boolean "cell_phone_bill_impact_allowed", default: false
    t.boolean "fuel_impact_allowed", default: false
    t.boolean "cell_phone_impact_allowed", default: false
    t.boolean "laptop_impact_allowed", default: false
    t.boolean "velicle_impact_allowed", default: false
    t.boolean "provident_fund_impact_allowed", default: false
    t.boolean "eobi_impact_allowed", default: false
    t.boolean "incentive_impact_allowed", default: false
    t.boolean "vehicle_allowance_impact_allowed", default: false
    t.boolean "maintenance_impact_allowed", default: false
    t.boolean "travel_allowance_impact_allowed", default: false
    t.boolean "attendance_impact_allowed", default: false
    t.datetime "vehicle_assignment_date"
    t.float "vehicle_value", default: 0.0
    t.boolean "bonus1_impact_allowed", default: false
    t.boolean "bonus1_allowed", default: false
    t.string "bonus1_eligibility"
    t.boolean "bonus2_impact_allowed", default: false
    t.boolean "bonus2_allowed", default: false
    t.string "bonus2_eligibility"
    t.boolean "bonus3_impact_allowed", default: false
    t.boolean "bonus3_allowed", default: false
    t.string "bonus3_eligibility"
    t.boolean "back_date_eobi_impact", default: false
    t.boolean "back_date_pf_impact", default: false
    t.string "tags"
    t.boolean "back_date_allowance_impact", default: false
    t.string "security_number"
    t.boolean "health_insurance_impact_allowed", default: false
    t.boolean "health_insurance_allowed", default: false
    t.string "health_insurance_plan"
    t.string "health_insurance_eligibility"
    t.string "laptop_category"
    t.float "actual_laptop_value", default: 0.0
    t.datetime "confimration_due_date"
    t.datetime "social_security_other_date"
    t.datetime "life_insurance_other_date"
    t.datetime "cell_phone_bill_other_date"
    t.datetime "fuel_other_date"
    t.datetime "cell_phone_other_date"
    t.datetime "laptop_other_date"
    t.datetime "velicle_other_date"
    t.datetime "provident_fund_other_date"
    t.datetime "eobi_other_date"
    t.datetime "incentive_other_date"
    t.datetime "vehicle_allowance_other_date"
    t.datetime "maintenance_other_date"
    t.datetime "travel_allowance_other_date"
    t.datetime "bonus1_other_date"
    t.datetime "bonus2_other_date"
    t.datetime "bonus3_other_date"
    t.datetime "health_insurance_other_date"
    t.boolean "gratuity_impact_allowed", default: false
    t.boolean "gratuity_allowed", default: false
    t.string "gratuity_eligibility"
    t.datetime "gratuity_other_date"
    t.boolean "lfa_impact_allowed", default: false
    t.boolean "lfa_allowed", default: false
    t.string "lfa_eligibility"
    t.datetime "lfa_other_date"
    t.boolean "house_allowance_impact_allowed", default: false
    t.boolean "house_allowance_allowed", default: false
    t.string "house_allowance_eligibility"
    t.datetime "house_allowance_other_date"
    t.text "permanent_address"
    t.string "file_number"
    t.string "family_number"
    t.boolean "is_contractual", default: false
    t.datetime "contract_start_date"
    t.datetime "contract_end_date"
    t.boolean "late_exempted", default: false
    t.boolean "is_sub_department_head", default: false
    t.boolean "regular_quota_encashment", default: false
    t.boolean "holiday_quota_encashment", default: false
    t.integer "roster_employee_id"
    t.boolean "is_regular_cpl", default: false
    t.boolean "is_holiday_overtime", default: false
    t.string "eobi_number", default: ""
    t.string "nationality"
    t.datetime "cnic_expiry_date"
    t.string "vehicle_name"
    t.string "vehicle_model"
    t.string "laptop_name"
    t.string "laptop_model"
    t.string "cell_phone_name"
    t.string "cell_phone_model"
    t.datetime "laptop_assignment_date"
    t.datetime "cell_assignment_date"
    t.string "ntn_number"
    t.boolean "customize_tax", default: false
    t.string "tax_criteria", default: "Custom Tax Slab"
    t.float "fixed_tax_rate", default: 0.0
    t.boolean "excluded_from_reports", default: false
    t.boolean "approval_base_overtime", default: false
    t.boolean "is_medical_allowance", default: false
    t.datetime "old_joining_date"
    t.text "fuel_card_number", default: ""
    t.boolean "velicle_two_allowed", default: false
    t.string "velicle_two_eligibility", default: "Date of Joining"
    t.datetime "velicle_two_other_date"
    t.datetime "vehicle_two_assignment_date"
    t.string "vehicle_two_name", default: ""
    t.string "vehicle_two_model", default: ""
    t.float "vehicle_two_value", default: 0.0
    t.string "fuel_company_name"
    t.integer "hiring_shift_id"
    t.boolean "is_struck_off", default: false
    t.integer "hod_id"
    t.integer "floor_id"
    t.integer "category_id"
    t.string "incharge_id"
    t.integer "line_id"
    t.boolean "is_incharge", default: false
    t.string "group_id"
    t.string "vaccinee_file_name"
    t.string "vaccinee_content_type"
    t.integer "vaccinee_file_size"
    t.datetime "vaccinee_updated_at"
    t.boolean "vaccinated", default: false
    t.string "spouse_name"
    t.string "whatsapp_number"
    t.string "linkedln_url"
    t.datetime "marriage_date"
    t.string "languages_level"
    t.string "other"
    t.text "languages", default: ""
    t.string "skills_software"
    t.string "skills_level"
    t.string "criminal_record"
    t.boolean "disability", default: false
    t.string "passport_number"
    t.datetime "passport_expiry"
    t.string "license_number"
    t.datetime "license_expiry"
    t.string "disability_needs"
    t.integer "permanent_country_id"
    t.integer "permanent_state_id"
    t.integer "permanent_city_id"
    t.string "language_second"
    t.string "language_third"
    t.string "inter_level"
    t.string "expert_level"
    t.string "category"
    t.string "skills_second"
    t.string "skills_third"
    t.string "second_level"
    t.string "third_level"
    t.string "mother_name"
    t.index ["branch_id"], name: "index_employees_on_branch_id"
    t.index ["company_id"], name: "index_employees_on_company_id"
    t.index ["cost_center_id"], name: "index_employees_on_cost_center_id"
    t.index ["department_id"], name: "index_employees_on_department_id"
    t.index ["designation_id"], name: "index_employees_on_designation_id"
    t.index ["grade_id"], name: "index_employees_on_grade_id"
    t.index ["job_title_id"], name: "index_employees_on_job_title_id"
    t.index ["location_id"], name: "index_employees_on_location_id"
    t.index ["relationship_id"], name: "index_employees_on_relationship_id"
    t.index ["role_id"], name: "index_employees_on_role_id"
    t.index ["salary_unit_id"], name: "index_employees_on_salary_unit_id"
    t.index ["sub_department_id"], name: "index_employees_on_sub_department_id"
    t.index ["user_id"], name: "index_employees_on_user_id"
  end

  create_table "eobis", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.boolean "is_active", default: true
    t.boolean "employer_is_taxable", default: true
    t.boolean "employee_is_taxable", default: true
    t.float "employer_wage_rate", default: 0.0
    t.float "employer_percentage", default: 0.0
    t.float "employee_wage_rate", default: 0.0
    t.float "employee_percentage", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_eobis_on_company_id"
  end

  create_table "finalize_attendances", force: :cascade do |t|
    t.integer "employee_attendance_id"
    t.integer "attendance_cutoff_id"
    t.integer "employee_id"
    t.integer "company_id"
    t.integer "location_id"
    t.integer "branch_id"
    t.datetime "attendance_date"
    t.float "arrear_days", default: 0.0
    t.float "pay_deduction", default: 0.0
    t.float "over_time_hours", default: 0.0
    t.float "over_time_minutes", default: 0.0
    t.float "over_time_seconds", default: 0.0
    t.float "off_day_payment", default: 0.0
    t.boolean "is_finalize", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "encashable_quota", default: 0.0
    t.integer "salary_unit_id"
    t.index ["attendance_cutoff_id"], name: "index_finalize_attendances_on_attendance_cutoff_id"
    t.index ["branch_id"], name: "index_finalize_attendances_on_branch_id"
    t.index ["company_id"], name: "index_finalize_attendances_on_company_id"
    t.index ["employee_attendance_id"], name: "index_finalize_attendances_on_employee_attendance_id"
    t.index ["employee_id"], name: "index_finalize_attendances_on_employee_id"
    t.index ["location_id"], name: "index_finalize_attendances_on_location_id"
  end

  create_table "fiscal_years", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.boolean "is_active", default: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_fiscal_years_on_company_id"
  end

  create_table "fixed_pay_items", force: :cascade do |t|
    t.integer "company_id"
    t.integer "employee_id"
    t.integer "pay_item_id"
    t.float "item_amount", default: 0.0
    t.boolean "is_active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "item_type", default: "Recurring"
    t.datetime "pay_month"
    t.string "formated_pay_month"
    t.text "description"
    t.index ["company_id"], name: "index_fixed_pay_items_on_company_id"
    t.index ["employee_id"], name: "index_fixed_pay_items_on_employee_id"
    t.index ["pay_item_id"], name: "index_fixed_pay_items_on_pay_item_id"
  end

  create_table "flexi_logs", force: :cascade do |t|
    t.string "employee_full_name"
    t.string "employee_code"
    t.string "machine_name"
    t.datetime "attendance_datetime"
    t.datetime "attendance_date"
    t.string "actual_attendance_date"
    t.integer "formatted_hour"
    t.integer "formatted_minute"
    t.integer "formatted_second"
    t.string "log_id"
    t.integer "company_id"
    t.integer "employee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fuel_card_details", force: :cascade do |t|
    t.integer "employee_id"
    t.integer "company_id"
    t.string "card_no"
    t.string "card_name"
    t.string "registration"
    t.float "fleet_division", default: 0.0
    t.float "quantity_consumed", default: 0.0
    t.float "amount_consumed", default: 0.0
    t.float "last_km", default: 0.0
    t.float "consumption", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "general_types", force: :cascade do |t|
    t.string "name"
    t.integer "company_id"
    t.text "description"
    t.string "type_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "grade_allocation_details", force: :cascade do |t|
    t.integer "grade_allocation_id"
    t.integer "grade_id"
    t.boolean "is_selected", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["grade_allocation_id"], name: "index_grade_allocation_details_on_grade_allocation_id"
    t.index ["grade_id"], name: "index_grade_allocation_details_on_grade_id"
  end

  create_table "grade_allocations", force: :cascade do |t|
    t.integer "company_id"
    t.integer "location_id"
    t.integer "branch_id"
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_grade_allocations_on_branch_id"
    t.index ["company_id"], name: "index_grade_allocations_on_company_id"
    t.index ["location_id"], name: "index_grade_allocations_on_location_id"
  end

  create_table "grades", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.integer "company_id"
    t.string "currency_title"
    t.boolean "is_active", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sort_order", default: 0
    t.string "management_type"
    t.string "management_tier"
    t.index ["company_id"], name: "index_grades_on_company_id"
  end

  create_table "holidays", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.string "code"
    t.text "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "religion_id"
    t.boolean "specific_religion", default: false
    t.integer "location_id"
    t.string "branch_ids"
    t.boolean "location_wise", default: false
    t.index ["company_id"], name: "index_holidays_on_company_id"
  end

  create_table "incentive_policies", force: :cascade do |t|
    t.integer "company_id"
    t.boolean "is_active", default: false
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_incentive_policies_on_company_id"
  end

  create_table "incentive_slabs", force: :cascade do |t|
    t.integer "incentive_policy_id"
    t.float "min_target_sale_percentage", default: 0.0
    t.float "max_target_sale_percentage", default: 0.0
    t.float "sale_incentive_percentage", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["incentive_policy_id"], name: "index_incentive_slabs_on_incentive_policy_id"
  end

  create_table "internees", force: :cascade do |t|
    t.string "salutation"
    t.string "first_name"
    t.string "last_name"
    t.string "father_name"
    t.string "official_email"
    t.string "official_mobile_number"
    t.string "personal_email"
    t.string "personal_number"
    t.datetime "date_of_birth"
    t.string "gender"
    t.string "cnic_number"
    t.string "blood_group"
    t.string "martial_status"
    t.float "gross_salary", default: 0.0
    t.integer "company_id"
    t.integer "location_id"
    t.integer "branch_id"
    t.integer "department_id"
    t.integer "grade_id"
    t.integer "designation_id"
    t.integer "job_title_id"
    t.integer "salary_unit_id"
    t.integer "cost_center_id"
    t.datetime "joining_date"
    t.string "internee_code"
    t.boolean "is_active", default: false
    t.text "current_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_converted", default: false
    t.integer "sub_department_id"
    t.index ["sub_department_id"], name: "index_internees_on_sub_department_id"
  end

  create_table "item_execution_details", force: :cascade do |t|
    t.integer "pay_execution_id"
    t.integer "pay_item_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pay_execution_id"], name: "index_item_execution_details_on_pay_execution_id"
    t.index ["pay_item_id"], name: "index_item_execution_details_on_pay_item_id"
  end

  create_table "job_titles", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.boolean "is_active", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_job_titles_on_company_id"
  end

  create_table "leave_allocations", force: :cascade do |t|
    t.integer "company_id"
    t.integer "employee_id"
    t.integer "leave_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "allocated_quota", default: 0.0
    t.float "remaining_quota", default: 0.0
    t.float "used_quota", default: 0.0
    t.integer "leave_year_id"
    t.datetime "leave_year_start_date"
    t.datetime "leave_year_end_date"
    t.boolean "is_active", default: false
    t.integer "location_id"
    t.index ["company_id"], name: "index_leave_allocations_on_company_id"
    t.index ["employee_id"], name: "index_leave_allocations_on_employee_id"
    t.index ["leave_type_id"], name: "index_leave_allocations_on_leave_type_id"
  end

  create_table "leave_request_details", force: :cascade do |t|
    t.integer "leave_request_id"
    t.integer "leave_type_id"
    t.float "allocated_quota", default: 0.0
    t.float "used_quota", default: 0.0
    t.float "remaining_quota", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "quota_transaction", default: 0.0
  end

  create_table "leave_requests", force: :cascade do |t|
    t.integer "company_id"
    t.integer "employee_id"
    t.integer "leave_type_id"
    t.float "allocated_quota", default: 0.0
    t.float "used_quota", default: 0.0
    t.float "remaining_quota", default: 0.0
    t.float "request_count", default: 0.0
    t.float "sandwich_count", default: 0.0
    t.datetime "min_apply_date"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "request_status"
    t.string "apply_status"
    t.boolean "is_cancelled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "reason"
    t.string "leave_category", default: "Full Day"
    t.boolean "is_composite", default: false
    t.string "request_sender_name", default: ""
    t.string "approval_name", default: "-"
    t.datetime "approval_datetime"
    t.index ["company_id"], name: "index_leave_requests_on_company_id"
    t.index ["employee_id"], name: "index_leave_requests_on_employee_id"
    t.index ["leave_type_id"], name: "index_leave_requests_on_leave_type_id"
  end

  create_table "leave_transaction_histories", force: :cascade do |t|
    t.integer "company_id"
    t.integer "employee_id"
    t.integer "leave_type_id"
    t.integer "leave_request_id"
    t.float "allocated_quota", default: 0.0
    t.float "remaining_quota", default: 0.0
    t.float "used_quota", default: 0.0
    t.float "quota_transaction"
    t.string "transaction_type"
    t.text "remarks"
    t.datetime "transaction_date"
    t.datetime "leave_year_start_date"
    t.datetime "leave_year_end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "leave_allocation_id"
    t.index ["company_id"], name: "index_leave_transaction_histories_on_company_id"
    t.index ["employee_id"], name: "index_leave_transaction_histories_on_employee_id"
    t.index ["leave_request_id"], name: "index_leave_transaction_histories_on_leave_request_id"
    t.index ["leave_type_id"], name: "index_leave_transaction_histories_on_leave_type_id"
  end

  create_table "leave_types", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.string "short_name"
    t.string "gender"
    t.string "tenure"
    t.string "eligible"
    t.string "encashment_applicable"
    t.string "limit_request_tenure"
    t.boolean "is_active", default: false
    t.boolean "is_deductible", default: false
    t.boolean "sandwich", default: false
    t.boolean "splitable", default: false
    t.boolean "can_apply_in_probation", default: false
    t.boolean "pro_rated", default: false
    t.boolean "can_apply_for_remaining_leave", default: false
    t.boolean "back_date_apply", default: false
    t.boolean "encashment", default: false
    t.boolean "carry_forward", default: false
    t.boolean "limit_request_in_tenure", default: false
    t.float "accumulative_count", default: 0.0
    t.float "min_day_for_apply_leave", default: 0.0
    t.float "min_experience_to_availed_leave", default: 0.0
    t.float "limit_request_count", default: 0.0
    t.float "back_date_limit", default: 0.0
    t.float "encashment_min_limit", default: 0.0
    t.float "encashment_max_limit", default: 0.0
    t.float "carry_forward_min_limit", default: 0.0
    t.float "carry_forward_max_limit", default: 0.0
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "quota_allocation", default: false
    t.boolean "earned_quota", default: false
    t.integer "sort_order", default: 0
    t.integer "location_id"
    t.boolean "auto_allocation", default: false
    t.boolean "special_leave", default: false
    t.float "earned_quota_max_limit", default: 0.0
    t.string "no_of_years", default: ""
    t.boolean "backdate_quota", default: false
    t.boolean "is_composite", default: false
    t.boolean "attendance_restricted", default: false
    t.string "attendance_restricted_applicable"
    t.float "no_of_absent", default: 0.0
    t.boolean "is_leave_without_pay", default: false
    t.boolean "skipped_joining_month", default: false
    t.string "experience_type", default: "Day"
    t.boolean "probation_limit_request_in_tenure", default: false
    t.string "probation_limit_request_tenure", default: "Monthly"
    t.float "probation_limit_request_count", default: 0.0
    t.boolean "transfer_probation_balance", default: false
    t.string "grade_ids"
    t.index ["company_id"], name: "index_leave_types_on_company_id"
  end

  create_table "leave_years", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.boolean "is_active", default: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_leave_years_on_company_id"
  end

  create_table "left_reasons", force: :cascade do |t|
    t.string "name"
    t.boolean "is_active", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.string "code"
    t.text "description"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "employee_code_prefix", default: 0.0
    t.index ["company_id"], name: "index_locations_on_company_id"
  end

  create_table "missing_punches", force: :cascade do |t|
    t.integer "company_id"
    t.integer "attendance_deduction_id"
    t.integer "fallback_id"
    t.string "name"
    t.string "code"
    t.boolean "is_active", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attendance_deduction_id"], name: "index_missing_punches_on_attendance_deduction_id"
    t.index ["company_id"], name: "index_missing_punches_on_company_id"
    t.index ["fallback_id"], name: "index_missing_punches_on_fallback_id"
  end

  create_table "notification_recipients", force: :cascade do |t|
    t.integer "recievable_id"
    t.string "recievable_type"
    t.boolean "did_read", default: false
    t.boolean "archived", default: false
    t.string "content"
    t.bigint "notification_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_id"], name: "index_notification_recipients_on_notification_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "notifiable_type"
    t.bigint "notifiable_id"
    t.string "sendable_type"
    t.bigint "sendable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["sendable_type", "sendable_id"], name: "index_notifications_on_sendable"
  end

  create_table "objective_comments", force: :cascade do |t|
    t.bigint "user_id"
    t.text "body"
    t.bigint "objective_setting_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "line_manager_approval", default: "Pending"
    t.string "status", default: "Pending"
    t.integer "employee_id"
    t.integer "fiscal_year_id"
    t.integer "comment_type", default: 1
    t.index ["objective_setting_id"], name: "index_objective_comments_on_objective_setting_id"
    t.index ["user_id"], name: "index_objective_comments_on_user_id"
  end

  create_table "objective_settings", force: :cascade do |t|
    t.string "starting_weight"
    t.string "ending_weight"
    t.integer "employee_id"
    t.text "task_ids"
    t.text "sub_task_ids"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "fiscal_year_id"
    t.string "status", default: "Pending"
    t.string "comments", default: "Nill"
    t.string "employee_name"
    t.string "line_manager_approval", default: "Pending"
    t.string "appraisal_status", default: "Pending"
    t.string "line_manager_appraisal_approval", default: "Pending"
    t.string "hod_approval_status", default: "Pending"
    t.index ["employee_id"], name: "index_objective_settings_on_employee_id"
  end

  create_table "official_duties", force: :cascade do |t|
    t.integer "company_id"
    t.integer "employee_id"
    t.float "request_count", default: 0.0
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "request_status"
    t.string "apply_status"
    t.boolean "is_cancelled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "reason"
    t.boolean "is_full_day", default: false
    t.string "request_sender_name", default: ""
    t.string "approval_name", default: "-"
    t.datetime "approval_datetime"
    t.string "official_duty_mode", default: "Office Duty"
    t.index ["company_id"], name: "index_official_duties_on_company_id"
    t.index ["employee_id"], name: "index_official_duties_on_employee_id"
  end

  create_table "over_strength_requests", force: :cascade do |t|
    t.integer "company_id"
    t.integer "employee_id"
    t.integer "department_id"
    t.float "request_count", default: 0.0
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "request_status"
    t.string "apply_status"
    t.boolean "is_cancelled", default: false
    t.text "reason"
    t.string "request_sender_name", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_over_strength_requests_on_company_id"
    t.index ["department_id"], name: "index_over_strength_requests_on_department_id"
    t.index ["employee_id"], name: "index_over_strength_requests_on_employee_id"
  end

  create_table "pay_executions", force: :cascade do |t|
    t.string "name"
    t.integer "company_id"
    t.integer "location_id"
    t.integer "provident_fund_id"
    t.integer "eobi_id"
    t.integer "tax_slab_id"
    t.integer "fiscal_year_id"
    t.datetime "pay_month"
    t.string "formated_pay_month"
    t.boolean "tax_applicable", default: false
    t.boolean "is_executed", default: false
    t.float "no_of_pay_days", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_generated", default: false
    t.float "per_litre_rate", default: 0.0
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean "is_locked", default: false
    t.boolean "incentive_impact_on_tax", default: false
    t.datetime "incentive_month"
    t.boolean "prediction_tax_impact", default: false
    t.boolean "opd_impact_on_arrear", default: false
    t.boolean "vehicle_impact_on_tax", default: false
    t.float "vehicle_tax_percentage", default: 0.0
    t.text "grade_ids"
    t.boolean "allowed_urdu", default: false
    t.boolean "exclude_sunday", default: false
    t.float "joining_exception_pay_days", default: 0.0
    t.string "joining_exception_formated_month"
    t.datetime "joining_exception_month"
    t.boolean "joining_exception", default: false
    t.boolean "vehicle_monthly_prorated", default: false
    t.boolean "allowed_extra_days", default: false
    t.text "attendance_cutoff_ids"
    t.index ["company_id"], name: "index_pay_executions_on_company_id"
    t.index ["eobi_id"], name: "index_pay_executions_on_eobi_id"
    t.index ["fiscal_year_id"], name: "index_pay_executions_on_fiscal_year_id"
    t.index ["location_id"], name: "index_pay_executions_on_location_id"
    t.index ["provident_fund_id"], name: "index_pay_executions_on_provident_fund_id"
    t.index ["tax_slab_id"], name: "index_pay_executions_on_tax_slab_id"
  end

  create_table "pay_invoice_details", force: :cascade do |t|
    t.integer "item_id"
    t.integer "pay_invoice_id"
    t.integer "sort_order", default: 0
    t.string "item_type"
    t.string "item_name"
    t.float "amount", default: 0.0
    t.float "taxable_amount", default: 0.0
    t.boolean "show_in_slip", default: false
    t.boolean "part_of_other", default: false
    t.boolean "part_of_gross_salary", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_pay_invoice_details_on_item_id"
    t.index ["pay_invoice_id"], name: "index_pay_invoice_details_on_pay_invoice_id"
  end

  create_table "pay_invoices", force: :cascade do |t|
    t.integer "employee_id"
    t.integer "pay_execution_id"
    t.integer "fiscal_year_id"
    t.integer "provident_fund_id"
    t.integer "eobi_id"
    t.integer "tax_slab_id"
    t.integer "company_id"
    t.integer "location_id"
    t.integer "branch_id"
    t.integer "department_id"
    t.integer "sub_department_id"
    t.integer "designation_id"
    t.integer "job_title_id"
    t.integer "grade_id"
    t.integer "salary_unit_id"
    t.integer "cost_center_id"
    t.string "invoice_number"
    t.text "slip_message"
    t.float "total_earning", default: 0.0
    t.float "total_deduction", default: 0.0
    t.float "net_pay_amount", default: 0.0
    t.float "tax_amount", default: 0.0
    t.float "deduction_days", default: 0.0
    t.float "over_time_hours", default: 0.0
    t.float "off_day_payment", default: 0.0
    t.float "arrears_days", default: 0.0
    t.datetime "joining_date"
    t.datetime "confirmation_date"
    t.boolean "on_probation", default: false
    t.boolean "status", default: true
    t.boolean "is_locked", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "short_joining_days", default: 0.0
    t.float "short_confirmation_days", default: 0.0
    t.float "vehicle_months", default: 0.0
    t.string "pay_month"
    t.float "actual_salary", default: 0.0
    t.float "payable_gross", default: 0.0
    t.float "remaining_tax_year_month", default: 0.0
    t.float "monthly_tax", default: 0.0
    t.float "total_pf_months", default: 0.0
    t.float "no_of_days_till_joining", default: 0.0
    t.datetime "actual_pay_month"
    t.float "encashable_quota", default: 0.0
    t.float "eobi_short_joining_days", default: 0.0
    t.float "eobi_no_of_days_till_joining", default: 0.0
    t.boolean "customize_tax", default: false
    t.string "tax_criteria", default: ""
    t.float "fixed_tax_rate", default: 0.0
    t.float "extra_pay_days", default: 0.0
    t.boolean "allowed_extra_days", default: false
    t.integer "employee_type_id"
    t.boolean "is_medical_allowance", default: false
    t.float "quota_encashment", default: 0.0
    t.index ["branch_id"], name: "index_pay_invoices_on_branch_id"
    t.index ["company_id"], name: "index_pay_invoices_on_company_id"
    t.index ["cost_center_id"], name: "index_pay_invoices_on_cost_center_id"
    t.index ["department_id"], name: "index_pay_invoices_on_department_id"
    t.index ["designation_id"], name: "index_pay_invoices_on_designation_id"
    t.index ["employee_id"], name: "index_pay_invoices_on_employee_id"
    t.index ["eobi_id"], name: "index_pay_invoices_on_eobi_id"
    t.index ["fiscal_year_id"], name: "index_pay_invoices_on_fiscal_year_id"
    t.index ["grade_id"], name: "index_pay_invoices_on_grade_id"
    t.index ["job_title_id"], name: "index_pay_invoices_on_job_title_id"
    t.index ["location_id"], name: "index_pay_invoices_on_location_id"
    t.index ["pay_execution_id"], name: "index_pay_invoices_on_pay_execution_id"
    t.index ["provident_fund_id"], name: "index_pay_invoices_on_provident_fund_id"
    t.index ["salary_unit_id"], name: "index_pay_invoices_on_salary_unit_id"
    t.index ["sub_department_id"], name: "index_pay_invoices_on_sub_department_id"
    t.index ["tax_slab_id"], name: "index_pay_invoices_on_tax_slab_id"
  end

  create_table "pay_items", force: :cascade do |t|
    t.integer "company_id"
    t.string "eligible_from"
    t.string "name"
    t.string "code"
    t.string "item_type"
    t.string "calculation_type"
    t.boolean "is_active", default: false
    t.boolean "show_in_slip", default: false
    t.boolean "part_of_other", default: false
    t.boolean "is_taxable", default: false
    t.float "exempted_tax_percentage", default: 0.0
    t.string "formula"
    t.boolean "is_bonus", default: false
    t.datetime "bonus_date"
    t.string "bonus_month"
    t.text "formula_with_code"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "sort_order", default: 0.0
    t.boolean "part_of_gross_salary", default: false
    t.string "bonus_type"
    t.boolean "prediction_tax_impact", default: false
    t.text "name_in_urdu", default: ""
    t.boolean "is_urdu", default: false
    t.boolean "is_static_item", default: false
    t.boolean "annualize", default: false
    t.index ["company_id"], name: "index_pay_items_on_company_id"
  end

  create_table "payitem_expressions", force: :cascade do |t|
    t.string "name"
    t.float "expression_value", default: 0.0
    t.boolean "is_active", default: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "piece_slab_details", force: :cascade do |t|
    t.integer "piece_slab_id"
    t.float "lower_limit", default: 0.0
    t.float "upper_limit", default: 0.0
    t.float "fixed_amount", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["piece_slab_id"], name: "index_piece_slab_details_on_piece_slab_id"
  end

  create_table "piece_slabs", force: :cascade do |t|
    t.integer "company_id"
    t.integer "location_id"
    t.boolean "is_active", default: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_piece_slabs_on_company_id"
    t.index ["location_id"], name: "index_piece_slabs_on_location_id"
  end

  create_table "piecerates", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "piecerate_type_name"
    t.integer "floor_id"
    t.integer "total_machines"
    t.integer "line_id"
    t.integer "category_id"
  end

  create_table "provident_funds", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.boolean "is_active", default: false
    t.string "employee_value", default: "0.0"
    t.float "employee_fixed_amount", default: 0.0
    t.float "employee_percentage", default: 0.0
    t.integer "employee_pay_item_id"
    t.string "employer_value", default: "0.0"
    t.float "employer_fixed_amount", default: 0.0
    t.float "employer_percentage", default: 0.0
    t.integer "employer_pay_item_id"
    t.boolean "employer_taxable", default: false
    t.float "employer_amount_exceed", default: 0.0
    t.float "employer_tax_percentage", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_provident_funds_on_company_id"
    t.index ["employee_pay_item_id"], name: "index_provident_funds_on_employee_pay_item_id"
    t.index ["employer_pay_item_id"], name: "index_provident_funds_on_employer_pay_item_id"
  end

  create_table "qualfication_types", force: :cascade do |t|
    t.string "name"
    t.boolean "is_active", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "qualification_programs", force: :cascade do |t|
    t.string "name"
    t.boolean "is_active", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "relationships", force: :cascade do |t|
    t.string "name"
    t.boolean "is_active", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "relaxation_requests", force: :cascade do |t|
    t.integer "company_id"
    t.integer "employee_id"
    t.integer "attendance_type_id"
    t.float "request_count", default: 0.0
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "request_status"
    t.string "apply_status"
    t.boolean "is_cancelled", default: false
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "request_sender_name", default: ""
    t.string "approval_name", default: "-"
    t.datetime "approval_datetime"
    t.float "criteria", default: 0.0
    t.datetime "relaxation_start_date"
    t.datetime "relaxation_end_date"
    t.index ["attendance_type_id"], name: "index_relaxation_requests_on_attendance_type_id"
    t.index ["company_id"], name: "index_relaxation_requests_on_company_id"
    t.index ["employee_id"], name: "index_relaxation_requests_on_employee_id"
  end

  create_table "religion_sects", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "religions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "request_flow_details", force: :cascade do |t|
    t.integer "request_flow_id"
    t.integer "department_id"
    t.integer "employee_id"
    t.string "request_node"
    t.boolean "specific_condition", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "branch_id"
    t.float "criteria"
    t.index ["branch_id"], name: "index_request_flow_details_on_branch_id"
    t.index ["department_id"], name: "index_request_flow_details_on_department_id"
    t.index ["employee_id"], name: "index_request_flow_details_on_employee_id"
    t.index ["request_flow_id"], name: "index_request_flow_details_on_request_flow_id"
  end

  create_table "request_flows", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.string "request_flow_type"
    t.string "request_node"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "criteria"
    t.float "back_date_limit", default: 0.0
    t.boolean "back_date_apply", default: false
    t.index ["company_id"], name: "index_request_flows_on_company_id"
  end

  create_table "restrict_leaves", force: :cascade do |t|
    t.integer "leave_days"
    t.integer "approval_days"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "notification"
    t.string "receiver_email"
    t.integer "company_id"
    t.string "user_id"
    t.text "user_ids"
  end

  create_table "role_permissions", force: :cascade do |t|
    t.string "display_name"
    t.string "module_name"
    t.boolean "index_access", default: false
    t.boolean "create_access", default: false
    t.boolean "view_access", default: false
    t.boolean "update_access", default: false
    t.boolean "delete_access", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "main_module"
    t.integer "role_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.integer "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active", default: true
    t.index ["company_id"], name: "index_roles_on_company_id"
  end

  create_table "salary_units", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.boolean "is_active", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_salary_units_on_company_id"
  end

  create_table "sale_entries", force: :cascade do |t|
    t.integer "company_id"
    t.integer "location_id"
    t.integer "branch_id"
    t.string "name"
    t.datetime "sale_month"
    t.string "formated_month"
    t.integer "sale_value", default: 0
    t.integer "profit_value", default: 0
    t.integer "loss_value", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "target_value", default: 0.0
    t.float "incentive_payable", default: 0.0
  end

  create_table "sms_configrations", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.string "url"
    t.string "user_name"
    t.string "password"
    t.string "show_password"
    t.string "masking"
    t.boolean "is_active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_sms_configrations_on_company_id"
  end

  create_table "sms_executions", force: :cascade do |t|
    t.integer "company_id"
    t.integer "location_id"
    t.integer "branch_id"
    t.integer "grade_id"
    t.string "name"
    t.integer "sms_template_id"
    t.string "trigger"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_sms_executions_on_branch_id"
    t.index ["company_id"], name: "index_sms_executions_on_company_id"
    t.index ["grade_id"], name: "index_sms_executions_on_grade_id"
    t.index ["location_id"], name: "index_sms_executions_on_location_id"
    t.index ["sms_template_id"], name: "index_sms_executions_on_sms_template_id"
  end

  create_table "sms_templates", force: :cascade do |t|
    t.integer "company_id"
    t.integer "sms_configration_id"
    t.string "name"
    t.boolean "is_active", default: false
    t.boolean "is_exempted", default: false
    t.string "exempted_numbers"
    t.string "trigger"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_sms_templates_on_company_id"
    t.index ["sms_configration_id"], name: "index_sms_templates_on_sms_configration_id"
  end

  create_table "specializations", force: :cascade do |t|
    t.string "name"
    t.boolean "is_active", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "states", force: :cascade do |t|
    t.string "name"
    t.integer "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_states_on_country_id"
  end

  create_table "sub_departments", force: :cascade do |t|
    t.integer "company_id"
    t.integer "department_id"
    t.string "name"
    t.string "code"
    t.text "description"
    t.boolean "is_active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_sub_departments_on_company_id"
    t.index ["department_id"], name: "index_sub_departments_on_department_id"
  end

  create_table "sub_tasks", force: :cascade do |t|
    t.integer "task_id"
    t.string "kpi"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_sub_tasks_on_task_id"
  end

  create_table "sub_time_slots", force: :cascade do |t|
    t.integer "company_id"
    t.integer "location_id"
    t.integer "branch_id"
    t.integer "time_slot_id"
    t.string "name"
    t.string "code"
    t.string "actual_start_time"
    t.string "actual_end_time"
    t.datetime "start_time"
    t.datetime "end_time"
    t.float "start_buffer", default: 0.0
    t.float "end_buffer", default: 0.0
    t.boolean "is_active", default: false
    t.text "description"
    t.float "total_working_minutes", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_sub_time_slots_on_branch_id"
    t.index ["company_id"], name: "index_sub_time_slots_on_company_id"
    t.index ["location_id"], name: "index_sub_time_slots_on_location_id"
    t.index ["time_slot_id"], name: "index_sub_time_slots_on_time_slot_id"
  end

  create_table "system_settings", force: :cascade do |t|
    t.integer "company_id"
    t.string "name"
    t.string "employee_prefix_code_usage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_employee_code_changeable", default: false
    t.boolean "live_leave_earning", default: false
    t.boolean "live_leave_deduction", default: false
    t.boolean "auto_arrear", default: false
    t.boolean "od_upper_cap_allowed", default: false
    t.float "od_upper_cap_limit", default: 0.0
    t.boolean "full_day_leave", default: true
    t.boolean "half_day_leave", default: true
    t.boolean "short_day_leave", default: true
    t.float "confirmation_days", default: 0.0
    t.string "confirmation_type", default: "Day"
    t.float "no_of_month", default: 0.0
    t.float "subtracted_days", default: 0.0
    t.boolean "location_wise_department", default: false
    t.boolean "location_wise_grade", default: false
    t.boolean "back_date_calculation", default: false
    t.boolean "advance_leave_allowed", default: false
    t.float "advance_leave_limit", default: 0.0
    t.boolean "auto_attendance_fetching", default: false
    t.boolean "auto_attendance_process", default: false
    t.text "schedule_time", default: ""
    t.float "attendance_days", default: 0.0
    t.boolean "in_process_leave_allowed", default: false
    t.boolean "overtime_execption", default: false
    t.boolean "pay_deduction_on_missing_in", default: false
    t.boolean "other_remarks_on_time_card", default: false
    t.boolean "arrear_overtime", default: false
    t.boolean "arrear_new_joiner", default: false
    t.boolean "arrear_off_day_payment", default: false
    t.boolean "od_restriction", default: false
    t.text "od_message", default: ""
    t.datetime "od_start_date"
    t.datetime "od_end_date"
    t.boolean "hide_religion", default: false
    t.boolean "hide_religion_sect", default: false
    t.boolean "leverage_minutes", default: false
    t.index ["company_id"], name: "index_system_settings_on_company_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "goal"
    t.string "weight"
    t.string "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "employee_id"
    t.integer "fiscal_year_id"
    t.integer "sr_number"
    t.integer "employee_rating"
    t.string "achievement_date"
    t.float "weighted_score"
    t.integer "line_manager_rating"
    t.float "line_manager_weighted_score"
    t.date "start_date"
  end

  create_table "tax_certificates", force: :cascade do |t|
    t.string "sr_number"
    t.string "date_of_issue"
    t.integer "employee_id"
    t.integer "fiscal_year_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tax_slab_details", force: :cascade do |t|
    t.integer "tax_slab_id"
    t.float "lower_limit", default: 0.0
    t.float "upper_limit", default: 0.0
    t.float "tax_percentage", default: 0.0
    t.float "fixed_amount", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tax_slab_id"], name: "index_tax_slab_details_on_tax_slab_id"
  end

  create_table "tax_slabs", force: :cascade do |t|
    t.integer "company_id"
    t.boolean "is_active", default: false
    t.string "name"
    t.string "code"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_tax_slabs_on_company_id"
  end

  create_table "tehsils", force: :cascade do |t|
    t.integer "division_id"
    t.integer "district_id"
    t.integer "country_id"
    t.integer "state_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_tehsils_on_country_id"
    t.index ["district_id"], name: "index_tehsils_on_district_id"
    t.index ["division_id"], name: "index_tehsils_on_division_id"
    t.index ["state_id"], name: "index_tehsils_on_state_id"
  end

  create_table "temp_staff_attendances", force: :cascade do |t|
    t.integer "company_id"
    t.integer "temporary_staff_id"
    t.string "attendance_status"
    t.datetime "in_time"
    t.datetime "out_time"
    t.datetime "attendance_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_temp_staff_attendances_on_company_id"
    t.index ["temporary_staff_id"], name: "index_temp_staff_attendances_on_temporary_staff_id"
  end

  create_table "temp_tbl_bonus", force: :cascade do |t|
    t.string "emp_code"
    t.float "jan", default: 0.0
    t.float "feb", default: 0.0
    t.float "mar", default: 0.0
    t.float "apr", default: 0.0
    t.float "may", default: 0.0
    t.float "june", default: 0.0
    t.float "july", default: 0.0
    t.float "aug", default: 0.0
    t.float "sep", default: 0.0
    t.float "oct", default: 0.0
    t.float "nov", default: 0.0
    t.float "dec", default: 0.0
    t.float "total", default: 0.0
    t.float "bonus", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "temporary_staffs", force: :cascade do |t|
    t.string "salutation"
    t.string "first_name"
    t.string "last_name"
    t.string "father_name"
    t.string "official_email"
    t.string "official_mobile_number"
    t.string "personal_email"
    t.string "personal_number"
    t.datetime "date_of_birth"
    t.string "gender"
    t.string "cnic_number"
    t.string "blood_group"
    t.string "martial_status"
    t.string "gross_salary", default: "0.0"
    t.integer "company_id"
    t.integer "location_id"
    t.integer "branch_id"
    t.integer "department_id"
    t.integer "grade_id"
    t.integer "designation_id"
    t.integer "job_title_id"
    t.integer "salary_unit_id"
    t.integer "cost_center_id"
    t.datetime "joining_date"
    t.string "temporary_staff_code"
    t.boolean "is_active", default: false
    t.text "current_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_converted", default: false
    t.integer "sub_department_id"
    t.index ["sub_department_id"], name: "index_temporary_staffs_on_sub_department_id"
  end

  create_table "time_slots", force: :cascade do |t|
    t.integer "company_id"
    t.integer "location_id"
    t.string "name"
    t.string "code"
    t.string "actual_start_time"
    t.string "actual_end_time"
    t.datetime "start_time"
    t.datetime "end_time"
    t.float "start_buffer", default: 0.0
    t.float "end_buffer", default: 0.0
    t.boolean "is_active", default: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "branch_id"
    t.boolean "is_flexi", default: false
    t.float "total_working_minutes", default: 0.0
    t.index ["branch_id"], name: "index_time_slots_on_branch_id"
    t.index ["company_id"], name: "index_time_slots_on_company_id"
    t.index ["location_id"], name: "index_time_slots_on_location_id"
  end

  create_table "training_types", force: :cascade do |t|
    t.string "name"
    t.boolean "is_active", default: true
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_activities", force: :cascade do |t|
    t.string "full_name", default: ""
    t.string "email", default: ""
    t.string "action_performed", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ip_address"
    t.string "role_name"
    t.integer "company_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "deleted_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "authentication_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_confirmed", default: false
    t.boolean "is_active", default: true
    t.boolean "is_admin", default: true
    t.boolean "custom_right", default: false
    t.integer "role_id"
    t.integer "company_id"
    t.boolean "is_company_head", default: false
    t.boolean "is_location_head", default: false
    t.boolean "is_branch_head", default: false
    t.boolean "is_department_head", default: false
    t.integer "login_count", default: 0
    t.boolean "first_login", default: false
    t.boolean "is_sub_department_head", default: false
    t.boolean "multi_branch_allowed", default: false
    t.text "branch_ids", default: ""
    t.boolean "all_company_department", default: false
    t.boolean "request_on_dashboard", default: false
    t.boolean "hris_dashboard", default: false
    t.boolean "salary_dashboard", default: false
    t.boolean "attendance_dashboard", default: false
    t.boolean "is_dtl", default: false
    t.boolean "is_wager", default: false
    t.boolean "is_piece_rate", default: false
    t.boolean "is_line_manager", default: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
  end

  add_foreign_key "cpl_earnings", "employee_attendances"
  add_foreign_key "cpl_earnings", "employees"
  add_foreign_key "objective_comments", "objective_settings"
  add_foreign_key "objective_comments", "users"
end
