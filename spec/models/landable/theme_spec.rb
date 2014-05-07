require 'spec_helper'

module Landable
  describe Theme do
    it { should have_valid(:thumbnail_url).when(nil) }
    it { should be_a HasAssets }
  end
end
