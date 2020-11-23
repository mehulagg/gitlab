# frozen_string_literal: true

class CodequalityReportsComparerEntity < Grape::Entity
  expose :status

  expose :new_errors, using: CodeQualityDegradationEntity
  expose :resolved_errors, using: CodeQualityDegradationEntity
  expose :existing_errors, using: CodeQualityDegradationEntity

  expose :summary do
    expose :total_count, as: :total
    expose :resolved_count, as: :resolved
    expose :errors_count, as: :errored
  end
end
