# frozen_string_literal: true

module BulkImports
  class Stage
    include Singleton

    def self.each
      instance.all.each_with_index do |pipelines, stage|
        Array.wrap(pipelines).each do |pipeline|
          yield(stage, pipeline)
        end
      end
    end

    def all
      @all ||= pipelines << last_stage
    end

    private

    def pipelines
      [
        BulkImports::Groups::Pipelines::GroupPipeline,
        [
          BulkImports::Groups::Pipelines::SubgroupEntitiesPipeline,
          BulkImports::Groups::Pipelines::MembersPipeline,
          BulkImports::Groups::Pipelines::LabelsPipeline,
          BulkImports::Groups::Pipelines::MilestonesPipeline
        ]
      ]
    end

    def last_stage
      BulkImports::Groups::Pipelines::EntityFinisher
    end
  end
end

::BulkImports::Stage.prepend_if_ee('::EE::BulkImports::Stage')
