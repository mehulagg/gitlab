# frozen_string_literal: true

module Projects
  module Security
    class CorpusManagementController < Projects::ApplicationController
      before_action do
        render_404 unless Feature.enabled?(:corpus_management, @project, default_enabled: :yaml)
        authorize_read_coverage_fuzzing!
      end

      feature_category :fuzz_testing

      def show
      end
    end
  end
end
