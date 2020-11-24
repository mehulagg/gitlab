# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::Gitlab::GonHelper do
  let(:helper) do
    Class.new do
      include Gitlab::GonHelper

      def current_user
        nil
      end
    end.new
  end

  describe '#add_gon_variables' do
    let(:gon) { instance_double('gon').as_null_object }

    before do
      allow(helper).to receive(:gon).and_return(gon)
    end

    it 'includes ee exclusive settings' do
      expect(gon).to receive(:roadmap_epics_limit=).with(1000)

      helper.add_gon_variables
    end
  end
end
