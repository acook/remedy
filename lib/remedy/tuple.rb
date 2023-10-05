module Remedy
    # Formerly known as "Remedy::Size", with related concepts in my other projects
    #   called things like "Coordinate", "Pair", or similar
    # Used primarily to contain dimensional numeric values such as the sizes of screen areas,
    #   offsets in two or more dimensions, etc
  class Tuple
    def initialize *new_dimensions
      dims = new_dimensions.flatten
      if dims.first.is_a? self.class then
        dims = dims.first.dimensions.dup
      elsif dims.first.is_a? Range then
        dims.map! do |range|
          range.end
        end
      end
      @dimensions = dims
    end
    attr_accessor :dimensions

    class << self
      def zero
        self.new(0,0)
      end

      def tuplify *tupleable
        klass = self
        tupleable.flatten!
        if tupleable.first.is_a? klass then
          tupleable
        else
          klass.new tupleable
        end
      end
    end

    # OPERATIONS

    def + other_tuple
      if other_tuple.respond_to? :[] then
        matrix_addition other_tuple
      elsif other_tuple.respond_to? :+ then
        scalar_addition other_tuple
      end
    end

    def - other_tuple
      if other_tuple.respond_to? :length then
        matrix_subtract other_tuple
      else
        scalar_subtract other_tuple
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

    def fits_into? size_to_fit_into
      other_tuple = Tuple(size_to_fit_into)
      cardinality.times.each do |index|
        return false if self[index] > other_tuple[index]
      end
      true
    end

        # Determines if the two tuples have the same number of dimensions
    # uses `length` on the other object so it can be used in comparison with more types
    def bijective? other_tuple
      cardinality == other_tuple.length
    end
    alias_method :sizesame?, :bijective?

    # ACCESSORS

    def x
      dimensions[0]
    end
    alias_method :height, :x
    alias_method :row, :x
    alias_method :first, :x

    def y
      dimensions[1]
    end
    alias_method :width, :y
    alias_method :col, :y
    alias_method :second, :y

    def z
      dimensions[2]
    end
    alias_method :depth, :z
    alias_method :layer, :z
    alias_method :third, :z

    def last
      dimensions.last
    end

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

    def scalar_subtract! amount
      dimensions.map do |dimension|
        dimension - amount
      end
    end

    def scalar_subtract amount
      dup scalar_subtract! amount
    end

    def matrix_subtract other_tuple
      raise "Different numbers of dimensions!" unless bijective? other_tuple

      result = cardinality.times.inject self.class.new do |difference, index|
        difference << self[index] - other_tuple[index]
      end

      self.class.tuplify result
    end

    def scalar_addition! amount
      dimensions.map do |dimension|
        dimension + amount
      end
    end

    def scalar_addition amount
      dup.add! amount
    end

    def matrix_addition other_tuple
      raise "Different numbers of dimensions!" unless bijective? other_tuple

      result = cardinality.times.inject self.class.new do |sum, index|
        sum << self[index] + other_tuple[index]
      end

      self.class.tuplify result
    end
  end
end

def Tuple *tupleable
  ::Remedy::Tuple.tuplify tupleable
end
