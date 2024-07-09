json.od_back_date do
  if @request_flow.back_date_apply == true
    json.min_apply_date 					(Time.now - @request_flow.back_date_limit.day).to_date
  else
    json.min_apply_date 					(Time.now - 60.day).to_date
  end
  end