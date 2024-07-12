# lib/capistrano/substitute_strings.rb
module Capistrano
  module SubstituteStrings
    # We often want to refer to variables which
    # are defined in subsequent stage files. This
    # lets us use the {{var}} to represent fetch(:var)
    # in strings which are only evaluated at runtime.

    def self.sub_strings(input_string)
      puts "Creating a String for Symlink: #{input_string}"
      puts "============================="

      output_string = input_string

      # Find all the {{var}} patterns in the input string
      input_string.scan(/{{(\w*)}}/).each do |var|
        var_name = var[0].to_sym

        # Fetch the value of the variable and replace in the output string
        begin
          value = fetch(var_name)
          output_string.gsub!("{{#{var[0]}}}", value)
        rescue KeyError
          puts "Warning: Could not fetch the value for :#{var_name}"
        end
      end

      puts "============================="
      puts "Result Generated: #{output_string}"
      output_string
    end
  end
end
