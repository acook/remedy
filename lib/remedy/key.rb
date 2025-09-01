require 'remedy/characters'

module Remedy
  class Key

    # @param character_sequence [String] a string representing a user keypress or terminal event
    def initialize character_sequence
      @character_sequence = character_sequence
    end

    # @return [String] the original raw sequence
    def seq
      @character_sequence
    end

    # (see seq)
    def raw
      seq
    end

    # @return [String] the original sequence in human-readable format
    def enc
      seq.dump[1..-2]
    end

    # @return [Symbol] if {Characters} has a name for it, the name of the input sequence
    # @return [Symbol] `:unknown` otherwise
    def name
      @name ||= Characters[seq] || :unknown
    end

    # @return [String] a single unicode glyph that represents the {Key}
    def glyph
      @glyph ||= get_glyph
    end

    # @return [Boolean] `true` if the input is a printable character, otherwise `false`
    def printable?
      @printable ||= !!Characters.printable[seq]
    end

    # @return [Boolean] `true` if the input is *not* a printable character, otherwise `false`
    def nonprintable?
      @nonprintable ||= !!Characters.nonprintable[seq]
    end

    # @return [Boolean] `true` if the input is a control character, otherwise `false`
    def control?
      @control ||= !!Characters.control[seq]
    end

    # @return [Boolean] `true` if the input is punctuation, otherwise `false`
    def punctuation?
      @control ||= !!Characters.punctuation[seq]
    end

    # @return [Boolean] `true` if the input is a gremlin (see also {Characters.gremlins}), otherwise `false`
    def gremlin?
      @gremlin ||= !!Characters.gremlins[name]
    end

    # @return [Boolean] `true` if the input is control-c, otherwise `false`
    def control_c?
      @control_c ||= seq == Characters.control.key(:control_c)
    end

    # @return [Boolean] `true` if the input has a name in the {Characters} list, otherwise `false`
    def recognized?
      @recognized ||= name != :unknown
    end

    # @return [Boolean] `true` if the input has a {Characters} entry, otherwise `false`
    def known?
      !!Characters[seq]
    end

    # @return [Boolean] `true` if the input is a single byte, otherwise `false`
    def single?
      @single ||= raw.length == 1
    end

    # @return [Boolean] `true` if the input is not a single byte, otherwise `false`
    def sequence?
      @sequence ||= raw.length > 1
    end

    # @return [String] representing the {Key} as a printable string
    def to_s
      @to_s ||= known? ? name.to_s : enc
    end

    # @example control-c's value
    #   3
    # @example tilde's value
    #   127
    #
    # @return [String] the input as a printable list of decimal numbers
    def value
      raw_value = raw.bytes.to_a.join(' ')
      single? ? raw_value : "(#{raw_value})"
    end

    # @return [String] the {Key}'s name, value, and glyph
    def inspect
      "<#{self.class} #{name.inspect} value:#{value} glyph:#{glyph}>"
    end

    # @return [Boolean] `true` if the {Key} has the name raw contents as the other {Key} or {String}, otherwise `false`
    def == key
      if key.respond_to? :raw then
        key.raw == raw
      else
        "#{raw}" == "#{key}"
      end
    end

    # @return [Boolean] `true` if the {Key} has the same raw contents as another {Key} ({String}s not permitted)
    def eql? key
      if key.is_a? self.class then
        self == key
      end
    end

    # Perform a fuzzy match on two objects
    def === object
      "#{object}" =~ /#{to_s}/i
    end

    # @return [Numeric] the hash code of the underlying sequence to improve performance in [Hash]es
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
