class DataBaseBackup
	class << self
		def delete_db_bkp
			files = Dir.glob(File.join("/home/alche/daily_db_bkp", '**', '*')).select { |file| File.file?(file) }
			if files.count > 0
				files.each do |aFile|
					File.delete(aFile)
				end
			end
		end

		def make_db_bkp
			current_date = Time.now.strftime('%d-%m-%Y')
			if ENV['S3_BUCKET_FOLDER'] == "srl_dev"
				system("PGPASSWORD='#{ENV['DATABASE_PASSWORD']}' /home/alche/pgsql-9.6/pgsql-9.6/bin/pg_dump -U #{ENV['DATABASE_USER']} -h localhost -Fc #{ENV['DATABASE_NAME']} > /home/alche/daily_db_bkp/hrms_db_#{current_date}.sql")
			else
				system("PGPASSWORD='#{ENV['DATABASE_PASSWORD']}' /home/alche/pgsql-9.6/bin/pg_dump -U #{ENV['DATABASE_USER']} -h localhost -Fc #{ENV['DATABASE_NAME']} > /home/alche/daily_db_bkp/hrms_db_#{current_date}.sql")
			end
		end

		def make_files_bkp
			file_name = 's3_files.tar'
			system("rm /home/alche/#{file_name}")
			system("tar cvf /home/alche/#{file_name} -C /home/alche/apps/tak_back_end_production/shared/public/system .")
			file_name
		end

		def upload_db_bkp_to_s3
			current_date = Time.now.strftime('%d-%m-%Y')
			file_names = Array.new
			file_names << "hrms_db_#{current_date}.sql"

			client = DropboxApi::Client.new(ENV['DROPBOX_SECRET'])
			file_names.each_index do |index|
				File.open("/home/alche/daily_db_bkp/#{file_names[index]}") do |file|
					client.upload_by_chunks "/sapphire-hrms-dbbackup/#{ENV['S3_DATABASE_BUCKET_FOLDER']}/#{current_date}/#{file_names[index]}", file
				end
				puts "\n\n File Uploaded \n\n"
			end

			# Remove backup folder older than 30 days
			begin
				client.delete "/sapphire-hrms-dbbackup/#{ENV['S3_DATABASE_BUCKET_FOLDER']}/#{(Time.now - 30.days).strftime('%d-%m-%Y')}"
			rescue StandardError => error
				puts "==================="
				puts error
				puts "Path does not exist /sapphire-hrms-dbbackup/#{ENV['S3_DATABASE_BUCKET_FOLDER']}/#{(Time.now - 30.days).strftime('%d-%m-%Y')}"
				puts "==================="
			end
		end

		def upload_files_bkp(file_name)
			current_date = Time.now.strftime('%d-%m-%Y')
			client = DropboxApi::Client.new(ENV['DROPBOX_SECRET'])
			File.open("/home/alche/#{file_name}") do |file|
				client.upload_by_chunks "/hrms-files-backup/#{ENV['S3_DATABASE_BUCKET_FOLDER']}/#{current_date}/#{file_name}", file
			end

			begin
				client.delete "/hrms-files-backup/#{ENV['S3_DATABASE_BUCKET_FOLDER']}/#{(Date.today - 1.month).beginning_of_week.strftime('%d-%m-%Y')}"
			rescue StandardError => error
				puts "==================="
				puts error
				puts "Path does not exist /hrms-files-backup/#{ENV['S3_DATABASE_BUCKET_FOLDER']}/#{(Date.today - 1.month).beginning_of_week.strftime('%d-%m-%Y')}"
				puts "==================="
			end
		end

		def execute_code
			current_date = Time.now.strftime('%d-%m-%Y')
			start_time = Time.now
			DataBaseBackup.delete_db_bkp
			DataBaseBackup.make_db_bkp
			DataBaseBackup.upload_db_bkp_to_s3
			if Date.today == Date.today.beginning_of_week
				file_name = DataBaseBackup.make_files_bkp
				DataBaseBackup.upload_files_bkp(file_name)
			end

			end_time = Time.now
			max_retries = 10
			times_retried = 0
			body_text = "<h1> #{ENV['S3_DATABASE_BUCKET_FOLDER']} Database Auto Back-up </h1> <ul> <li>hrms_db_#{current_date}.sql</li> </ul>"

			begin
				UserMailer.send_database_backup_email(ENV['DB_BACKUP_EMAIL_TO'], "#{ENV['S3_DATABASE_BUCKET_FOLDER']} database Auto Back-up", body_text, start_time, end_time).deliver
			rescue Net::ReadTimeout => error
			  if times_retried < max_retries
			    times_retried += 1
			    puts "\n\nFailed to <do the thing>, retry #{times_retried}/#{max_retries}\n\n"
			    retry
			  else
			  	puts "\n\nExiting script. DataBase Backup Failed \n\n"
			    exit(1)
			  end
			end
		end
	end
end