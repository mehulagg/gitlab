# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PipelineEntity do
  include Gitlab::Routing

  let(:project) { build_stubbed(:project) }
  let(:pipeline) { build_stubbed(:ci_empty_pipeline) }
  let(:request) { double('request', current_user: project.owner, project: project) }
  let(:entity) { described_class.represent(pipeline, request: request) }

  describe '#as_json' do
    subject { entity.as_json }

    it 'contains flags' do
      expect(subject).to include :flags
      expect(subject[:flags]).to include :merge_train_pipeline
    end
  end
end
