require "uri"

# Backward compatibility for gems or legacy code still calling URI.escape/URI.unescape.
module URI
  class << self
    unless respond_to?(:escape)
      def escape(value, unsafe = nil)
        return if value.nil?

        unsafe ? DEFAULT_PARSER.escape(value.to_s, unsafe) : DEFAULT_PARSER.escape(value.to_s)
      end
    end

    unless respond_to?(:unescape)
      def unescape(value)
        return if value.nil?

        DEFAULT_PARSER.unescape(value.to_s)
      end
    end
  end
end
