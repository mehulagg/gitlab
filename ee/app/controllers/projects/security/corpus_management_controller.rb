# frozen_string_literal: true

module Projects
  module Security
    class CorpusManagementController < Projects::ApplicationController
      before_action do
        authorize_read_corpus_management!
        push_frontend_feature_flag(:corpus_managment, @project, default_enabled: :yaml)
      end

      feature_category :fuzz_testing

      def show
        return render_404 unless Feature.enabled?(:corpus_managment)
      end
    end
  end
end