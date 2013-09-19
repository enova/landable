require 'spec_helper'

module Landable
  describe TidyService do
    let(:service) { TidyService }

    describe '.tidyable?' do
      after(:each) { service.class_variable_set :@@is_tidyable, nil }

      context 'when tidyable' do
        it 'should check on the availability of a `tidy` command' do
          Kernel.should_receive(:system).with('which tidy > /dev/null') { true }
          service.should be_tidyable
          service.class_variable_get(:@@is_tidyable).should be_true
        end
      end

      context 'not tidyable' do
        it 'should return false' do
          Kernel.should_receive(:system).with('which tidy > /dev/null') { false }
          service.should_not be_tidyable
          service.class_variable_get(:@@is_tidyable).should be_false
        end
      end
    end

    describe '.call!' do
      it 'should call #call with raise_on_error: true' do
        input = double
        output = double
        service.should_receive(:call).with(input, raise_on_error: true) { output }
        service.call!(input).should == output
      end
    end

    describe '.call' do
      context 'when not tidyable' do
        it 'should raise an exception' do
          service.should_receive(:tidyable?) { false }
          expect { service.call 'foo' }.to raise_error(StandardError)
        end
      end
      
      context 'when tidyable' do
        before(:each) do
          service.should_receive(:tidyable?) { true }
        end

        it 'should invoke tidy and return a Result' do
          input = double('input')
          output = double('output')
          result = double('result')

          service.should_receive(:wrap_liquid) { |input| input }.ordered # passthrough; will test later

          mock_io = double('io')
          mock_io.should_receive(:puts).with(input).ordered
          mock_io.should_receive(:close_write).ordered
          mock_io.should_receive(:read) { output }

          service.should_receive(:unwrap_liquid) { |input| input }.ordered # passthrough; will test later

          # other setup
          service.should_receive(:options) { ['one', 'two', 'three'] }
          IO.should_receive(:popen).with('tidy one two three', 'r+').and_yield(mock_io)

          TidyService::Result.should_receive(:new).with(output) { result }

          service.call(input).should == result
        end

        it 'should wrap known liquid tags before sending to tidy, and unwrap them after' do
          original_string = '<div> {% template foobar title: "sixteen" %} <span> {% meta_tags "something" %} </span> </div>'
          wrapped_string = '<div> <div data-liquid="' + Base64.encode64('{% template foobar title: "sixteen" %}').strip + '"></div> <span> <div data-liquid="' + Base64.encode64('{% meta_tags "something" %}').strip + '"></div> </span> </div>'

          # mock out tidy itself, and make it a no-op
          mock_io = double('io')
          mock_io.should_receive(:puts).with(wrapped_string)
          mock_io.should_receive(:close_write)
          mock_io.should_receive(:read) { wrapped_string }
          IO.should_receive(:popen).and_yield(mock_io)

          # ensuring that the output == the input, modulo any new whitespace
          service.call(original_string).to_s.gsub(/\s+/, ' ').should == original_string.gsub(/\s+/, ' ')
        end

        context 'raise_on_error is enabled' do
          it 'should raise TidyError when status is 2' do
            IO.should_receive(:popen)
            $?.should_receive(:exitstatus) { 2 }

            # meh, shouldn't have to do this. could use a refactor.
            service.should_receive(:wrap_liquid) { |input| input }

            expect { service.call('<div>foo</div>', raise_on_error: true) }.to raise_error TidyService::TidyError
          end

          it 'should be cool when status is 1' do
            IO.should_receive(:popen)
            $?.should_receive(:exitstatus) { 1 }

            # meh, shouldn't have to do this. could use a refactor.
            service.should_receive(:wrap_liquid) { |input| input }

            expect { service.call('<div>foo</div>', raise_on_error: true) }.to_not raise_error TidyService::TidyError
          end
        end
      end
    end
  end

  module TidyService
    describe Result do

      let(:result) { Result.new <<-eof
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
      }

      describe '#to_s' do
        it 'should return the string given on init' do
          Result.new('foobar').to_s.should == 'foobar'
        end
      end

      describe '#body' do
        it 'should return the de-indented contents of <body>' do
          result.body.should == "<div>hello</div>\n<div>friend</div>"
        end
      end

      describe '#head' do
        it 'should return the de-indented contents of <head>' do
          result.head.should == "<link type=\"text/css\" rel=\"stylesheet\">\n<title>sup</title>\n<style type=\"text/css\">\n  body {}\n</style>"
        end
      end

      describe '#css' do
        it 'should return embedded and linked stylesheets from the head' do
          result.css.should == "<link type=\"text/css\" rel=\"stylesheet\">\n\n<style type=\"text/css\">\n  body {}\n</style>"
        end
      end
    end
  end
end