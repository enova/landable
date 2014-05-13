module Landable
  module VERSION
    MAJOR = 1
    MINOR = 7
    PATCH = 1
    PRE   = 'rc1'

    STRING = [MAJOR, MINOR, PATCH, PRE].compact.join('.')
  end
end
