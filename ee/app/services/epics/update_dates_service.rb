# frozen_string_literal: true

module Epics
  class UpdateDatesService < ::BaseService
    BATCH_SIZE = 100

    STRATEGIES = [
      Epics::Strategies::StartDateInheritedStrategy,
      Epics::Strategies::DueDateInheritedStrategy
    ].freeze

    def initialize(epics)
      @epics = epics
      @epics = Epic.id_in(@epics) unless @epics.is_a?(ActiveRecord::Relation)
    end

    def execute
      each_batch do |relation, parent_ids|
        STRATEGIES.each do |strategy|
          strategy.new(relation).execute
        end

        if parent_ids.any?
          Epics::UpdateEpicsDatesWorker.perform_async(parent_ids)
        end
      end
    end

    private

    # rubocop: disable CodeReuse/ActiveRecord
    def each_batch
      @epics.in_batches(of: BATCH_SIZE) do |relation| # rubocop: disable Cop/InBatches
        parent_ids = relation.has_parent.distinct.pluck(:parent_id)

        yield(relation, parent_ids)
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
