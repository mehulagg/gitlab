# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::API::Entities::Experiment do
  describe '#as_json' do
    let(:experiment) { { key: 'experiment_1', enabled: true } }
    let(:entity) { described_class.new(experiment) }

    subject { entity.as_json }

    it { is_expected.to match({ key: experiment[:key], enabled: experiment[:enabled] }) }
  end
end
