require 'spec_helper'

describe Landable::Asset do
  def asset_fixture(name)
    File.expand_path("../../../fixtures/assets/#{name}", __FILE__)
  end

  let(:png) { File.open(asset_fixture('panda.png')) }
  let(:pdf) { File.open(asset_fixture('small.pdf')) }

  after do
    png.close
    pdf.close
  end

  it 'has a human-facing name, that need not be unique'
  it 'must have an author'
  it 'stores a SHA of its content'
  it 'rejects duplicate SHAs'
  it 'stores its mime type'
  it "stores its file's basename"
end
