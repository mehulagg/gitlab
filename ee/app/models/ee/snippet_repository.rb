# frozen_string_literal: true

module EE
  module SnippetRepository
    extend ActiveSupport::Concern

    prepended do
      include ::Gitlab::Geo::ReplicableModel
      include FromUnion

      with_replicator Geo::SnippetRepositoryReplicator
    end

    class_methods do
      # @param primary_key_in [Range, SnippetRepository] arg to pass to primary_key_in scope
      # @return [ActiveRecord::Relation<SnippetRepository>] everything that should be synced to this node, restricted by primary key
      def replicables_for_current_secondary(primary_key_in)
        node = ::Gitlab::Geo.current_node

        if !node.selective_sync?
          all.primary_key_in(primary_key_in)
        elsif node.selective_sync_by_namespaces?
          snippet_repositories_for_selected_namespaces(primary_key_in)
        elsif node.selective_sync_by_shards?
          snippet_repositories_for_selected_shards(primary_key_in)
        else
          self.none
        end
      end

      def snippet_repositories_for_selected_namespaces(primary_key_in)
        personal_snippets = self.where(snippet: ::Snippet.only_personal_snippets.primary_key_in(primary_key_in))

        project_snippets = self.where(snippet: ::Snippet.for_projects(::Gitlab::Geo.current_node.projects.select(:id))
                                                   .primary_key_in(primary_key_in))

        # We use `find_by_sql` here in order to perform the union operation and cast the results as
        # Snippet repositories. If we use a `from_union`, it wraps the query in in a sub-select and
        # it increases the query time by a surprising amount.
        self.find_by_sql(::Gitlab::SQL::Union.new([project_snippets, personal_snippets]).to_sql)
      end

      def snippet_repositories_for_selected_shards(primary_key_in)
        self
          .for_repository_storage(::Gitlab::Geo.current_node.selective_sync_shards)
          .primary_key_in(primary_key_in)
      end
    end

    # Geo checks this method in FrameworkRepositorySyncService to avoid
    # snapshotting repositories using object pools
    def pool_repository
      nil
    end
  end
end
