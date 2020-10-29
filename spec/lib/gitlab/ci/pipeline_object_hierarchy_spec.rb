# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::PipelineObjectHierarchy do
  include Ci::SourcePipelineHelpers

  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:ancestor) { create(:ci_pipeline, project: project) }
  let_it_be(:parent) { create(:ci_pipeline, project: project) }
  let_it_be(:child) { create(:ci_pipeline, project: project) }
  let_it_be(:cousin_parent) { create(:ci_pipeline, project: project) }
  let_it_be(:cousin) { create(:ci_pipeline, project: project) }
  let_it_be(:cousin_child) { create(:ci_pipeline, project: project) }
  let_it_be(:triggered_pipeline) { create(:ci_pipeline) }

  let(:ci_build_metadata_config_status) { false }

  before do
    # The use of this Feature Flag affects where options are stored and in particular
    # the `strategy:depend` config used by `while_dependent:true` option.
    stub_feature_flags(ci_build_metadata_config: ci_build_metadata_config_status)

    # ancestor
    #   - parent -> child -> triggered_pipeline
    #   - cousin_parent -> cousin -> cousin_child
    create_source_pipeline(ancestor, parent, strategy: :depend)
    create_source_pipeline(ancestor, cousin_parent, strategy: :depend)
    create_source_pipeline(parent, child, strategy: :depend)
    create_source_pipeline(cousin_parent, cousin, strategy: nil)
    create_source_pipeline(cousin, cousin_child, strategy: :depend)
    create_source_pipeline(child, triggered_pipeline, strategy: nil)
  end

  describe '#base_and_ancestors' do
    it 'includes the base and its ancestors' do
      relation = described_class.new(::Ci::Pipeline.where(id: parent.id),
                                     options: { same_project: true }).base_and_ancestors

      expect(relation).to contain_exactly(ancestor, parent)
    end

    it 'can find ancestors upto a certain level' do
      relation = described_class.new(::Ci::Pipeline.where(id: child.id),
                                     options: { same_project: true }).base_and_ancestors(upto: ancestor.id)

      expect(relation).to contain_exactly(parent, child)
    end

    describe 'hierarchy_order option' do
      let(:relation) do
        described_class.new(::Ci::Pipeline.where(id: child.id),
                            options: { same_project: true }).base_and_ancestors(hierarchy_order: hierarchy_order)
      end

      context ':asc' do
        let(:hierarchy_order) { :asc }

        it 'orders by child to ancestor' do
          expect(relation).to eq([child, parent, ancestor])
        end
      end

      context ':desc' do
        let(:hierarchy_order) { :desc }

        it 'orders by ancestor to child' do
          expect(relation).to eq([ancestor, parent, child])
        end
      end
    end
  end

  describe '#base_and_descendants' do
    it 'includes the base and its descendants' do
      relation = described_class.new(::Ci::Pipeline.where(id: parent.id),
                                     options: { same_project: true }).base_and_descendants

      expect(relation).to contain_exactly(parent, child)
    end

    context 'when with_depth is true' do
      let(:relation) do
        described_class.new(::Ci::Pipeline.where(id: ancestor.id),
                            options: { same_project: true }).base_and_descendants(with_depth: true)
      end

      it 'includes depth in the results' do
        object_depths = {
          ancestor.id => 1,
          parent.id => 2,
          cousin_parent.id => 2,
          child.id => 3,
          cousin.id => 3,
          cousin_child.id => 4
        }

        relation.each do |object|
          expect(object.depth).to eq(object_depths[object.id])
        end
      end
    end

    context 'when while_dependent is true' do
      let(:relation) do
        described_class.new(
          ::Ci::Pipeline.where(id: ancestor.id),
          options: { same_project: true, while_dependent: true }
        ).base_and_descendants
      end

      it 'returns pipelines as long as they use strategy:depend' do
        expect(relation).to contain_exactly(ancestor, parent, child, cousin_parent)
      end

      context 'when feature flag ci_build_metadata_config is enabled' do
        let(:ci_build_metadata_config_status) { true }

        it 'returns pipelines as long as they use strategy:depend' do
          expect(relation).to contain_exactly(ancestor, parent, child, cousin_parent)
        end
      end
    end
  end

  describe '#all_objects' do
    it 'includes its ancestors and descendants' do
      relation = described_class.new(::Ci::Pipeline.where(id: parent.id),
                                     options: { same_project: true }).all_objects

      expect(relation).to contain_exactly(ancestor, parent, child)
    end

    it 'returns all family tree' do
      relation = described_class.new(
        ::Ci::Pipeline.where(id: child.id),
        described_class.new(::Ci::Pipeline.where(id: child.id), options: { same_project: true }).base_and_ancestors,
        options: { same_project: true }
      ).all_objects

      expect(relation).to contain_exactly(ancestor, parent, cousin_parent, child, cousin, cousin_child)
    end
  end
end
