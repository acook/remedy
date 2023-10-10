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

    def == other_tuple
      return false unless other_tuple.respond_to? :length
      return false unless bijective? other_tuple

      self.dimensions.each.with_index do |d, i|
        return false unless d == other_tuple[i]
      end

      true
    end

    # Three-way comparison operator AKA the "spaceship operator".
    #
    # Used for sorting.
    # @return [-1,0,1] `-1` if `self > other_tuple`, `1` if `self < other_tuple`, `0` otherwise
    def <=> other_tuple
      self.aold(other_tuple).magnitude <=> self.aogd(other_tuple).magnitude
    end

    # Determines if this Tuple is smaller than the other Tuple in all dimensions.
    # @param other_tuple [Remedy::Tuple]
    # @return [Boolean] `true` if this Tuple is the same size or smaller, `false` otherwise.
    def fits_into? other_tuple
      return false if self.cardinality > other_tuple.cardinality
      cardinality.times.each do |index|
        return false if self[index] > other_tuple[index]
      end
      true
    end

    # Determines if the two tuples have the same number of dimensions
    #   uses `length` on the other object so it can be used in comparison with more types than just Tuples.
    # @param other_tuple [Remedy::Tuple]
    # @return [Boolean]
    def bijective? other_tuple
      cardinality == other_tuple.length
    end
    alias_method :sizesame?, :bijective?

    # Returns a Tuple where the dimensions are the absolute values of the current Tuple.
    # @return [Remedy::Tuple]
    def abs
      self.class.new dimensions.map(&:abs)
    end

    # Returns the total magnitude of all dimensions.
    # @return [Numeric]
    def magnitude
      dimensions.map(&:abs).sum
    end

    # The area of difference.
    #
    # Indicates the magnitude of the difference between two Tuples.
    #
    # @param other_tuple [Remedy::Tuple]
    # @return [Remedy::Tuple]
    def aod other_tuple
      result = [cardinality, other_tuple.cardinality].max.times.with_object(self.class.new) do |index, area|
        if self[index].nil? then
          area << other_tuple[index].abs
        elsif other_tuple[index].nil? then
          area << self[index].abs
        else
          difference = other_tuple[index] - self[index]

          area << difference.abs
        end
      end

      self.class.tuplify result
    end

    # The area of lesser difference.
    #
    # Indicates where the `other` Tuple is lesser and by how much.
    #
    # @param other_tuple [Remedy::Tuple]
    # @return [Remedy::Tuple]
    def aold other_tuple
      result = [cardinality, other_tuple.cardinality].max.times.with_object(self.class.new) do |index, area|
        if self[index].nil? then
          area << 0
        elsif other_tuple[index].nil? then
          area << self[index]
        else
          difference = self[index] - other_tuple[index]

          if difference < 0 then
            area << 0
          else
            area << difference
          end
        end
      end

      self.class.tuplify result
    end

    # The area of greater difference.
    #
    # Indicates where the `other` Tuple is greater and by how much.
    #
    # @param other_tuple [Remedy::Tuple]
    # @return [Remedy::Tuple]
    def aogd other_tuple
      result = [cardinality, other_tuple.cardinality].max.times.with_object(self.class.new) do |index, area|
        if self[index].nil? then
          area << other_tuple[index]
        elsif other_tuple[index].nil? then
          area << 0
        else
          difference = other_tuple[index] - self[index]

          if difference < 0 then
            area << 0
          else
            area << difference
          end
        end
      end

      self.class.tuplify result
    end

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

    def x= new_value
      dimensions[0] = new_value
    end
    alias_method :height=, :x=
    alias_method :row=, :x=
    alias_method :first=, :x=

    def y= new_value
      dimensions[1] = new_value
    end
    alias_method :width=, :y=
    alias_method :col=, :y=
    alias_method :second=, :y=

    def z= new_value
      dimensions[2] = new_value
    end
    alias_method :depth=, :z=
    alias_method :layer=, :z=
    alias_method :third=, :z=

    def last
      dimensions.last
    end

    def [] index
      dimensions[index]
    end

    def []= index, value
      dimensions[index] = value
    end

    # @return [Integer] The number of dimensions in this Tuple.
    def cardinality
      dimensions.length
    end
    alias_method :length, :cardinality

    # @return [Boolean] `true` if all dimensions are zero, otherwise `false`.
    def zero?
      dimensions.all? do |d|
        d == 0
      end
    end

    # @return [Boolean] `true` if any dimension is nonzero, otherwise `false`.
    def nonzero?
      dimensions.any? do |d|
        d != 0
      end
    end

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

    def dup
      new_tuple = super
      new_tuple.dimensions = dimensions.dup
      new_tuple
    end

    protected

    def scalar_subtract! amount
      dimensions.map do |dimension|
        dimension - amount
      end
    end

    def scalar_subtract amount
      dup.scalar_subtract! amount
    end

    def matrix_subtract other_tuple
      raise "Different numbers of dimensions! (#{cardinality} vs #{other_tuple.cardinality})" unless bijective? other_tuple

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
      raise "Different numbers of dimensions! (#{cardinality} vs #{other_tuple.cardinality})" unless bijective? other_tuple

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
