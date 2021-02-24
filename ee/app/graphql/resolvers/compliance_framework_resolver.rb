# frozen_string_literal: true

module Resolvers
  class ComplianceFrameworkResolver < BaseResolver
    include Gitlab::Graphql::Authorize::AuthorizeResource

    type ::Types::ComplianceManagement::ComplianceFrameworkType.connection_type, null: true

    when_single do
      argument :id, ::Types::GlobalIDType[::ComplianceManagement::Framework],
               description: 'Global ID of a specific compliance framework to return.',
               required: false
    end

    def resolve(id: nil)
      id = ::Types::GlobalIDType[::ComplianceManagement::Framework].coerce_isolated_input(id) unless id.nil?
      BatchLoader::GraphQL
        .for([object.id, id&.model_id])
        .batch(default_value: []) do |keys, loader|
        namespace_ids = keys.map(&:first).uniq
        by_namespace_id = keys.group_by(&:first).transform_values { |k| k.map(&:second) }
        frameworks = ::ComplianceManagement::Framework.with_namespaces(namespace_ids)
        frameworks.group_by(&:namespace_id).each do |ns_id, group|
          by_namespace_id[ns_id].each do |fw_id|
            group.each do |fw|
              next unless allowed?
              next unless fw_id.nil? || fw_id.to_i == fw.id

              loader.call([ns_id, fw_id]) { |array| array << fw }
            end
          end
        end
      end
    end

    private

    def allowed?
      Ability.allowed?(context[:current_user], :admin_compliance_framework, object)
    end
  end
end
