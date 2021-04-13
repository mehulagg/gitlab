# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::Minutes::TrackLiveConsumptionService do
  let(:build) { create(:ci_build) }

  describe '#execute', :redis do
    subject { described_class.new.execute(build) }

    # TODO: continue
    it do
      subject
    end
  end
end
