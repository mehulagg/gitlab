# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Pipeline::Chain::SeedBlock do
  let(:project) { create(:project, :repository) }
  let(:user) { create(:user, developer_projects: [project]) }
  let(:seeds_block) {  }

  let(:command) do
    Gitlab::Ci::Pipeline::Chain::Command.new(
      project: project,
      current_user: user,
      origin_ref: 'master',
      seeds_block: seeds_block)
  end

  def run_chain(pipeline, command)
    [
      Gitlab::Ci::Pipeline::Chain::Config::Content.new(pipeline, command),
      Gitlab::Ci::Pipeline::Chain::Config::Process.new(pipeline, command)
    ].map(&:perform!)

    described_class.new(pipeline, command).perform!
  end

  let(:pipeline) { build(:ci_pipeline, project: project) }

  describe '#perform!' do
    before do
      stub_ci_pipeline_yaml_file(YAML.dump(config))
      run_chain(pipeline, command)
    end

    let(:config) do
      { rspec: { script: 'rake' } }
    end

    context 'when there is not seeds_block' do
      it 'does nothing' do
        # no-op
      end
    end

    context 'when there is seeds_block' do
      let(:seeds_block) do
        ->(pipeline) { pipeline.variables.build(key: 'VAR', value: '123') }
      end

      it 'executes the block' do
        expect(pipeline.variables.size).to eq(1)
      end
    end
  end
end
