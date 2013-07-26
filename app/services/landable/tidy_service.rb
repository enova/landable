module Landable
  module TidyService

    mattr_accessor :options
    @@options = [
      # is what we have
      '-utf8',

      # two-space soft indents
      '-indent',

      # no wrapping
      '--wrap 0',

      # make some guesses about how the code should look
      '--clean true',

      # kill microsoft word crap
      '--bare true',

      # quote 'em up
      '--quote-ampersand true',

      # whitespace niceness
      '--break-before-br true',

      # allow <div ...><div ...></div></div>
      '--merge-divs false',
    ]


    def self.call input
      if not tidyable?
        raise StandardError, 'Your system doesn\'t seem to have tidy installed. Please see https://github.com/w3c/tidy-html5.'
      end

      output = IO.popen("tidy #{options.join(' ')}", 'r+') do |io|
        io.puts input
        io.close_write
        io.read
      end

      Result.new output
    end

    def self.tidyable?
      @@is_tidyable ||= Kernel.system('which tidy > /dev/null')
    end

    class Result < Object
      def initialize source
        @source = source
      end

      def to_s
        @source
      end

      def body
        if match = @source.match(/<body(?: [^>]*)?>(.*)<\/body>/m)
          deindent match[1]
        end
      end

      def head
        if match = @source.match(/<head>(.*)<\/head>/m)
          deindent match[1]
        end
      end

      def css
        links = head.try :scan, /<link [^>]*type=['"]text\/css['"][^>]*>/
        styles = head.try :scan, /<style[^>]*>.*?<\/style>/m
        [links.to_a, styles.to_a].flatten.join("\n\n")
      end

      protected

      def deindent string
        if match = string.match(/^([ \t]*)[^\s]/)
          string.gsub(/^#{match[1]}/, '').strip
        else
          string.strip
        end
      end
    end

  end
end