json.sub_tasks @sub_task do |sub_task|
  json.id 									sub_task.id
  json.task_id       				sub_task.task_id
  json.kpi 						      sub_task.kpi
end