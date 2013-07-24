module Landable
  module TidyService

    mattr_accessor :options
    @@options = [
      '-indent',
      '--wrap 0',
      '--clean true',
      '--bare true',
      '--quote-ampersand true',
      '--show-body-only true',
      '--break-before-br true',
      # '--vertical-space true',
    ]

    def self.call input
      if not tidyable?
        raise Exeception('Your system doesn\'t seem to have tidy installed. Please see https://github.com/w3c/tidy-html5.')
      end

      IO.popen("tidy #{options.join(' ')}", 'r+') do |io|
        io.puts input
        io.close_write
        io.read
      end
    end

    def self.tidyable?
      Kernel.system('which tidy > /dev/null')
    end

  end
end