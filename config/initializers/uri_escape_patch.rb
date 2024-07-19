# config/initializers/uri_escape_patch.rb
require 'uri'
require 'cgi'

module URI
  def self.escape(url)
    CGI.escape(url)
  end
end
