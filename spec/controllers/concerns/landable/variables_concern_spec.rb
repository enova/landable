require 'spec_helper'

module Landable
  # descriptions
  describe VariablesConcern, type: :controller do
    # setup
    controller(ApplicationController) do
      protected
        def hello_world
          "i live in a giant bucket."
        end

        def hello_cleveland
          "i am a banana."
        end
    end

    after(:each) do
      controller.class.imported_variables.clear
    end

    before(:each) do
      controller.class.instance_exec do
        register_landable_variable :hello_world
        register_landable_variable :is_rejected, :hello_cleveland
      end
    end

    # tests
    it "should include the VariablesConcern module" do
      # setup
      # actions
      # expectations
      expect(controller).to be_a Landable::VariablesConcern
      # end
    end

    it "should use the #register_landable_variable with a similarly named method" do
      # setup
      # actions
      # expectations
      expect(controller.fetch_landable_variables[:hello_world]).to eql("i live in a giant bucket.")
      # end
    end

    it "should use the #register_landable_variable with a custom named method" do
      # setup
      # actions
      # expectations
      expect(controller.fetch_landable_variables[:is_rejected]).to eql("i am a banana.")
      # end
    end

    it "should use the #register_landable_variable with a string-based name" do
      # setup
      # actions
      # expectations
      expect(controller.fetch_landable_variables['is_rejected']).to eql("i am a banana.")
      # end
    end

    # end
  end

  # end
end