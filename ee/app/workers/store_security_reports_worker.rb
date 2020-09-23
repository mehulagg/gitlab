# frozen_string_literal: true

# Worker for storing security reports into the database.
#
class StoreSecurityReportsWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include SecurityScansQueue

  def perform(pipeline_id)
    Ci::Pipeline.find(pipeline_id).try do |pipeline|
      break unless pipeline.project.can_store_security_reports?

      ::Security::StoreReportsService.new(pipeline).execute
    end
  end
end
