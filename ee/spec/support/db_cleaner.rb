# frozen_string_literal: true

module EE
  module DbCleaner
    extend ::Gitlab::Utils::Override

    override :deletion_except_tables
    def deletion_except_tables
      super << 'licenses'
    end

    override :setup_database_cleaner
    def setup_database_cleaner
      if ::Gitlab::Geo.geo_database_configured?
        ::DatabaseCleaner[:active_record, { connection: ::Geo::BaseRegistry }]
      end

      super
    end
  end
end
