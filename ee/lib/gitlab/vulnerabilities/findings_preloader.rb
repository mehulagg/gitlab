# frozen_string_literal: true

module Gitlab
  # Preloading of Vulnerabilities Findings.
  #
  # This class can be used to efficiently preload the feedback of a given list of
  # vulnerabilities (findings).
  module Vulnerabilities
    class FindingsPreloader
      def self.preload!(findings)
        findings.all_preloaded.tap do |findings|
          preload_feedback!(findings)
        end
      end

      def self.preload_feedback!(findings)
        findings.each(&:load_feedback)
      end
    end
  end
end
