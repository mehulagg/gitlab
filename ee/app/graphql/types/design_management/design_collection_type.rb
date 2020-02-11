# frozen_string_literal: true

module Types
  module DesignManagement
    class DesignCollectionType < BaseObject
      graphql_name 'DesignCollection'
      description 'A collection of designs.'

      authorize :read_design

      field :project, Types::ProjectType, null: false,
            description: 'Project associated with the design collection'
      field :issue, Types::IssueType, null: false,
            description: 'Issue associated with the design collection'

      field :designs,
            Types::DesignManagement::DesignsConnectionType,
            null: false,
            resolver: Resolvers::DesignManagement::DesignsResolver,
            description: 'All designs for the design collection'

      field :versions,
            Types::DesignManagement::VersionType.connection_type,
            resolver: Resolvers::DesignManagement::VersionsResolver,
            description: 'All versions related to all designs, ordered newest first'

      field :version,
            Types::DesignManagement::VersionType,
            resolver: Resolvers::DesignManagement::VersionsResolver.single,
            description: 'A specific version'

      field :design_at_version, ::Types::DesignManagement::DesignAtVersionType,
            null: true,
            resolver: ::Resolvers::DesignManagement::DesignAtVersionResolver,
            description: 'Find a design as of a version'

      field :design, ::Types::DesignManagement::DesignType,
            null: true,
            resolver: ::Resolvers::DesignManagement::DesignResolver,
            description: 'Find a specific design'
    end
  end
end
