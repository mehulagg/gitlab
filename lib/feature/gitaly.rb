# frozen_string_literal: true

class Feature
  class Gitaly
    PREFIX = "gitaly_"

    class << self
      def enabled?(feature_flag, project = nil)
        return false unless Feature::FlipperFeature.table_exists?

        feature_flag = "#{PREFIX}#{feature_flag}" unless feature_flag.starts_with?(PREFIX)

        Feature.enabled?(feature_flag, project)
      rescue ActiveRecord::NoDatabaseError, PG::ConnectionBad
        false
      end

      def server_feature_flags(project = nil)
        # We need to check that both the DB connection and table exists
        return {} unless ::Gitlab::Database.cached_table_exists?(FlipperFeature.table_name)

        Feature
          .persisted_names
          .select { |f| f.start_with?(PREFIX) }
          .to_h { |f| [gitaly_feature_flag_name(f), enabled?(f, project).to_s] }
      end

      private

      def gitaly_feature_flag_name(feature_flag)
        "gitaly-feature-#{feature_flag.delete_prefix(PREFIX).tr('_', '-')}"
      end
    end
  end
end
