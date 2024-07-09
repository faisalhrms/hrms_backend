class UserMailer < ApplicationMailer

  default from: "hrms@sapphiretextiles.com.pk"

  def send_shopify_email(subject, email, from, product_details, delivery_options = {})
    @product_details = product_details
    mail = mail(to: email, from: from, subject: subject)
    mail.delivery_method.settings.merge!(delivery_options) if delivery_options.present?
  end

  def reset_password(user,link, from, delivery_options = {})
    @user = user
    @link = link
    mail = mail(to: @user.email, from: from, subject: 'Password Reset')
    mail.delivery_method.settings.merge!(delivery_options) if delivery_options.present?
  end

  def send_forget_password (user,custom_password, from, delivery_options = {})
    @user = user
    @custom_password = custom_password
    mail = mail(to: user.email, from: from, subject: 'Password Reset')
    mail.delivery_method.settings.merge!(delivery_options) if delivery_options.present?
  end

  def create_custom_notification(user_email, cc_email, bcc_email, mail_subject, mail_text)

    puts "To Email:     => #{user_email}"
    puts "CC Email:     => #{cc_email}"
    puts "BCC Email:    => #{bcc_email}"
    puts "Mail Subject: => #{mail_subject}"
    puts "Mail Text:    => #{mail_text}"

    @mail_text = mail_text
    mail to: user_email, subject: mail_subject, :cc => cc_email, :bcc => bcc_email
  end

  def create_leave_request_notification(user_email, cc_email, bcc_email, mail_subject, approval_request)

    puts "To Email:     => #{user_email}"
    puts "CC Email:     => #{cc_email}"
    puts "BCC Email:    => #{bcc_email}"
    puts "Mail Subject: => #{mail_subject}"

    @approval_request = approval_request
    mail to: user_email, subject: mail_subject, :cc => cc_email, :bcc => bcc_email
  end

  def create_leave_request_reject_notification(user_email, cc_email, bcc_email, mail_subject, approval_request)

    puts "To Email:     => #{user_email}"
    puts "CC Email:     => #{cc_email}"
    puts "BCC Email:    => #{bcc_email}"
    puts "Mail Subject: => #{mail_subject}"

    @approval_request = approval_request
    mail to: user_email, subject: mail_subject, :cc => cc_email, :bcc => bcc_email
  end

  def send_email_notification from_email, to_email, subject, template, cc_address, delivery_options = {}
    @from_email = "hrms@sapphiretextiles.com.pk"
    @cc_address = cc_address
    @to_email = to_email
    @subject = subject
    @template = template
    mail to: to_email, subject: subject, :cc => cc_address, from: "hrms@sapphiretextiles.com.pk"
    mail.delivery_method.settings.merge!(delivery_options) if delivery_options.present?
  end

  def send_email_attch_notification from_email, subject, template, path, attachment_name
    @from_email = from_email
    @to_email = ENV['STATUS_REPORT_RECEIVER']
    @subject = subject
    @template = template
    attachments["#{attachment_name.split('.')[0]}.xlsx"] = File.read("#{Rails.public_path}/excel/#{path}",mode: "rb")
    mail to: @to_email, subject: subject
  end

  def send_database_backup_email(user_email, mail_subject, body_text, start_time, end_time)
    puts "User Email: => #{user_email}"
    puts "User Subject: =>  #{mail_subject}"
    puts "User Body: => #{body_text}"

    @body_text = body_text
    @start_time = start_time
    @end_time = end_time

    mail to: user_email, subject: mail_subject
  end

  def send_report_xlsx(user_email, mail_subject, body_text, path, attachment_name, start_time, end_time, cc_email, bcc_email)

    puts "User Email: => #{user_email}"
    puts "CC Email: => #{cc_email}"
    puts "User Subject: =>  #{mail_subject}"
    puts "User Body: => #{body_text}"
    puts "User PDF: => #{path}"

    @body_text = body_text
    @start_time = start_time
    @end_time = end_time

    attachments["#{attachment_name.split('.')[0]}.xlsx"] = File.read("#{Rails.public_path}/excel/#{path}",mode: "rb")

    mail to: user_email, subject: mail_subject, :cc => cc_email, :bcc => bcc_email

  end

  def send_report_xlsx2(user_email, mail_subject, body_text, path, attachment_name, start_time, end_time, cc_email, bcc_email)

    puts "User Email: => #{user_email}"
    puts "CC Email: => #{cc_email}"
    puts "User Subject: =>  #{mail_subject}"
    puts "User Body: => #{body_text}"
    puts "User PDF: => #{path}"

    @body_text = body_text
    @start_time = start_time
    @end_time = end_time

    attachments["#{attachment_name}.xlsx"] = File.read("#{Rails.public_path}/excel/#{attachment_name}.xlsx",mode: "rb")

    mail to: user_email, subject: mail_subject, :cc => cc_email, :bcc => bcc_email

  end


end
