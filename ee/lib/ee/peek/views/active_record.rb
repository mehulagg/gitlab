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
            detail[:db_role] = ::Gitlab::Database::LoadBalancing.db_role_for_connection(data[:connection]).to_s.capitalize
          end

          detail
        end

        override :summary
        def summary
          return super unless ::Gitlab::Database::LoadBalancing.enable?

          role_summary =
            detail_store
            .group_by { |item| item[:db_role] }
            .map { |group, items| "#{items.length} #{group}" }

          role_summary + super
        end
      end
    end
  end
end
