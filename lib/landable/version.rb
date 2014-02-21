module Landable
  module VERSION
    MAJOR = 1
    MINOR = 5
    PATCH = 2
    PRE   = 'pre1'

    STRING = [MAJOR, MINOR, PATCH, PRE].compact.join('.')
  end
end
