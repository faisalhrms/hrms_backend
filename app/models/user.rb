class User < ApplicationRecord

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  ########## Validation ############
  validates :email, :uniqueness => true

  ####### Relation Ship #########
  has_many :recieved_notifications, as: :recievable, class_name: 'NotificationRecipient', dependent: :destroy
  has_one     :employee
  
  belongs_to  :role
  belongs_to  :company

  def self.current
    Thread.current[:current_user]
  end

  def self.current=(usr)
    Thread.current[:current_user] = usr
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def send_password_reset(link)
    generate_token(:reset_password_token)
    self.reset_password_sent_at = Time.zone.now
    save!
    email_configration = EmailConfigration.where(:company_id => self.company_id).first
    delivery_options = {}
    if email_configration and ENV['EMAIL_ENV'] == 'production'
      delivery_options[:host] = 'http://hcm.sapphirepakistan.pk'
      delivery_options[:address] = email_configration.outgoing_server_address
      delivery_options[:domain] = email_configration.domain
      delivery_options[:port] = email_configration.outgoing_server_port
      delivery_options[:user_name] = email_configration.user_name
      delivery_options[:password] = email_configration.password
      delivery_options[:openssl_verify_mode] = 'none'
      delivery_options[:authentication] = 'login'
      delivery_options[:enable_starttls_auto] = true
    end
    uMailer = UserMailer.reset_password(self,link, email_configration.email, delivery_options)
    uMailer.deliver_later
  end

  def send_forget_password
    custom_password = SecureRandom.hex(6)
    self.reset_password_token = SecureRandom.urlsafe_base64
    self.reset_password_sent_at = Time.zone.now
    self.save!
    delivery_options = {}
    email_configration = EmailConfigration.where(:company_id => self.company_id).first
    if email_configration and ENV['EMAIL_ENV'] == 'production'
      delivery_options[:host] = 'http://hcm.sapphirepakistan.pk'
      delivery_options[:address] = email_configration.outgoing_server_address
      delivery_options[:domain] = email_configration.domain
      delivery_options[:port] = email_configration.outgoing_server_port
      delivery_options[:user_name] = email_configration.user_name
      delivery_options[:password] = email_configration.password
      delivery_options[:openssl_verify_mode] = 'none'
      delivery_options[:authentication] = 'login'
      delivery_options[:enable_starttls_auto] = true
    end
    uMailer = UserMailer.send_forget_password(self, custom_password, delivery_options)
    uMailer.deliver_later
  end

  def self.show_salary(current_user)
    if current_user.nil?
      return false
    else
      if current_user.role.nil?
        return false
      else
        user_permission = current_user.role.role_permissions.find_by(:module_name => "show_salary")
        if user_permission.nil?
          return false
        else
          return user_permission.index_access
        end
      end
    end
  end
  
end
