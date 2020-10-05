# frozen_string_literal: true

module GemExtensions
  module Elasticsearch
    module Model
      module Adapter
        module ActiveRecord
          # rubocop:disable all
          module Records
            # Original method
            # https://github.com/elastic/elasticsearch-rails/blob/v6.1.0/elasticsearch-model/lib/elasticsearch/model/adapters/active_record.rb#L21
            def records
              sql_records = klass.where(klass.primary_key => ids)
              sql_records = sql_records.includes(self.options[:includes]) if self.options[:includes]

              # Re-order records based on the order from Elasticsearch hits
              # by redefining `to_a`, unless the user has called `order()`
              #
              sql_records.instance_exec(response.response['hits']['hits']) do |hits|
                ar_records_method_name = :to_a
                ar_records_method_name = :records if defined?(::ActiveRecord) && ::ActiveRecord::VERSION::MAJOR >= 5

                define_singleton_method(ar_records_method_name) do
                  if defined?(::ActiveRecord) && ::ActiveRecord::VERSION::MAJOR >= 4
                    self.load
                  else
                    self.__send__(:exec_queries)
                  end
                  if !self.order_values.present?
                    # BEGIN_MONKEY_PATCH
                    #
                    # Monkey patch sorting because we monkey patch ids and the
                    # previous code uses `hit['_id']` which does not match our
                    # record.id. We instead need `hit['_source']['id']`.
                    @records.sort_by { |record| hits.index { |hit| hit['_source']['id'].to_s == record.id.to_s } }
                    # END_MONKEY_PATCH
                  else
                    @records
                  end
                end if self
              end

              sql_records
            end
          end
          # rubocop:enable all
        end
      end
    end
  end
end
