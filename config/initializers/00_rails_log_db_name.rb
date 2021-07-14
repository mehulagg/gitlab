module LogDatabase
  module AbstractAdapter
    extend ActiveSupport::Concern

    def translate_exception(exception, message:, sql:, binds:)
      # override in derived class
      case exception
      when RuntimeError
        exception
      else
        ActiveRecord::StatementInvalid.new(message + " db_name: #{@connection_parameters[:dbname]}", sql: sql, binds: binds)
      end
    end
  end
end

ActiveRecord::ConnectionAdapters::AbstractAdapter.prepend(LogDatabase::AbstractAdapter)
