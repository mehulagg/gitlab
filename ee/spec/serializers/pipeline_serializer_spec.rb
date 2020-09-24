# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PipelineSerializer do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:user) { create(:user) }

  let(:serializer) do
    described_class.new(current_user: user, project: project)
  end

  subject { serializer.represent(pipeline, details: true) }

  context 'when pipeline contains failed bridge jobs' do
    let(:pipeline) do
      create(:ci_empty_pipeline,
             project: project,
             status: :success,
             ref: :master)
    end

    before do
      create(:ci_bridge, pipeline: pipeline, status: :failed)
    end

    it 'serializes bridge job correctly' do
      name = subject.dig(:details, :stages, 0, :latest_statuses, 0, :name)

      expect(name).to eq 'bridge'
    end
  end
end
