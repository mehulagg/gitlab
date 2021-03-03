# frozen_string_literal: true

module EE
  module Backup
    module Repositories
      extend ::Gitlab::Utils::Override

      override :restore
      def restore
        restore_group_repositories

        super
      end

      private

      override :repository_storage_klasses
      def repository_storage_klasses
        super << GroupWikiRepository
      end

      def restore_group_repositories
        find_groups_in_batches do |group|
          restore_repository(group, ::Gitlab::GlRepository::WIKI)
        end
      end

      def group_relation
        ::Group.includes(:route, :owners, group_wiki_repository: :shard) # rubocop: disable CodeReuse/ActiveRecord
      end

      def find_groups_in_batches(&block)
        group_relation.find_each(batch_size: 1000) do |group| # rubocop: disable CodeReuse/ActiveRecord
          yield(group)
        end
      end

      override :dump_container
      def dump_container(container)
        if container.is_a?(Group)
          dump_group(container)
        else
          super
        end
      end

      def dump_group(group)
        backup_repository(group, ::Gitlab::GlRepository::WIKI)
      end

      override :dump_consecutive
      def dump_consecutive
        dump_consecutive_groups

        super
      end

      def dump_consecutive_groups
        find_groups_in_batches do |group|
          dump_group(group)
        end
      end

      override :records_to_enqueue
      def records_to_enqueue(storage)
        super << groups_in_storage(storage)
      end

      def groups_in_storage(storage)
        group_relation.id_in(GroupWikiRepository.for_repository_storage(storage).select(:group_id))
      end
    end
  end
end
