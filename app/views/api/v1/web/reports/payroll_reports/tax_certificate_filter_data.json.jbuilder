if @tax_certificate.present?
  json.sr_number 						@tax_certificate.last.sr_number
  json.date_of_issue 				ReportFormat.date_format(@tax_certificate.last.date_of_issue)
end
