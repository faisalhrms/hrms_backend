json.piecerate do
  json.id           		@piecerate.try(:id)
  json.total_machines				@piecerate.try(:total_machines)
  if @piecerate.try(:floor_id).present?
    json.floor_id				@piecerate.try(:floor_id)
    json.floor_name				Piecerate.find(@piecerate.try(:floor_id)).name
  end
  if @piecerate.try(:line_id).present?
    json.line_id				@piecerate.try(:line_id)
    line = Piecerate.find(@piecerate.try(:line_id))
    json.line_name				line.name
    json.floor_name				Piecerate.find(line.floor_id).name
  end
  if @piecerate.try(:category_id).present?
    json.category_id				@piecerate.try(:category_id)
    json.category_name				Piecerate.find(@piecerate.try(:category_id)).name
  end
  json.piecerate_type_name		@piecerate.try(:piecerate_type_name)
  json.name							@piecerate.try(:name)
end