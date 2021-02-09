# frozen_string_literal: true

module EE
  module BulkImports
    module Importers
      module Groups
        class EpicRelationsImporter
          def initialize(entity)
            @entity = entity
          end

          def execute
            @entity.group.epics.find_each do |epic|
              context = ::BulkImports::Pipeline::Context.new(@entity)
              context.extra[:epic_iid] = epic.iid

              pipelines.each { |pipeline| pipeline.new.run(context) }
            end
          end

          def pipelines
            [
              EE::BulkImports::Groups::Pipelines::EpicAwardEmojiPipeline
            ]
          end
        end
      end
    end
  end
end
