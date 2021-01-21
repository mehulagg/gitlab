# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module LicenseCompliance
        class V1
          attr_reader :report

          def initialize(report)
            @report = report
          end

          def parse(json)
            json.fetch(:dependencies, []).each do |dependency|
              each_license_for(dependency) do |license_hash|
                license = report.add_license(id: nil, name: license_hash[:name], url: license_hash[:url])
                license.add_dependency(name: dependency[:dependency][:name])
              end
            end
          end

          private

          def each_license_for(dependency)
            if dependency.key?(:licenses)
              dependency[:licenses].each do |license|
                yield license
              end
            else
              dependency[:license][:name].split(',').each do |name|
                yield(name: remove_suffix(name.strip), url: dependency.dig(:license, :url))
              end
            end
          end

          def remove_suffix(name)
            name.gsub(/-or-later$|-only$|\+$/, '')
          end
        end
      end
    end
  end
end
