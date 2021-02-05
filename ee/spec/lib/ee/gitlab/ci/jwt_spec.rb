# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Jwt do
  let(:namespace) { build_stubbed(:namespace) }
  let(:project) { build_stubbed(:project, namespace: namespace) }
  let(:user) { build_stubbed(:user) }
  let(:pipeline) { build_stubbed(:ci_pipeline, ref: 'auto-deploy-2020-03-19') }
  let(:environment) { build_stubbed(:environment, project: project, name: 'production') }
  let(:build) do
    build_stubbed(
      :ci_build,
      project: project,
      user: user,
      pipeline: pipeline,
      environment: environment.name
    )
  end

  describe '#payload' do
    before do
      allow(build).to receive(:persisted_environment).and_return(environment)
    end

    subject(:payload) { described_class.new(build, ttl: 30).payload }

    describe 'environment_protected' do
      it 'is false when environment is not protected' do
        expect(environment).to receive(:protected?).and_return(false)

        expect(payload[:environment_protected]).to eq('false')
      end

      it 'is true when environment is protected' do
        expect(environment).to receive(:protected?).and_return(true)

        expect(payload[:environment_protected]).to eq('true')
      end
    end
  end
end
