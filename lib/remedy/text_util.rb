module Remedy
  module TextUtil
    module_function

    def nlclean content, context = nil
      case content
      when String
        nlsplit(content)
      when Array
        content.map do |l|
          nlclean l
        end
      else
        content.to_a
      end
    end

    def nlsplit line
      raise ArgumentError, "Requires a String, got #{line.class} instead!" unless line.is_a? String
      line.split(/\r\n|\n\r|\n|\r/)
    end

  end
end
