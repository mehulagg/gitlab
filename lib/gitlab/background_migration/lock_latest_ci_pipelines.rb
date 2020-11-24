# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # Lock all latest Ci::Pipeline
    class LockLatestCiPipelines

      ARTIFACTS_LOCKED = 1

      module Ci
        class Pipeline < ActiveRecord::Base
          self.table_name = 'ci_pipelines'

          scope :latest, -> { where(id: select('DISTINCT ON ("project_id", "ref", "tag") "id"').order(project_id: :desc, ref: :desc, tag: :desc, id: :desc)) }

        end
      end

      def perform
        Ci::Pipeline.latest.update_all(locked: ARTIFACTS_LOCKED)
      end
    end
  end
end
