json.request_flows @request_flows do |request_flow|
  json.id										request_flow.try(:id)
  json.name 								request_flow.try(:name)
  json.request_flow_type 		request_flow.try(:request_flow_type)
end