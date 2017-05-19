require 'spec_helper'

module Landable
  module Traffic
    describe Referer do
      let(:referer) { Landable::Traffic::Referer.new(domain: 'www.something.com', path: '/mypath') }

      describe '#url' do
        it 'should return the entire url as a string' do
          expect(referer.url).to eq 'http://www.something.com/mypath'
        end
      end

      describe '#uri' do
        it 'should return the URI object' do
          test_uri = URI('http://www.something.com/mypath')
          expect(referer.uri).to eq test_uri
        end
      end
    end
  end
end
