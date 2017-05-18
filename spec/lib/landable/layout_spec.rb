# TODO: test case for modifying a file updates or clobbers the proper attributes

require 'spec_helper'

module Landable
  describe Layout do
    it 'creates themes' do
      Theme.destroy_all
      expect { described_class.all.each(&:to_theme) }.to change { Theme.count }.by(3)
    end

    it 'defaults attributes' do
      theme = Theme.where(file: 'application').first
      theme.attributes.should include({
        name:        'Application',
        file:        'application',
        extension:   'erb',
        editable:    false,
        description: 'Defined in application.html.erb'
      }.stringify_keys)

      theme.body.should eq File.read(Rails.root.join('app/views/layouts/application.html.erb'))
    end

    context 'File Finding' do
      it 'will find the correct application files' do
        Layout.files.any? { |f| f.end_with?('application.haml') }.should eq true
        Layout.files.any? { |f| f.end_with?('application.html.erb') }.should eq true
        Layout.files.any? { |f| f.end_with?('priority.html.erb') }.should eq true
        Layout.files.any? { |f| f.end_with?('_partial.html.haml') }.should eq false
        Layout.files.any? { |f| f.end_with?('partial.html.haml') }.should eq false
      end
    end
  end
end
