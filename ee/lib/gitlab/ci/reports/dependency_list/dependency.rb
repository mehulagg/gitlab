# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module DependencyList
        class Dependency
          attr_reader :name, :packager, :package_manager, :location, :version, :licenses, :vulnerabilities

          def initialize(params = {})
            @name = params.fetch(:name)
            @packager = params.fetch(:packager)
            @package_manager = params.fetch(:package_manager)
            @location = params.fetch(:location)
            @version = params.fetch(:version)
            @licenses = params.fetch(:licenses)
            @vulnerabilities = unique_vulnerabilities(params.fetch(:vulnerabilities, []))
          end

          def update_dependency(dependency)
            if self.packager.empty? && !dependency.fetch(:packager).empty?
              @packager = dependency.fetch(:packager)
            end

            new_vulns = dependency.fetch(:vulnerabilities)
            new_vulns.each { |v| add_vulnerability(v) }
          end

          def composite_key
            data = [self.name, self.version, self.location.fetch(:path)].compact.join
            Digest::SHA2.hexdigest(data)
          end

          def to_hash
            {
              name: self.name,
              packager: self.packager,
              package_manager: self.package_manager,
              location: self.location,
              version: self.version,
              licenses: self.licenses,
              vulnerabilities: self.vulnerabilities.to_a.map(&:to_hash)
            }
          end

          private

          def add_vulnerability(vulnerability)
            return if vulnerability.empty?

            @vulnerabilities.add(Vulnerability.new(vulnerability))
          end

          def unique_vulnerabilities(vulnerabilities)
            return Set.new if vulnerabilities.empty?

            unique_vulnerabilities = Set.new
            vulnerabilities.each do |v|
              next if v.empty?

              unique_vulnerabilities.add(Vulnerability.new(v))
            end

            unique_vulnerabilities
          end
        end
      end
    end
  end
end
