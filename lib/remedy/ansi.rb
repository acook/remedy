require 'remedy/console'

module Remedy
  module ANSI
    module_function

    def push *sequences
      Console.output << sequences.join('')
    end

    def pushesc *sequences
      push sequences.map{|sequence| esc sequence }
    end

    def pushe *sequences
      push sequences.map{|sequence| e sequence }
    end

    def esc sequence = nil
      "\e[#{sequence}"
    end

    def e sequence = nil
      "\e#{sequence}"
    end

    def cursor
      Cursor
    end

    def screen
      Screen
    end

    def command
      Command
    end

    def color
      Color
    end

    module Command
      extend ANSI

      module_function

      def code
        {
          clear_line: 'K',

          clear_down:   'J',
          clear_up:     '1J',
          clear_screen: '2J'
        }
      end

      def clear_line!
        pushesc code[:clear_line]
      end

      def clear_up!
        pushesc code[:clear_up]
      end

      def clear_down!
        pushesc code[:clear_down]
      end

      def clear_screen!
        pushesc code[:clear_screen]
      end
    end

    module Cursor
      extend ANSI

      module_function

      def code
        {
          # Movement
          home: 'H',
          up: '%{lines}A',
          down: '%{lines}B',
          to_column: '%{column}G',

          # May not work on all terminals.
          next_line: '%{lines}E',
          prev_line: '%{lines}F',

          # Visiblity
          show: '?25h',
          hide: '?25l'
        }
      end

      def to_column column
        esc code[:to_column] % {column: column}
      end

      def down lines = 1
        esc code[:down] % {lines: lines}
      end

      def up lines = 1
        esc code[:up] % {lines: lines}
      end

      def next_line lines = 1
        #esc code[:next_line] % {lines: lines}
        down(lines) + to_column(0)
      end

      def prev_line lines = 1
        #esc code[:prev_line] % {lines: lines}
        up(lines) + to_column(0)
      end

      def home!
        pushesc code[:home]
      end

      def hide!
        pushesc code[:hide]
      end

      def show!
        pushesc code[:show]
      end

      def next_line! lines = 1
        push next_line(lines)
      end

      def prev_line! lines = 1
        push prev_line(lines)
      end

      def beginning_of_line!
        to_column 0
      end

    end

    module Screen
      extend ANSI

      module_function

      def code
        {
          up:   'M',
          down: 'D'
        }
      end

      def reset!
        ANSI.color.reset!
        ANSI.cursor.home!
        clear!
      end

      def safe_reset!
        ANSI.cursor.home!
        ANSI.command.clear_down!
      end

      def clear!
        ANSI.command.clear_screen!
      end

      def up! count = 1
        count.times { pushe code[:up] }
      end

      def down!  count = 1
        count.times { pushe code[:down] }
      end
    end

    module Color
      extend ANSI

      module_function

      def code
        {
          reset: '0'
        }
      end

      def pushc *sequences
        push sequences.map{|sequence| c sequence }
      end

      def c sequence
        "#{esc sequence}m"
      end

      def reset!
        pushc code[:reset]
      end
    end
  end
end
