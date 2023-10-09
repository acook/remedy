module Remedy
  module TextUtil
    module_function

    def nlclean content, context = nil
      case content
      when String
        nlsplit(content)
      when Frame
        content.to_a
      when Partial
        content.to_a
      when View
        content.to_a
      when Array
        content.map do |l|
          nlclean l
        end
      else
        binding.pry
      end
    end

    def nlsplit line
      raise ArgumentError, "Requires a String, got #{line.class} instead!" unless line.is_a? String
      line.split(/\r\n|\n\r|\n|\r/)
    end

  end
end
