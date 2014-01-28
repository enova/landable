# TODO: test case for modifying a file updates or clobbers the proper attributes

require 'spec_helper'

module Landable
  describe Layout do
    it "creates themes" do
      Theme.destroy_all
      expect { described_class.all.each(&:to_theme) }.to change { Theme.count }.by(2)
    end

    it "defaults attributes" do
      theme = Theme.where(file: "application").first
      theme.attributes.should include({
        name:        'Application',
        file:        'application',
        extension:   'erb',
        editable:    false,
        description: 'Defined in application.html.erb'
      }.stringify_keys)

      theme.body.should == File.read(Rails.root.join('app/views/layouts/application.html.erb'))
    end
  end
end
