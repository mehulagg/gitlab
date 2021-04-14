# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        class Scanner
          ANALYZER_ORDER = {
            "bundler_audit" => 1,
            "retire.js" =>  2,
            "gemnasium" => 3,
            "gemnasium-maven" => 3,
            "gemnasium-python" => 3,
            "bandit" => 1,
            "semgrep" =>  2
          }.freeze

          attr_accessor :external_id, :name, :vendor

          alias_method :key, :external_id

          def initialize(external_id:, name:, vendor:)
            @external_id = external_id
            @name = name
            @vendor = vendor
          end

          def to_hash
            {
              external_id: external_id.to_s,
              name: name.to_s,
              vendor: vendor.presence
            }.compact
          end

          def ==(other)
            other.external_id == external_id
          end

          def priority
            ANALYZER_ORDER.fetch(external_id, Float::INFINITY)
          end
        end
      end
    end
  end
end
