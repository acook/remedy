module Remedy
  class View
    def initialize body, header = [], footer = []
      @header, @body, @footer = header, body, footer
    end
    attr_accessor :body, :header, :footer, :length

    def to_s force_recompile = false
      unless @view.nil? || force_recompile then
        @view
      else
        reset_length!
        @view = compile!
      end
    end

    protected

    def compile!
      compiled_view = String.new
      reset_length!

      merged.each do |line|
        compiled_view << row(line)
      end

      compiled_view
    end

    def merged
      @header.to_a + @body.to_a + @footer.to_a
    end

    def row line
      @length += 1
      "#{line}#{ANSI.cursor.next_line}"
    end

    def reset_length!
      @length = 0
    end
  end
end
