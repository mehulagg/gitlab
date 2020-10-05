# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Clusters::AgentResolver do
  it { expect(described_class).to be < Resolvers::Clusters::AgentsResolver }

  describe 'arguments' do
    subject { described_class.arguments[argument] }

    describe 'name' do
      let(:argument) { 'name' }

      it do
        expect(subject).to be_present
        expect(subject.type.to_s).to eq('String!')
        expect(subject.description).to be_present
      end
    end
  end
end
