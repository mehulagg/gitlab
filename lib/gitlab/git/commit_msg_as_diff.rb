# frozen_string_literal: true

module Gitlab
  module Git
    class CommitMsgAsDiff
      # Diff properties
      attr_accessor :old_path, :new_path, :a_mode, :b_mode, :diff

      # Stats properties
      attr_accessor :new_file, :renamed_file, :deleted_file

      alias_method :new_file?, :new_file
      alias_method :deleted_file?, :deleted_file
      alias_method :renamed_file?, :renamed_file

      attr_accessor :expanded
      attr_writer :too_large

      alias_method :expanded?, :expanded

      SERIALIZE_KEYS = %i(diff new_path old_path a_mode b_mode new_file renamed_file deleted_file too_large).freeze

      class << self
        # Returns the limit of bytes a single diff file can reach before it
        # appears as 'collapsed' for end-users.
        # By convention, it's 10% of the persisted `diff_max_patch_bytes`.
        #
        # Example: If we have 100k for the `diff_max_patch_bytes`, it will be 10k by
        # default.
        #
        # Patches surpassing this limit should still be persisted in the database.
        def patch_safe_limit_bytes(limit = patch_hard_limit_bytes)
          limit / 10
        end

        # Returns the limit for a single diff file (patch).
        #
        # Patches surpassing this limit shouldn't be persisted in the database
        # and will be presented as 'too large' for end-users.
        def patch_hard_limit_bytes
          Gitlab::CurrentSettings.diff_max_patch_bytes
        end
      end

      def initialize(commit)
        @commit = commit

        @diff = commit.raw.message
        @new_path = "COMMIT_MSG"
        @old_path = "COMMIT_MSG"
        @a_mode = "0100644"
        @b_mode = "0100644"
        @new_file = true
        @renamed_file = false
        @deleted_file = false
        @too_large = false
      end

      def to_hash
        hash = {}

        SERIALIZE_KEYS.each do |key|
          hash[key] = send(key) # rubocop:disable GitlabSecurity/PublicSend
        end

        hash
      end

      def mode_changed?
        a_mode && b_mode && a_mode != b_mode
      end

      def submodule?
        a_mode == '160000' || b_mode == '160000'
      end

      def line_count
        @line_count ||= Util.count_lines(@diff)
      end

      def diff_bytesize
        @diff_bytesize ||= @diff.bytesize
      end

      def too_large?
        if @too_large.nil?
          @too_large = diff_bytesize >= self.class.patch_hard_limit_bytes
        else
          @too_large
        end
      end

      # This is used by `to_hash` and `init_from_hash`.
      alias_method :too_large, :too_large?

      def too_large!
        @diff = ''
        @line_count = 0
        @too_large = true
      end

      def collapsed?
        return @collapsed if defined?(@collapsed)

        @collapsed = !expanded && diff_bytesize >= self.class.patch_safe_limit_bytes
      end

      def collapse!
        @diff = ''
        @line_count = 0
        @collapsed = true
      end

      def json_safe_diff
        @diff
      end

      def has_binary_notice?
        false
      end
    end
  end
end
