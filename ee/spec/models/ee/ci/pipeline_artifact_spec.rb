# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::PipelineArtifact do
  using RSpec::Parameterized::TableSyntax
  include EE::GeoHelpers

  describe '#replicables_for_current_secondary' do
    # Selective sync is configured relative to the pipeline artifact's project.
    #
    # Permutations of sync_object_storage combined with object-stored-artifacts
    # are tested in code, because the logic is simple, and to do it in the table
    # would quadruple its size and have too much duplication.
    where(:selective_sync_namespaces, :selective_sync_shards, :factory, :project_factory, :include_expectation) do
      nil                  | nil    | [:ci_pipeline_artifact]           | [:project]               | true
      # selective sync by shard
      nil                  | :model | [:ci_pipeline_artifact]           | [:project]               | true
      nil                  | :other | [:ci_pipeline_artifact]           | [:project]               | false
      # selective sync by namespace
      :model_parent        | nil    | [:ci_pipeline_artifact]           | [:project]               | true
      :model_parent_parent | nil    | [:ci_pipeline_artifact]           | [:project, :in_subgroup] | true
      :other               | nil    | [:ci_pipeline_artifact]           | [:project]               | false
      :other               | nil    | [:ci_pipeline_artifact]           | [:project, :in_subgroup] | false
      # expired
      nil                  | nil    | [:ci_pipeline_artifact, :expired] | [:project]               | true
    end

    with_them do
      subject(:pipeline_artifact_included) { described_class.replicables_for_current_secondary(ci_pipeline_artifact).exists? }

      let(:project) { create(*project_factory) } # rubocop: disable Rails/SaveBang
      let(:pipeline) { create(:ci_pipeline, project: project) }
      let(:node) do
        create(:geo_node_with_selective_sync_for,
               model: project,
               namespaces: selective_sync_namespaces,
               shards: selective_sync_shards,
               sync_object_storage: sync_object_storage)
      end

      before do
        stub_artifacts_object_storage
        stub_current_geo_node(node)
      end

      context 'when sync object storage is enabled' do
        let(:sync_object_storage) { true }

        context 'when the pipeline artifact is locally stored' do
          let(:ci_pipeline_artifact) { create(*factory, pipeline: pipeline) }

          it { is_expected.to eq(include_expectation) }
        end

        context 'when the pipeline artifact is object stored' do
          let(:ci_pipeline_artifact) { create(*factory, :remote_store, pipeline: pipeline) }

          it { is_expected.to eq(include_expectation) }
        end
      end

      context 'when sync object storage is disabled' do
        let(:sync_object_storage) { false }

        context 'when the pipeline artifact is locally stored' do
          let(:ci_pipeline_artifact) { create(*factory, pipeline: pipeline) }

          it { is_expected.to eq(include_expectation) }
        end

        context 'when the pipeline artifact is object stored' do
          let(:ci_pipeline_artifact) { create(*factory, :remote_store, pipeline: pipeline) }

          it { is_expected.to be_falsey }
        end
      end
    end
  end
end
