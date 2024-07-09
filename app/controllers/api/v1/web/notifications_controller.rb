class Api::V1::Web::NotificationsController < ApplicationController
	skip_before_action :authenticate_user_from_token!, only: :send_shopify_emails
	rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
	SHARED_SECRET = 'fd4b8c66d9a933b48ad59547009960e7dbd410599a969c42c38eea8cd72beb9b'

	def send_shopify_emails
		hmac_header = request.headers['HTTP_X_SHOPIFY_HMAC_SHA256']
		data = request.body.read
		if hmac_header.blank? || !webhook_verified?(data, hmac_header)
			render status: 200, json: {error: 'Secret not matched'}
		else
			email_config = EmailConfigration.first
			delivery_options = {}
			if ENV["EMAIL_ENV"] == 'production'
				delivery_options[:host] = 'http://hcm.sapphirepakistan.pk'
				delivery_options[:address] = email_config.outgoing_server_address
				delivery_options[:domain] = email_config.domain
				delivery_options[:port] = email_config.outgoing_server_port
				delivery_options[:user_name] =  'noreply@diamondenim.com'
				delivery_options[:password] = 'Diamond@123'
				delivery_options[:openssl_verify_mode] = 'none'
				delivery_options[:authentication] = 'login'
				delivery_options[:enable_starttls_auto] = true
			end
			item_names = params['line_items'].map{|item| item['name']}
			variant_title = params['line_items'].map{|item| item['variant_title']}
			item_quantity = params['line_items'].map{|item| item['quantity']}
			item_properties = params['line_items'].map{|item| item['properties'].map{|a| a.values.join(' x ')}}
			billing_address = [params['billing_address']['name'], params['billing_address']['address1'], "#{params['billing_address']['city']} #{params['billing_address']['zip']}" , params['billing_address']['country']]
			shipping_address = [params['shipping_address']['name'], params['shipping_address']['address1'], "#{params['shipping_address']['city']} #{params['shipping_address']['zip']}" , params['shipping_address']['country']]
			order_no = params['order_number']
			product_details = {note: params['note'].try(:strip), item_properties: item_properties, item_names: item_names, variant_title: variant_title, item_quantity: item_quantity, billing_address: billing_address, shipping_address: shipping_address, order_no: order_no}
			params["note_attributes"].map{|a| a['value']}.map{|a| a.split(',')}.flatten.each do |email|
				uMailer = UserMailer.send_shopify_email("Order ##{order_no} Confirmed DD Samples", email, 'noreply@diamondenim.com', product_details, delivery_options)
				uMailer.deliver_later
			end
			render status:200, json: {}
		end
	end

	def index
    user = User.find_by_email(params[:user_email])
    @noti = user.recieved_notifications.order('id DESC')
    render status:200, template: 'api/v1/web/notifications/index.json.jbuilder'
  end

  def get_lastest_notifications
  	user = User.find_by_email(params[:user_email])
  	@notis = user.recieved_notifications.where(:did_read => false).order('id DESC')
		render status:200, template: 'api/v1/web/notifications/get_unread_notification.json.jbuilder'
  end

  def mark_as_read
  	noti = NotificationRecipient.find params[:noti_id]
  	noti.did_read = true
  	noti.save
  	render status:200, json: {}
  end

	def webhook_verified?(data, hmac_header)
		calculated_hmac = Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', SHARED_SECRET, data))
		ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, hmac_header)
	end
end