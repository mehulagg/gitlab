# frozen_string_literal: true

module Gitlab
  module StatusPage
    module Pipeline
      class PostProcessPipeline < ::Banzai::Pipeline::PostProcessPipeline
        def self.filters
          @filters ||= super
            .dup
            .insert_before(::Banzai::Filter::ReferenceRedactorFilter,
                           Gitlab::StatusPage::Filter::MentionAnonymizationFilter)
            .concat(::Banzai::FilterArray[StatusPage::Filter::ImageFilter])
            .freeze
        end
      end
    end
  end
end
