json.payitem_expression do
  json.id										@payitem_expression.try(:id)
	json.expression_value			@payitem_expression.try(:expression_value)
	json.name									@payitem_expression.try(:name)
	json.description					@payitem_expression.try(:description)
	json.is_active						@payitem_expression.try(:is_active)
end