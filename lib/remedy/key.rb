require 'remedy/characters'

module Remedy
  class Key
    def initialize(character_sequence)
      @character_sequence = character_sequence
    end

    def seq
      @character_sequence
    end

    def raw
      seq
    end

    def enc
      seq.dump[1..-2]
    end

    def name
      @name ||= Characters[seq] || :unknown
    end

    def glyph
      @glyph ||= get_glyph
    end

    def printable?
      @printable ||= !!Characters.printable[seq]
    end

    def nonprintable?
      @nonprintable ||= !!Characters.nonprintable[seq]
    end

    def control?
      @control ||= !!Characters.control[seq]
    end

    def punctuation?
      @control ||= !!Characters.punctuation[seq]
    end

    def gremlin?
      @gremlin ||= !!Characters.gremlins[name]
    end

    def control_c?
      @control_c ||= seq == Characters.control.key(:control_c)
    end

    def recognized?
      @recognized ||= name != :unknown
    end

    def known?
      !!Characters[seq]
    end

    def single?
      @single ||= raw.length == 1
    end

    def sequence?
      @sequence ||= raw.length > 1
    end

    def to_s
      @to_s ||= known? ? name.to_s : enc
    end

    def value
      raw_value = raw.bytes.to_a.join(' ')
      single? ? raw_value : "(#{raw_value})"
    end

    def inspect
      "<#{self.class} #{name.inspect} value:#{value} glyph:#{glyph}>"
    end

    def ==(other)
      if other.respond_to? :raw
        other.raw == raw
      else
        raw.to_s == other.to_s
      end
    end

    def eql?(other)
      self == other if other.is_a? self.class
    end

    def ===(object)
      object.to_s =~ /#{self}/i
    end

    def hash
      raw.hash
    end

    protected

    def get_glyph
      if punctuation?
        seq
      elsif gremlin?
        Characters.gremlins[name]
      else
        recognized? ? name : ''
      end
    end
  end

  def Key(object)
    if object.is_a? Key
      object
    else
      Key.new object
    end
  end
end
