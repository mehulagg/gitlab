# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        class Remediation
          attr_reader :summary, :diff

          def initialize(summary:, diff:)
            @summary = summary
            @diff = diff
          end

          def diff_file
            @diff_file ||= Tempfile.new.tap { |file| file.write(diff) && file.rewind }
          end

          def checksum
            @checksum ||= Digest::SHA256.hexdigest(diff.to_s)
          end
        end
      end
    end
  end
end
