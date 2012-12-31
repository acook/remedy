module Characters
  module_function

  def [] sequence_to_match
    all[sequence_to_match]
  end

  def all
    @all ||= printable.merge(nonprintable)
  end

  def printable
    @printable ||= whitespace.merge(
      alphabetical.merge(
        numeric.merge(
          punctuation)))
  end

  def whitespace
    {
      ' '  => :space,
      "\t" => :tab,
      "\r" => :carriage_return,
      "\n" => :line_feed
    }
  end

  def alphabetical
    @alphabetics ||= get_alphabetics
  end

  def numeric
    {
      '0' => :zero,
      '1' => :one,
      '2' => :two,
      '3' => :three,
      '4' => :four,
      '5' => :five,
      '6' => :six,
      '7' => :seven,
      '8' => :eight,
      '9' => :nine
    }
  end

  def punctuation
    {
      '.' => :period,
      ',' => :comma,
      ':' => :colon,
      ';' => :semicolon,

      '"' => :double_quote,
      "'" => :single_quote,
      '`' => :back_quote,

      '[' => :left_bracket,
      ']' => :right_bracked,
      '(' => :left_paren,
      ')' => :right_paren,

      '^' => :caret,
      '_' => :underscore,
      '-' => :dash,
      '~' => :tilde,

      '!' => :bang,
      '?' => :query,

      '|'       => :solid_pipe,
      "\u00A6"  => :broken_pipe,

      '/'  => :forward_slash,
      "\\" => :back_slash
    }
  end

  def nonprintable
    @nonprintable ||= special.merge(directional).merge(escape).merge(control)
  end

  def special
    {
      "\177"  => :backspace
    }
  end

  def directional
    {
      "\e[A" => :up,
      "\e[B" => :down,
      "\e[D" => :left,
      "\e[C" => :right
    }
  end

  def escape
    {
      "\e" => :escape,

      "\e[3~" => :delete
    }
  end

  def control
    {
      "\u0003" => :control_c,
      "\u0004" => :control_d,
      "\u0012" => :control_r
    }
  end

  def gremlins
    {
      space:           "\u2420",
      tab:             "\u21B9",
      carriage_return: "\u23CE",
      line_feed:       "\u240A",

      control_c: "\u2404",
      control_d: "\u2403",
      control_r: "\u2412",

      escape: "\u238B",

      backspace: "\u2408",
      delete:    "\u232B",

      up:    "\u2191",
      down:  "\u2193",
      left:  "\u2190",
      right: "\u2192"
    }
  end

  def alternate_names
    {
      control_c: :end_of_transmission,
      control_d: :end_of_text,

      control_r: :device_control_two
    }
  end

  def get_alphabetics
    letters = ('a'..'z').to_a + ('A'..'Z').to_a
    letters.inject(Hash.new) do |alphas, letter|
      alphas[letter] = letter.to_sym
      alphas
    end
  end
end

