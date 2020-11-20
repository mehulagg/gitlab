# frozen_string_literal: true

module MergeRequests
  class UpdateBlocksService
    include ::Gitlab::Allowable
    include ::Gitlab::Utils::StrongMemoize

    class << self
      def extract_params!(mutable_params)
        {
          update: mutable_params.delete(:update_blocking_merge_request_refs),
          remove_hidden: mutable_params.delete(:remove_hidden_blocking_merge_requests),
          references: mutable_params.delete(:blocking_merge_request_references)
        }
      end
    end

    attr_reader :merge_request, :current_user, :params

    def initialize(merge_request, current_user, params = {})
      @merge_request = merge_request
      @current_user = current_user
      @params = params

      DeclarativePolicy.user_scope do
        @visible_blocks, @hidden_blocks = merge_request.blocks_as_blockee.partition do |block|
          can?(current_user, :read_merge_request, block.blocking_merge_request)
        end
      end
    end

    def execute
      return unless update?
      return unless merge_request.target_project.feature_available?(:blocking_merge_requests)

      merge_request
        .blocks_as_blockee
        .with_blocking_mr_ids(ids_to_del)
        .delete_all

      # If the block is invalid, silently fail to add it
      ids_to_add.each do |blocking_id|
        blocked = ::MergeRequestBlock.create(
          blocking_merge_request_id: blocking_id,
          blocked_merge_request_id: merge_request.id
        )

        unless blocked.persisted?
          merge_request.errors.merge!(blocked.errors)
        end
      end

      if invalid_references.present?
        merge_request.errors.add(:dependencies, 'failed to save: ' + invalid_references.join(", "))
      end

      true
    end

    private

    attr_reader :visible_blocks, :hidden_blocks, :invalid_references

    def update?
      params.fetch(:update, false)
    end

    def remove_hidden?
      params.fetch(:remove_hidden, false)
    end

    def references
      params.fetch(:references, [])
    end

    def requested_ids
      strong_memoize(:requested_ids) do
        next [] unless references.present?

        # The analyzer will only return references the current user can see
        @invalid_references = []
        re_references = []

        references.each do |reference|
          analyzer = ::Gitlab::ReferenceExtractor.new(merge_request.target_project, current_user)
          analyzer.analyze(reference)

          if analyzer.merge_requests.count >= 1
            re_references << analyzer.merge_requests
          else
            @invalid_references << reference
          end
        end

        re_references.flatten.map(&:id)
      end
    end

    def visible_ids
      strong_memoize(:visible_ids) { visible_blocks.map(&:blocking_merge_request_id) }
    end

    def hidden_ids
      strong_memoize(:hidden_ids) { hidden_blocks.map(&:blocking_merge_request_id) }
    end

    def ids_to_add
      strong_memoize(:ids_to_add) { requested_ids - visible_ids }
    end

    def ids_to_del
      strong_memoize(:ids_to_del) do
        (visible_ids - requested_ids).tap do |ary|
          ary.push(*hidden_ids) if remove_hidden?
        end
      end
    end
  end
end
