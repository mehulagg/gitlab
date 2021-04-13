# frozen_string_literal: true

module BulkImports
  class ExportWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include ExceptionBacktrace

    feature_category :importers
    loggable_arguments 2
    sidekiq_options retry: false, dead: false

    def perform(current_user_id, exportable_id, exportable_class)
      user = User.find(current_user_id)
      exportable = exportable_object(exportable_id, exportable_class)

      top_relations_list = ExportHelper.exportable_relations(exportable_class)

      top_relations_list.each do |relation|

        exportable
      end


    end

    private

    def exportable_object(exportable_id, exportable_class)
      object_class = case exportable_class.to_s
                     when ::Project.name then ::Project
                     when ::Group.name then ::Group
                     else
                       raise "Unknown exportable type: #{exportable_class}!"
                     end

      object_class.find(exportable_id)
    end

    def create_pipeline_tracker_for(entity)
      BulkImports::Stage.pipelines.each do |stage, pipeline|
        entity.trackers.create!(
          stage: stage,
          pipeline_name: pipeline
        )
      end
    end
  end
end
