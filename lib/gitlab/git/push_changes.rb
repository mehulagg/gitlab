module Gitlab
  module Git
    class PushChanges
      include Enumerable
      include Gitlab::Utils::StrongMemoize

      REV_LIST_CHECK_LIMIT = 2000

      attr_reader :new_rev, :repository

      def initialize(repository, new_rev)
        @repository = repository
        @new_rev = new_rev
      end

      def each(&block)
        changes.each(&block)
      end

      def size
        return 0 unless new_rev

        strong_memoize(:push_size) do
          changes.inject(0) do |total_size, (_object_id, (_blob_path, blob_size))|
            total_size + blob_size
          end
        end
      end

      private

      def changes
        strong_memoize(:changes) do
          changes = {}
          rev_list = ::Gitlab::Git::RevList.new(repository, newrev: new_rev)

          Gitlab::GitalyClient::StorageSettings.allow_disk_access do
            rev_list.new_objects(require_path: true, include_path: true) do |lazy_output|
              lazy_output.take(REV_LIST_CHECK_LIMIT).each do |object_id, path|
                type, size = repository.rugged.read_header(object_id).values_at(:type, :len)

                # git rev-list also includes Tree objects in the output so we need to filter them out.
                changes[object_id] = [path, size] if type == :blob
              end
            end
          end

          changes
        end
      end
    end
  end
end
