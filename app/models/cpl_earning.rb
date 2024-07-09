class CplEarning < ApplicationRecord
  belongs_to :employee
  belongs_to :employee_attendance
  has_one :approval_request, class_name: 'ApprovalRequest', as: :requestable

  after_save :cpl_approval_request

  enum status: [:Pending, :Availed, :Cancelled, :Rejected, :Reverted]
  enum request_type: [:in_time, :out_time, :both]
  validates_uniqueness_of :employee_attendance_id, message: 'CPL request already applied.'

  def employee_name
    employee.full_name
  end

  private
  def cpl_approval_request
    requested_employee 				= employee
    if status == 'Pending'
      request_flow = RequestFlow.find_by(:company_id => requested_employee.company_id, :request_flow_type => "Cpl Earning")
      if request_flow.nil?
        self.status = 'Availed'
        self.save
      else
        if request_flow.request_node == 'Line Manager'
          approval_employee = self.employee.line_manager
          ########## Send Approval Request ##########
          ApprovalRequest.generate_approval_request(requested_employee.company_id, requested_employee.id, approval_employee.id, request_flow.id, 'Waiting For Approval', self.id, self.class.name)
          #############################################
          ########## Notification Generation ##########
          #############################################
          request_by_user = requested_employee.user
          request_to_user = approval_employee.user
          if not request_by_user.nil?
            Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "Your Cpl Earning Request has forward to #{approval_employee.full_name} for Approval")
          end
          if not request_to_user.nil?
            Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "#{requested_employee.full_name} submitted a Cpl Earning Request")
          end
          if not (request_by_user.nil? or request_to_user.nil?)
            email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Cpl Earning Request")
            if not email_template.nil?
              EmailOutbound.initiate_email_notification(email_template, request_to_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user)
            end
          end
          #############################################
          ########## Notification Generation ##########
          #############################################
        elsif request_flow.request_node == 'HOD'
          approval_employee = Employee.department_head(requested_employee)
          if not approval_employee.nil?
            ########## Send Approval Request ##########
            ApprovalRequest.generate_approval_request(requested_employee.company_id, requested_employee.id, approval_employee.id, request_flow.id, "Waiting For Approval", self.id, self.class.name)
            #############################################
            ########## Notification Generation ##########
            #############################################
            request_by_user = requested_employee.user
            request_to_user = approval_employee.user
            if not request_by_user.nil?
              Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "Your Cpl Earning Request has forward to #{approval_employee.full_name} for Approval")
            end
            if not request_to_user.nil?
              Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "#{requested_employee.full_name} submitted a Official Duty Request")
            end
            if not (request_by_user.nil? or request_to_user.nil?)
              email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => 'Cpl Earning Request')
              RequestFlow.request_flow_next_level_notification(request_flow, requested_employee, request_by_user, approval_employee, request_to_user, 'Cpl Earning Request Notification')
              if not email_template.nil?
                EmailOutbound.initiate_email_notification(email_template, request_to_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user)
              end
            end
            #############################################
            ########## Notification Generation ##########
            #############################################
          else
            #############################################
            ########## Notification Generation ##########
            #############################################
            request_by_user = requested_employee.user
            request_to_user = approval_employee.user
            if not request_by_user.nil?
              Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, 'You Availed Cpl Earning')
            end
            if not (request_by_user.nil? or request_to_user.nil?)
              email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => 'Cpl Earning Approved')
              if not email_template.nil?
                EmailOutbound.initiate_email_notification(email_template, request_to_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user)
              end
            end
            #############################################
            ########## Notification Generation ##########
            #############################################
          end
        else
          self.request_status = "Availed"
          self.save
          #############################################
          ########## Notification Generation ##########
          #############################################
          request_by_user = requested_employee.user
          request_to_user = approval_employee.user
          if not request_by_user.nil?
            Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, 'You Availed Cpl Earning')
          end
          if not request_by_user.nil?
            email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => 'Cpl Earning Approved')
            if not email_template.nil?
              EmailOutbound.initiate_email_notification(email_template, request_to_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user)
            end
          end
          #############################################
          ########## Notification Generation ##########
          #############################################
        end
      end
    elsif self.status == 'Cancelled'
      ########## Revert Approval Request ##########
      ApprovalRequest.revert_cpl_earning_request(self)
    end
  end

end
