require 'remedy/characters'

module Remedy
  class Key

    def initialize character_sequence
      @character_sequence = character_sequence
    end

    def seq
      @character_sequence
    end

    def raw
      seq
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

    def single?
      @single ||= raw.length == 1
    end

    def sequence?
      @sequence ||= raw.legnth > 1
    end

    def to_s
      @to_s ||= name.to_s
    end

    def value
      raw_value = raw.bytes.to_a.join(' ')
      single? ? raw_value : "(#{raw_value})"
    end

    def inspect
      "<#{self.class} #{name.inspect} value:#{value} glyph:#{glyph}>"
    end

    def == key
      if key.respond_to? :raw then
        key.raw == raw
      else
        "#{raw}" == "#{key}"
      end
    end

    def eql? key
      if key.is_a? self.class then
        self == key
      end
    end

    def === object
      "#{object}" =~ /#{to_s}/i
    end

    def hash
      raw.hash
    end

    protected

    def get_glyph
      if punctuation? then
        seq
      elsif gremlin? then
        Characters.gremlins[name]
      else
        recognized? ? name : ''
      end
    end
  end

  def Key object
    if object.is_a? Key then
      object
    else
      Key.new object
    end
  end
end
