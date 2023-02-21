module Remedy
  # Namespace for tables of information about characters and byte sequences
  #
  # Primarily contains maps between characters and their:
  #
  #  - simple names as understood from a terminal as easily matchable symbols<br><br>
  #    examples: `1` => `:one` and `0x02` => `:control_b`
  #  - associated gremlins, characters which represent nonprintable ones<br><br>
  #    examples: `\e` => `⎋`
  #  - explanatory phrases for terminal and control characters<br><br>
  #    examples: `0x02` => `"start of text"`
  module Characters
    module_function

    # ASCII alphabetical characters
    ALPHABETIC = [*?A..?Z, *?a..?z].each_with_object({}) { |c,h| h[c] = c.to_sym }
    # ASCII numeric characters
    NUMERIC = {
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
    # ASCII whitespace characters
    WHITESPACE = {
      ?\s => :space,
      ?\t => :tab,
      ?\r => :carriage_return,
      ?\n => :line_feed
    }
    # ASCII punctuation characters
    # as well as legacy terminal characters
    PUNCTUATION = {
      '.' => :period,
      ',' => :comma,
      ':' => :colon,
      ';' => :semicolon,

      '"' => :double_quote,
      "'" => :single_quote,
      '`' => :back_quote,

      '[' => :left_bracket,
      ']' => :right_bracket,
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
    # ASCII printable characters (alphanumeric, punctuation, and whitespace characters)
    PRINTABLE = WHITESPACE.merge(ALPHABETIC.merge(NUMERIC.merge(PUNCTUATION)))

    # Special characters
    SPECIAL = {}
    # Fundamental escape sequences
    ESCAPE = {
      "\e" => :escape,

      "\e[3~" => :delete
    }
    # Sequences which indicate directional movement
    DIRECTION = {
      "\e[A" => :up,
      "\e[B" => :down,
      "\e[D" => :left,
      "\e[C" => :right
    }
    # Bytes which indicate that control was held
    # And other single-byte control characters
    CONTROL = (?a..?z).each_with_object(Hash.new).with_index { |(c,h),i|
      h[(i+1).chr] = "control_#{c}".to_sym
    }.merge({
      27.chr => :control_left_square_bracket,
      28.chr => :control_backslash,
      29.chr => :control_right_square_bracket,
      30.chr => :control_caret,
      31.chr => :control_underscore,
      127.chr => :delete,
      177.chr => :backspace
    })

    # Nonprintable characters (special, directional, escape, and control characters)
    NONPRINTABLE = SPECIAL.merge(DIRECTION).merge(ESCAPE).merge(CONTROL)

    # All known characters
    ALL = PRINTABLE.merge(NONPRINTABLE)

    # Lookup a sequence and return the matching symbolic name
    #
    # @param [String] sequence_to_match the character or control sequence to find
    # @return [Symbol] the associated symbol
    # @return [nil] if character or sequence is not in the tables
    def [] sequence_to_match
      all[sequence_to_match]
    end

    # Convenience methods for symbolic names:

    # (see ALL)
    def all; ALL; end
    # (see PRINTABLE)
    def printable; PRINTABLE; end
    # (see NONPRINTABLE)
    def nonprintable; NONPRINTABLE; end

    # (see ALPHABETIC)
    def alphabetical; ALPHABETIC; end
    # (see WHITESPACE)
    def whitespace; WHITESPACE; end
    # (see NUMERIC)
    def numeric; NUMERIC; end
    # (see PUNCTUATION)
    def punctuation; PUNCTUATION; end

    # (see SPECIAL)
    def special; SPECIAL; end
    # (see DIRECTION)
    def directional; DIRECTION; end
    # (see ESCAPE)
    def escape; ESCAPE; end
    # (see CONTROL)
    def control; CONTROL; end

    # Glyphs and Alternate Names:

    # Gremlins are the visible counterparts of nonprintable characters
    #
    # examples:
    #  - `␠` for ` ` (AKA `space`)
    #  - `␄` for `0x04` (AKA `control_d` AKA `EOT`)
    #
    # Keep in mind these may be *wide* characters!
    # This means they may take up more horizontal space than ASCII characters in a monospace font.
    # This may be 1.5 or 2 characters for example, which would potentially make them overlap with subsequent non-whitespace characters.
    #
    # Character width is always something to pay attention to when dealing with UTF-8 and not exclusive to gremlins.
    GREMLINS = {

           null: "\u2400",
      control_a: "\u2401",
      control_b: "\u2402",
      control_c: "\u2403",
      control_d: "\u2404",
      control_e: "\u2405",
      control_f: "\u2406",
      control_g: "\u2407",
      control_h: "\u2408", # backspace
      control_i: "\u2409", # horizontal tab \t
      control_j: "\u240A", # line feed \n
      control_k: "\u240B", # vertical tab
      control_l: "\u240C", # form feed
      control_m: "\u240D", # carriage return \r
      control_n: "\u240E", # shift out
      control_o: "\u240F", # shift in
      control_p: "\u2410", # data link escape
      control_q: "\u2411", # device control 1
      control_r: "\u2412", # device control 2
      control_s: "\u2413", # device control 3
      control_t: "\u2414", # device control 4
      control_u: "\u2415", # negative acknowledge
      control_v: "\u2416", # synchronous idle
      control_w: "\u2417", # end of transmissions block
      control_x: "\u2418", # cancel
      control_y: "\u2419", # end of medium
      control_z: "\u241A", # substitute

      control_left_square_bracket:  "\u241B", # escape
      control_backslash:            "\u241C", # file separator
      control_right_square_bracket: "\u241D", # group separator
      control_caret:                "\u241E", # record separator
      control_underscore:           "\u241F", # unit separator

      space:           "\u2420", # "symbol for space"
      delete:          "\u2421", # "symbol for delete"

      # keyboard key symbols
      command:         "\u2318", # "place of interest sign"
      option:          "\u2325", # "option key"
      keyboard:        "\u2328", # "keyboard"
      backspace:       "\u232B", # "erase to left"
      symdelete:       "\u2326", # "erase to right"
      alt:             "\u2387", # "alternative key symbol"
      escape:          "\u238B", # "broken circle with northwest arrow"
      enter:           "\u23CE", # "return symbol"
      power:           "\u23FB", # "power symbol"

      tab:             "\u2B7E", # tab symbol
      vtab:            "\u2B7F", # vertical tab symbol

      # extra
      prev_page:    "\u2397",
      next_page:    "\u2398",
      print_screen: "\u2399",
      clear_screen: "\u239A",

      # directional
      left:  "\u2190", # "leftwards arrow"
      up:    "\u2191", # "upwards arrow"
      right: "\u2192", # "rightwards arrow"
      down:  "\u2193", # "downwards arrow"
    }
    # Descriptive names of control characters and sequences
    ALTERNATE_NAMES = {
           null: :null, # generated by control_space, control_@, and control_`
      control_a: :start_of_heading,
      control_b: :start_of_text,
      control_c: :end_of_text,
      control_d: :end_of_transmission,
      control_e: :enquiry,
      control_f: :acknowledge,
      control_g: :bell,
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
    # Abbreviations for control characters as used traditionally.
    #
    # Sometimes still used for serial terminals.
    #
    # Defined by ASCII, also known as the C0 control code set.
    ABBREVIATIONS = {
           null: :NUL, # 0
      control_a: :SOH,
      control_b: :STX,
      control_c: :ETX,
      control_d: :EOT,
      control_e: :ENQ,
      control_f: :ACK,
      control_g: :BEL,
      control_h: :BS,
      control_i: :HT,
      control_j: :LF,
      control_k: :VT,
      control_l: :FF,
      control_m: :CR,
      control_n: :SO,
      control_o: :SI,
      control_p: :DLE,
      control_q: :DC1,
      control_r: :DC2,
      control_s: :DC3,
      control_t: :DC4,
      control_u: :NAK,
      control_v: :SYN,
      control_w: :ETB,
      control_x: :CAN,
      control_y: :EM,
      control_z: :SUB, # 26, also traditionally EOF on Windows/DOS systems

      # non-alphabetic codes
      control_left_square_bracket:  :ESC, # 27
      control_backslash:            :FS,
      control_right_square_bracket: :GS,
      control_caret:                :RS,
      control_underscore:           :US, # 31

      # not technically part of the spec, but uses these names
      space:                        :SP, # 32
      control_question_mark:        :DEL
    }

    # Convenience methods for gremlins and alternate names:

    # (see GREMLINS)
    def gremlins; GREMLINS; end
    # (see ALTERNATE_NAMES)
    def alternate_names; ALTERNATE_NAMES; end

  end
end
