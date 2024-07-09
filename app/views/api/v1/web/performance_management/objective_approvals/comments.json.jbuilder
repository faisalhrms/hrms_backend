json.comments @comments do |comment|
  json.id comment.id
  json.body comment.body
  json.user_avatar comment.user.try(:employee).try(:avatar).try(:url)
  json.avatar_present comment.user.try(:employee).try(:avatar).try(:url).present?
  json.user_name comment.user.full_name
  json.created_at comment.created_at.strftime('%d %b %Y')
end
json.status @objective_setting.status
json.appraisal_status @objective_setting.appraisal_status
json.can_update @objective_setting.try(:status) != 'Approved'
json.can_update_appraisal @objective_setting.try(:appraisal_status) != 'Approved'