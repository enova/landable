require 'spec_helper'

module Landable
  describe Theme do
    it { should_not have_valid(:thumbnail_url).when(nil) }
  end
end
