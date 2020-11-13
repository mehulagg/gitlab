# frozen_string_literal: true

module CycleAnalytics
  module LevelBase
    STAGES = %i[issue plan code test review staging].freeze

    # This is a temporary adapter class which makes the new value stream (cycle analytics)
    # backend compatible with the old implementation.
    class LegacyStageAdapter
      def initialize(stage, options)
        @stage = stage
        @options = options
      end

      # rubocop: disable CodeReuse/Presenter
      def as_json
        presenter = Analytics::CycleAnalytics::StagePresenter.new(stage)

        AnalyticsStageEntity.new(OpenStruct.new(
                                   title: presenter.title,
                                   description: presenter.description,
                                   legend: presenter.legend,
                                   name: stage.name,
                                   project_median: project_median
                                 )).as_json
      end
      # rubocop: enable CodeReuse/Presenter

      def events
        data_collector.records_fetcher.serialized_records
      end

      def project_median
        data_collector.median.seconds
      end

      private

      attr_reader :stage, :options

      def data_collector
        @data_collector ||= Gitlab::Analytics::CycleAnalytics::DataCollector.new(stage: stage, params: options)
      end
    end

    def all_medians_by_stage
      STAGES.each_with_object({}) do |stage_name, medians_per_stage|
        medians_per_stage[stage_name] = self[stage_name].project_median
      end
    end

    def stats
      STAGES.map do |stage_name|
        self[stage_name].as_json
      end
    end

    def no_stats?
      stats.all? { |hash| hash[:value].nil? }
    end

    def [](stage_name)
      if Feature.enabled?(:new_project_level_vsa_backend)
        stage_params = stage_params_by_name(stage_name).merge(project: project)
        stage = Analytics::CycleAnalytics::ProjectStage.new(stage_params)
        LegacyStageAdapter.new(stage, options)
      else
        Gitlab::CycleAnalytics::Stage[stage_name].new(options: options)
      end
    end

    def stage_params_by_name(name)
      Gitlab::Analytics::CycleAnalytics::DefaultStages.all.find { |raw_stage| raw_stage[:name].to_s.eql?(name.to_s) } || raise("Default stage '#{name}' not found")
    end
  end
end
