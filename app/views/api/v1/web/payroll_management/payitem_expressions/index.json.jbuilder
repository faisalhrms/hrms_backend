json.payitem_expressions @payitem_expressions do |payitem_expression|
  json.id									payitem_expression.try(:id)
  json.name 							payitem_expression.try(:name)
  json.expression_value		payitem_expression.try(:expression_value)
  json.is_active 					payitem_expression.try(:is_active)
end