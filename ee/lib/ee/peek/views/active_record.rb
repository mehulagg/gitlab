# frozen_string_literal: true

module EE
  module Peek
    module Views
      module ActiveRecord
        extend ::Gitlab::Utils::Override

        override :generate_detail
        def generate_detail(start, finish, data)
          detail = super

          if ::Gitlab::Database::LoadBalancing.enable?
            role = ::Gitlab::Database::LoadBalancing.db_role_for_connection(data[:connection]) || :unknown
            detail[:db_role] = role.to_s.capitalize
          end

          detail
        end

        override :count_summary
        def count_summary(item, count)
          super

          if ::Gitlab::Database::LoadBalancing.enable?
            count[item[:db_role]] ||= 0
            count[item[:db_role]] += 1
          end
        end
      end
    end
  end
end
