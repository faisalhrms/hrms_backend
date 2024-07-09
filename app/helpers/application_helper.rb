module ApplicationHelper

	def check_directory(dir_path)
		unless File.directory?(dir_path)
			Dir.mkdir(dir_path)
		end
	end

	def mill_instance?
		ENV.fetch("APP_URL").include?('millshrmsbe.dfl.com.pk')
	end

	def ild_instance?
		ENV.fetch("APP_URL").include?('idlhrmsbe.technology-partner.pk')
	end

	def srl_instance?
		ENV['APP_URL'].include?('hrmsbe.sapphirepakistan.pk')
	end

	def grade_params
		params[:grade_id].class == Array ? params[:grade_id].map(&:to_i) : params[:grade_id]
	end

	def grade_name(grade_params)
		grades = []
		grade_name = Grade.where(id: grade_params).pluck(:name)
		grades << 'Worker' if grade_name.include? 'W'
		grades << 'Staff' if grade_name.include? 'S'
		grades << 'Management' if grade_name.include? 'M'
		grades.join(',')
	end
end
