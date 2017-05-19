require 'spec_helper'

module Landable
  describe TidyService do
    let(:service) { TidyService }

    describe '.tidyable?' do
      after(:each) { service.instance_variable_set :@is_tidyable, nil }

      context 'when tidyable' do
        it 'should check on the availability of a `tidy` command' do
          expect(Kernel).to receive(:system).with('which tidy > /dev/null') { true }
          expect(service).to be_tidyable
          expect(service.instance_variable_get(:@is_tidyable)).to eq true
        end
      end

      context 'not tidyable' do
        it 'should return false' do
          expect(Kernel).to receive(:system).with('which tidy > /dev/null') { false }
          expect(service).not_to be_tidyable
          expect(service.instance_variable_get(:@is_tidyable)).to eq false
        end
      end
    end

    describe '.call!' do
      it 'should call #call with raise_on_error: true' do
        input = double
        output = double
        expect(service).to receive(:call).with(input, raise_on_error: true) { output }
        expect(service.call!(input)).to eq output
      end
    end

    describe '.call' do
      context 'when not tidyable' do
        it 'should raise an exception' do
          expect(service).to receive(:tidyable?) { false }
          expect { service.call 'foo' }.to raise_error(StandardError)
        end
      end

      context 'when tidyable' do
        before(:each) do
          expect(service).to receive(:tidyable?) { true }
        end

        it 'should invoke tidy and return a Result' do
          input = double('input')
          output = double('output')
          result = double('result')

          expect(service).to receive(:wrap_liquid) { |value| value }.ordered # passthrough; will test later

          mock_io = double('io')
          expect(mock_io).to receive(:puts).with(input).ordered
          expect(mock_io).to receive(:close_write).ordered
          expect(mock_io).to receive(:read) { output }

          expect(service).to receive(:unwrap_liquid) { |value| value }.ordered # passthrough; will test later

          # other setup
          expect(service).to receive(:options) { %w(one two three) }
          expect(IO).to receive(:popen).with('tidy one two three', 'r+').and_yield(mock_io)

          expect(TidyService::Result).to receive(:new).with(output) { result }

          expect(service.call(input)).to eq result
        end

        it 'should wrap known liquid tags before sending to tidy, and unwrap them after' do
          original_string = '<div> {% template foobar title: "sixteen" %} <span> {% meta_tags "something" %} </span> </div>'
          wrapped_string = '<div> <div data-liquid="' + Base64.encode64('{% template foobar title: "sixteen" %}').strip + '"></div> <span> <div data-liquid="' + Base64.encode64('{% meta_tags "something" %}').strip + '"></div> </span> </div>'

          # mock out tidy itself, and make it a no-op
          mock_io = double('io')
          expect(mock_io).to receive(:puts).with(wrapped_string)
          expect(mock_io).to receive(:close_write)
          expect(mock_io).to receive(:read) { wrapped_string }
          expect(IO).to receive(:popen).and_yield(mock_io)

          # ensuring that the output == the input, modulo any new whitespace
          expect(service.call(original_string).to_s.gsub(/\s+/, ' ')).to eq original_string.gsub(/\s+/, ' ')
        end

        context 'raise_on_error is enabled' do
          it 'should raise TidyError when status is 2' do
            expect(IO).to receive(:popen)
            expect($CHILD_STATUS).to receive(:exitstatus) { 2 }

            # meh, shouldn't have to do this. could use a refactor.
            expect(service).to receive(:wrap_liquid) { |input| input }

            expect { service.call('<div>foo</div>', raise_on_error: true) }.to raise_error TidyService::TidyError
          end

          it 'should be cool when status is 1' do
            expect(IO).to receive(:popen)
            expect($CHILD_STATUS).to receive(:exitstatus) { 1 }

            # meh, shouldn't have to do this. could use a refactor.
            expect(service).to receive(:wrap_liquid)   { |input| input }
            expect(service).to receive(:unwrap_liquid) { |input| input }

            expect { service.call('<div>foo</div>', raise_on_error: true) }.not_to raise_error
          end
        end
      end
    end
  end

  module TidyService
    describe Result do
      let(:result) do
        Result.new <<-eof
<html>
  <head>
    <link type="text/css" rel="stylesheet">
    <title>sup</title>
    <style type="text/css">
      body {}
    </style>
  </head>
  <body class="foo">
    <div>hello</div>
    <div>friend</div>
  </body>
</html>
eof
      end

      describe '#to_s' do
        it 'should return the string given on init' do
          expect(Result.new('foobar').to_s).to eq 'foobar'
        end
      end

      describe '#body' do
        it 'should return the de-indented contents of <body>' do
          expect(result.body).to eq "<div>hello</div>\n<div>friend</div>"
        end
      end

      describe '#head' do
        it 'should return the de-indented contents of <head>' do
          expect(result.head).to eq "<link type=\"text/css\" rel=\"stylesheet\">\n<title>sup</title>\n<style type=\"text/css\">\n  body {}\n</style>"
        end
      end

      describe '#css' do
        it 'should return embedded and linked stylesheets from the head' do
          expect(result.css).to eq "<link type=\"text/css\" rel=\"stylesheet\">\n\n<style type=\"text/css\">\n  body {}\n</style>"
        end
      end
    end
  end
end
