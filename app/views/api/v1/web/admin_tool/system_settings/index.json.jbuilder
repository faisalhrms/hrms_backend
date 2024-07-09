json.system_settings @system_settings do |system_setting|
  json.id										system_setting.try(:id)
  json.name 								system_setting.try(:name)
end