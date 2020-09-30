# frozen_string_literal: true

module Gitlab
  module Vulnerabilities
    class CalculateFindingUUID
      FINDING_NAMESPACES_IDS = {
        development: "a143e9e2-41b3-47bc-9a19-081d089229f4",
        test: "a143e9e2-41b3-47bc-9a19-081d089229f4",
        production:  "58dc0f06-936c-43b3-93bb-71693f1b6570"
      }.freeze

      NAMESPACE_REGEX = /(\h{8})-(\h{4})-(\h{4})-(\h{4})-(\h{4})(\h{8})/.freeze
      PACK_PATTERN = "NnnnnN".freeze

      def self.call(value)
        Digest::UUID.uuid_v5(namespace_id, value)
      end

      def self.namespace_id
        namespace_uuid = FINDING_NAMESPACES_IDS.fetch(Rails.env.to_sym)
        # Digest::UUID is broken when using an UUID in namespace_id
        # https://github.com/rails/rails/issues/37681#issue-520718028
        namespace_uuid.scan(NAMESPACE_REGEX).flatten.map { |s| s.to_i(16) }.pack(PACK_PATTERN)
      end
    end
  end
end
