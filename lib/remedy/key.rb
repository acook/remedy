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

    def enc
      seq.dump[1..-2]
    end

    def name
      Characters[seq] || :unknown
    end

    def glyph
      get_glyph
    end

    def printable?
      !!Characters.printable[seq]
    end

    def nonprintable?
      !!Characters.nonprintable[seq]
    end

    def control?
      !!Characters.control[seq]
    end

    def punctuation?
      !!Characters.punctuation[seq]
    end

    def gremlin?
      !!Characters.gremlins[name]
    end

    def control_c?
      seq == Characters.control.key(:control_c)
    end

    def known?
      !!Characters[seq]
    end

    def unknown?
      !Characters[seq]
    end

    def single?
      raw.length == 1
    end

    def sequence?
      raw.length > 1
    end

    def to_s
      known? ? name.to_s : enc
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

    def get_glyph default = "\u25A1"
      if punctuation? then
        seq
      elsif gremlin? then
        Characters.gremlins[name]
      else
        known? ? name : default
      end
    end
  end

  # use this to wrap keypresses that you get from outside of Remedy
  def Key object
    if object.is_a? Key then
      object
    else
      Key.new object
    end
  end
end
