# frozen_string_literal: true

class BuildReportResultsEntity < Grape::Entity
  expose :name
  expose :duration
  expose :success
  expose :failed
  expose :errored
  expose :skipped
  expose :total
end
