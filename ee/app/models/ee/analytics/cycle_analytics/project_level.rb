# frozen_string_literal: true

module EE
  module Analytics
    module CycleAnalytics
      module ProjectLevel
        def time_summary
          @time_summary ||= begin
            stage = ::Analytics::CycleAnalytics::ProjectStage.new(project: project)

            ::Gitlab::Analytics::CycleAnalytics::Summary::StageTimeSummary
              .new(stage, options: options)
              .data
          end
        end
      end
    end
  end
end
