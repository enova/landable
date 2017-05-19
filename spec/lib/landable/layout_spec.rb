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
      expect(theme.attributes).to include({
        name:        'Application',
        file:        'application',
        extension:   'erb',
        editable:    false,
        description: 'Defined in application.html.erb'
      }.stringify_keys)

      expect(theme.body).to eq File.read(Rails.root.join('app/views/layouts/application.html.erb'))
    end

    context 'File Finding' do
      it 'will find the correct application files' do
        expect(Layout.files.any? { |f| f.end_with?('application.haml') }).to eq true
        expect(Layout.files.any? { |f| f.end_with?('application.html.erb') }).to eq true
        expect(Layout.files.any? { |f| f.end_with?('priority.html.erb') }).to eq true
        expect(Layout.files.any? { |f| f.end_with?('_partial.html.haml') }).to eq false
        expect(Layout.files.any? { |f| f.end_with?('partial.html.haml') }).to eq false
      end
    end
  end
end
