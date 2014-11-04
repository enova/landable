module Landable
  module VERSION
    MAJOR = 1
    MINOR = 10
    PATCH = 0
    PRE   = 'rc2'

    STRING = [MAJOR, MINOR, PATCH, PRE].compact.join('.')
  end
end
