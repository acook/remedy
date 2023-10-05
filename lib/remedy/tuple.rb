module Remedy
  class Tuple
    # Formerly known as "Remedy::Size", with related concepts in my other projects
    #   called things like "Coordinate", "Pair", or similar
    # Used primarily to contain dimensional numeric values such as the sizes of screen areas,
    #   offsets in two or more dimensions, etc
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

    # OPERATIONS

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

    # COMPARISON

    def bijective? other_tuple
      length == other_tuple.length
    end

    def fits_into? tuple_to_fit_into
      other_tuple = Tuple(tuple_to_fit_into)
      length.times.each do |index|
        return false if self[index] > other_tuple[index]
      end
      true
    end

    # ACCESSORS

    def x
      dimensions[0]
    end
    alias_method :height, :x

    def y
      dimensions[1]
    end
    alias_method :width, :y

    def z
      dimensions[2]
    end
    alias_method :depth, :z

    def [] index
      dimensions[index]
    end

    def cardinality
      dimensions.length
    end
    alias_method :length, :cardinality

    # CONVERSIONS

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
      raise "Different numbers of dimensions!" unless bijective? other_tuple

      length.times.inject Tuple.new do |difference, index|
        difference << self[index] - other_tuple[index]
      end
    end
  end
end

def Tuple *tupleable
  klass = ::Remedy::Tuple
  tupleable.flatten!
  if tupleable.first.is_a? klass then
    tupleable
  else
    klass.new tupleable
  end
end
