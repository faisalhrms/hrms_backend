json.restrict_leave do
  json.id                 @restrict_leave.try(:id)
  json.leave_days         @restrict_leave.try(:leave_days)
  json.is_active          @restrict_leave.try(:is_active)
  json.approval_days      @restrict_leave.try(:approval_days)
  json.receiver_email     @restrict_leave.try(:receiver_email)
  json.notification       @restrict_leave.try(:notification)
  json.user_id            @restrict_leave.try(:user_id)
  json.company_id         @restrict_leave.try(:company_id)

  if @restrict_leave.user_ids.nil?
    json.user_ids 								[]
  else
    json.user_ids @restrict_leave.try(:user_ids).split(',').map(&:to_i)
  end

  # json.selected_users     @restrict_leave.user_id.parameterize.split('-')
  # users = User.where(id: @restrict_leave.user_id.parameterize.split('-'))
  # json.users users.map{|user| "#{user.id} | #{user.first_name} | #{user.email}" }
end

json.users @users.where(is_admin: true) do |users|
  json.id   			      users.try(:id)
  json.email 			      users.try(:email)
  json.combine_name    "#{users.id} | #{users.first_name} | #{users.email}"
end
