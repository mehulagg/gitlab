module DetectTransactionConnection
  extend ActiveSupport::Concern

  def select(*args, &block)
    query = args.first
    ci_tables = Ci::ApplicationRecord.descendants.map(&:table_name).uniq
    referenced_ci_tables = ci_tables.select { |table| query.include?(table) }
    super(*args, &block).tap do
      if referenced_ci_tables.any? && ActiveRecord::Base.transactions[:main].any?
        msg = "CI table(s) are referenced within Main DB transaction: #{referenced_ci_tables.join(', ')}"
        Rails.logger.info "-- #{msg}"
        raise msg
      elsif referenced_ci_tables.none? && ActiveRecord::Base.transactions[:ci].any?
        msg = "Non CI table(s) are referenced within CI DB transaction"

        Rails.logger.info "-- #{msg}"
        raise msg
      end
    end
  end
end

module DetectTransaction
  extend ActiveSupport::Concern

  class_methods do
    def transactions
      @@transactions ||= {
        ci: [],
        main: []
      }
    end

    def register_transaction_open(db)
      @@transactions ||= {
        ci: [],
        main: []
      }
      @@transactions[db] << 1
    end

    def register_transaction_close(db)
      @@transactions[db].pop
    end

    def transaction(**args, &block)
      db = ancestors.include?(Ci::ApplicationRecord) ? :ci : :main
      Rails.logger.info "-- Transaction open in DB: #{db}"

      register_transaction_open(db)
      super(**args, &block).tap do
        register_transaction_close(db)
        Rails.logger.info "-- Transaction closed in DB: #{db}"
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.prepend(DetectTransaction)
  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(DetectTransactionConnection)
end
