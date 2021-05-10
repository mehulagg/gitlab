# frozen_string_literal: true

module Ci
  class DeleteUnitTestsService
    include EachBatch

    BATCH_SIZE = 100

    # rubocop: disable CodeReuse/ActiveRecord
    def execute
      ids = Ci::UnitTestFailure.deletable.pluck(:id)
      ids.in_groups_of(BATCH_SIZE, false) do |ids|
        Ci::UnitTestFailure.where(id: ids).delete_all
      end

      ids = Ci::UnitTest.deletable.pluck(:id)
      ids.in_groups_of(BATCH_SIZE, false) do |ids|
        Ci::UnitTest.where(id: ids).delete_all
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
