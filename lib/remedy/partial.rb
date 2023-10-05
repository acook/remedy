module Remedy
  class Partial
    def initialize collection = Array.new
      @lines = Array.new
      self + collection
    end
    attr_accessor :lines

    def + new_lines
      new_lines.each do |line|
        self << line
      end
    end

    def << line
      reset_width!
      line = "#{line}" # opportunistically convert any object into a string
      @lines += clean line unless line.nil? || line.empty?
      self
    end

    def first
      lines.first
    end

    def last
      lines.last
    end

    def height
      lines.length
    end
    alias_method :length, :height

    def width
      lines.map{|line| line.length }.max
    end

    def size
      Size.new height, width
    end

    def to_a
      lines
    end

    def to_s
      lines.join '\n'
    end

    def join seperator
      lines.join seperator
    end

    def excerpt lines_range, width_range
      self.class.new lines[lines_range].map { |line| line[width_range] }
    end

    protected

    def reset_width!
      @width = nil
    end

    def clean line
      Array split(line)
    end

    def split line
      line.split(/\r\n|\n\r|\n|\r/)
    end
  end
end
