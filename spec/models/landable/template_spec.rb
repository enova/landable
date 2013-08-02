require 'spec_helper'

module Landable
  describe Template do
    describe 'validators' do
      # some valid seed data
      before(:each) { create :template }

      it { should validate_presence_of :name }
      it { should validate_presence_of :description }
      it { should validate_presence_of :slug }
      it { should validate_uniqueness_of :slug }
    end

    describe '#name=' do
      context 'without a slug' do
        it 'should assign a slug' do
          template = build(:template, slug: nil)
          template.name = 'Six Seven'
          template.name.should == 'Six Seven'
          template.slug.should == 'six_seven'
        end
      end

      context 'with a slug' do
        it 'should leave the slug alone' do
          template = build(:template, slug: 'six')
          template.name = 'seven'
          template.name.should == 'seven'
          template.slug.should == 'six'
        end
      end
    end
  end
end
