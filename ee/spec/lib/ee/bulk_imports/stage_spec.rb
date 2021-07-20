# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe BulkImports::Stage do
  let(:pipelines) do
    [
      [0, BulkImports::Groups::Pipelines::GroupPipeline],
      [1, BulkImports::Groups::Pipelines::GroupAvatarPipeline],
      [1, BulkImports::Groups::Pipelines::SubgroupEntitiesPipeline],
      [1, BulkImports::Groups::Pipelines::MembersPipeline],
      [1, BulkImports::Groups::Pipelines::LabelsPipeline],
      [1, BulkImports::Groups::Pipelines::MilestonesPipeline],
      [1, BulkImports::Groups::Pipelines::BadgesPipeline],
      [1, BulkImports::Groups::Pipelines::IterationsPipeline],
      [2, BulkImports::Groups::Pipelines::BoardsPipeline],
      [2, BulkImports::Groups::Pipelines::EpicsPipeline],
      [4, BulkImports::Groups::Pipelines::EntityFinisher]
    ]
  end

  describe '#each' do
    it 'iterates over all pipelines with the stage number' do
      expect(described_class.pipelines).to match_array(pipelines)
    end
  end
end
