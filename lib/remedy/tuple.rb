module Remedy
  class Tuple
    def initialize *new_dimensions
      new_dimensions.flatten!
      if new_dimensions.first.is_a? Range then
        new_dimensions.map! do |range|
          range.to_a.length
        end
      end
      @dimensions = new_dimensions
    end
    attr_accessor :dimensions

    def self.zero
      self.new([0,0])
    end

    def - other_tuple
      if other_tuple.respond_to? :length then
        self.class.new subtract(other_tuple)
      else
        self.class.new deduct(other_tuple)
      end
    end

    def / value
      dimensions.map do |dimension|
        dimension / value
      end
    end

    def << value
      self.dimensions << value
    end


    def fits_into? tuple_to_fit_into
      other_tuple = Tuple(tuple_to_fit_into)
      length.times.each do |index|
        return false if self[index] > other_tuple[index]
      end
      true
    end

    def rows
      dimensions[0]
    end
    alias_method :height, :rows

    def cols
      dimensions[1]
    end
    alias_method :columns, :cols
    alias_method :width, :cols

    def [] index
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
      "#<#{self.class}:#{to_s}>"
    end

    protected

    def deduct amount
      dimensions.map do |dimension|
        dimension - amount
      end
    end

    def subtract other_tuple
      tuplesame? other_tuple

      length.times.inject Tuple.new do |difference, index|
        difference << self[index] - other_tuple[index]
      end
    end

    def tuplesame? other_tuple
      raise "Different numbers of dimensions!" unless length == other_tuple.length
    end
  end
end

def Tuple *tupleable
  tupleable.flatten!
  if tupleable.first.is_a? Remedy::Tuple then
    tupleable
  else
    Remedy::Tuple.new tupleable
  end
end
