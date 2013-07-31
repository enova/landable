require 'spec_helper'

module Landable
  describe Template do
    it { should have_valid(:thumbnail_url).when(nil) }
  end
end
