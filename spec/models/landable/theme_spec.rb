require 'spec_helper'

module Landable
  describe Theme do
    it { should have_valid(:thumbnail_url).when(nil) }
  end
end
