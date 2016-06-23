module Remedy
  module Characters
    module_function

    def [] sequence_to_match
      all[sequence_to_match]
    end

    # Character Groups

    def all
      @all ||= printable.merge(nonprintable)
    end

    def printable
      @printable ||= whitespace.merge(
        alphabetical.merge(
          numeric.merge(
            punctuation
          )
        )
      )
    end

    def alphabetical
      @alphabetics ||= get_alphabetics
    end

    def nonprintable
      @nonprintable ||= special.merge(directional).merge(escape).merge(control)
    end

    def whitespace
      {
        ?\s => :space,
        ?\t => :tab,
        ?\r => :carriage_return,
        ?\n => :line_feed
      }
    end

    def numeric
      {
        ?0 => :zero,
        ?1 => :one,
        ?2 => :two,
        ?3 => :three,
        ?4 => :four,
        ?5 => :five,
        ?6 => :six,
        ?7 => :seven,
        ?8 => :eight,
        ?9 => :nine
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

    def special
      {
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
      control_chars = {
        27.chr => :control_left_square_bracket,
        28.chr => :control_backslash,
        29.chr => :control_right_square_bracket,
        30.chr => :control_caret,
        31.chr => :control_underscore,
        127.chr => :delete,
        177.chr => :backspace
      }
      (?a..?z).each.with_index do |letter, index|
        control_chars.merge({index.chr => "control_#{letter}".to_sym})
      end

      control_chars
    end

    # Glyphs and Alternate Names

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
        control_a: :start_of_heading,
        control_b: :start_of_text,
        control_c: :end_of_transmission,
        control_d: :end_of_text,
        control_e: :enquiry,
        control_f: :acknowledge,
        control_g: :bel,
        control_h: :backspace,
        control_i: :horizontal_tabulation,
        control_j: :line_feed,
        control_k: :vertical_tabulation,
        control_l: :form_feed,
        control_m: :carriage_return,
        control_n: :shift_out,
        control_o: :shift_in,
        control_p: :data_link_escape,
        control_q: :device_control_one,
        control_r: :device_control_two,
        control_s: :device_control_three,
        control_t: :device_control_four,
        control_u: :negative_acknowledge,
        control_v: :sychnronous_idle,
        control_w: :end_of_transmission_block,
        control_x: :cancel,
        control_y: :end_of_medium,
        control_z: :substitute,

        control_left_square_bracket:  :escape,
        control_backslash:            :file_separator,
        control_right_square_bracket: :group_separator,
        control_caret:                :record_separator,
        control_underscore:           :unit_separator
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
end
