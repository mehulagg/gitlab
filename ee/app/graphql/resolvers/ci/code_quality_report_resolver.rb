# frozen_string_literal: true

module Resolvers
  module Ci
    class CodeQualityReportResolver < BaseResolver
      # include Gitlab::Graphql::Authorize::AuthorizeResource

      type ::Types::Ci::CodeQualityReportType, null: true
      # authorize :read_build
      # authorizes_object!

      alias_method :pipeline, :object

      def resolve
        # binding.pry
        # return unless pipeline.has_reports?(::Ci::JobArtifact.codequality_reports)

        pipeline.codequality_reports
      end
    end
  end
end
