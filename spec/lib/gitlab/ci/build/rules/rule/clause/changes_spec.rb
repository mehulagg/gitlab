# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Build::Rules::Rule::Clause::Changes do
  describe '#satisfied_by?' do
    it_behaves_like 'a glob matching rule' do
      let(:pipeline) { build(:ci_pipeline) }

      before do
        allow(pipeline).to receive(:modified_paths).and_return(files.keys)
      end

      subject { described_class.new(globs).satisfied_by?(pipeline, nil) }
    end

    context 'when using variable expansion' do
      let_it_be(:pipeline) { create(:ci_pipeline) }

      let(:globs) { ['$HELM_DIR/**/*'] }
      let(:modified_paths) { ['helm/test.txt'] }
      let(:stage_attributes) { {} }

      let(:context) do
        Gitlab::Ci::Build::Context::Build.new(pipeline, stage_attributes)
      end

      subject { described_class.new(globs).satisfied_by?(pipeline, context) }

      before do
        allow(pipeline).to receive(:modified_paths).and_return(modified_paths)
      end

      context 'when context is nil' do
        let(:context) {}

        it { is_expected.to be_falsey }
      end

      context 'when context has YAML variables' do
        let(:stage_attributes) do
          {
            yaml_variables: [
              { key: "HELM_DIR", value: "helm", public: true }
            ]
          }
        end

        it { is_expected.to be_truthy }
      end

      context 'when rules use predefined variables' do
        let(:globs) { ['$CI_JOB_NAME/**/*'] }

        let(:stage_attributes) do
          { name: 'helm' }
        end

        it { is_expected.to be_truthy }
      end

      context 'when variable expansion does not match' do
        let(:globs) { ['path/with/$in/it/*'] }
        let(:modified_paths) { ['path/with/$in/it/file.txt'] }

        it { is_expected.to be_truthy }
      end
    end
  end
end
