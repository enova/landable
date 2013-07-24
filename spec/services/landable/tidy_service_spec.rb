require 'spec_helper'

module Landable
  describe TidyService do
    let(:service) { TidyService }

    describe '.tidyable?' do
      context 'when tidyable' do
        it 'should check on the availability of a `tidy` command' do
          Kernel.should_receive(:system).with('which tidy > /dev/null') { true }
          service.should be_tidyable
        end
      end

      context 'not tidyable' do
        it 'should return false' do
          Kernel.should_receive(:system).with('which tidy > /dev/null') { false }
          service.should_not be_tidyable
        end
      end
    end

    describe '.tidy' do
      context 'when not tidyable' do
        it 'should raise an exception' do
          service.should_receive(:tidyable?) { false }
          expect { service.call 'foo' }.to raise_error(StandardError)
        end
      end
      
      context 'when tidyable' do
        it 'should invoke tidy' do
          input = double('input')
          output = double('output')

          mock_io = double('io')
          mock_io.should_receive(:puts).with(input).ordered
          mock_io.should_receive(:close_write).ordered
          mock_io.should_receive(:read) { output }

          service.should_receive(:options) { ['one', 'two', 'three'] }

          IO.should_receive(:popen).with('tidy one two three', 'r+').and_yield(mock_io)

          service.call(input).should == output
        end
      end
    end
  end
end