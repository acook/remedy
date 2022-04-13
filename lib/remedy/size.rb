module Remedy
  class Size
    def initialize(*new_dimensions)
      new_dimensions.flatten!
      if new_dimensions.first.is_a? Range
        new_dimensions.map! do |range|
          range.to_a.length
        end
      end
      @dimensions = new_dimensions
    end
    attr_accessor :dimensions

    def -(other)
      if other.respond_to? :length
        self.class.new subtract(other)
      else
        self.class.new deduct(other)
      end
    end

    def /(other)
      dimensions.map do |dimension|
        dimension / other
      end
    end

    def <<(value)
      dimensions << value
    end

    def fits_into?(size_to_fit_into)
      other_size = Size(size_to_fit_into)
      length.times.each do |index|
        return false if self[index] > other_size[index]
      end
      true
    end

    def rows
      dimensions[0]
    end

    def cols
      dimensions[1]
    end
    alias columns cols

    def [](index)
      dimensions[index]
    end

    def length
      dimensions.length
    end

    def to_a
      dimensions.dup
    end

    def to_ary
      dimensions
    end

    def to_s
      "(#{dimensions.join('x')})"
    end

    def inspect
      "#<#{self.class}:#{self}>"
    end

    protected

    def deduct(amount)
      dimensions.map do |dimension|
        dimension - amount
      end
    end

    def subtract(other_size)
      sizesame? other_size

      length.times.inject Size.new do |difference, index|
        difference << (self[index] - other_size[index])
      end
    end

    def sizesame?(other_size)
      raise 'Different numbers of dimensions!' unless length == other_size.length
    end
  end
end

def Size(*sizeable)
  sizeable.flatten!
  if sizeable.first.is_a? Remedy::Size
    sizeable
  else
    Remedy::Size.new sizeable
  end
end
