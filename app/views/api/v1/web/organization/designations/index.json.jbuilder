json.designations @designations do |designation|
  json.id   designation.try(:id)
  json.name designation.try(:name)
  json.code designation.try(:code)
  json.is_active designation.try(:is_active)
end