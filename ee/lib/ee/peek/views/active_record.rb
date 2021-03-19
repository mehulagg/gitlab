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
            detail[:db_role] = ::Gitlab::Database::LoadBalancing.db_role_for_connection(data[:connection])
          end

          detail
        end
      end
    end
  end
end
