# frozen_string_literal: true
module Vulnerabilities
  class ManuallyCreateService
    include Gitlab::Allowable

    MANUAL_REPORT_TYPE = ::Enums::Vulnerability.report_types[:manual]

    def initialize(project, author, params:)
      @project = project
      @author = author
      @params = params
    end

    def execute
      raise Gitlab::Access::AccessDeniedError unless can?(@author, :create_vulnerability, @project)

      vulnerability = initialize_vulnerability(params[:vulnerability])
      identifiers = initialize_identifiers(params[:vulnerability][:identifiers])
      scanner = initialize_scanner(params[:vulnerability][:scanner])
      finding = initialize_finding(vulnerability, identifiers, scanner, params[:message])

      Vulnerability.transaction(requires_new: true) do
        vulnerability.save!
        finding.save!

        Statistics::UpdateService.update_for(vulnerability)
        HistoricalStatistics::UpdateService.update_for(@project)

        ServiceResponse.success(payload: { vulnerability: vulnerability })
      end
    rescue ActiveRecord::RecordNotUnique => e
      Gitlab::AppLogger.error(e.message)
      ServiceResponse.error(message: "Vulnerability with those details already exists")
    rescue ActiveRecord::RecordInvalid => e
      ServiceResponse.error(message: e.message)
    end

    private

    attr_reader :params

    def initialize_vulnerability(vulnerability_hash)
      Vulnerability.new(
        project: @project,
        author: @author,
        title: vulnerability_hash.dig(:name)&.truncate(::Issuable::TITLE_LENGTH_MAX),
        state: vulnerability_hash.dig(:state),
        severity: vulnerability_hash.dig(:severity),
        confidence: vulnerability_hash.dig(:confidence),
        report_type: MANUAL_REPORT_TYPE
      )
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def initialize_identifiers(identifier_hashes)
      identifier_hashes.map do |identifier|
        name = identifier.dig(:name)
        external_type = map_external_type_from_name(name)
        external_id = name
        fingerprint = Digest::SHA1.hexdigest("#{external_type}:#{external_id}")
        url = identifier.dig(:url)

        Vulnerabilities::Identifier.find_or_initialize_by(name: name) do |i|
          i.fingerprint = fingerprint
          i.project = @project
          i.external_type = external_type
          i.external_id = external_id
          i.url = url
        end
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def map_external_type_from_name(name)
      return 'cve' if name.match?(/CVE/i)
      return 'cwe' if name.match?(/CWE/i)

      'other'
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def initialize_scanner(scanner_hash)
      name = scanner_hash.dig(:name)

      Vulnerabilities::Scanner.find_or_initialize_by(name: name) do |s|
        s.project = @project
        s.external_id = Gitlab::Utils.slugify(name)
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def initialize_finding(vulnerability, identifiers, scanner, message)
      location_fingerprint = Digest::SHA1.hexdigest("manually added")
      uuid = ::Security::VulnerabilityUUID.generate(
        report_type: MANUAL_REPORT_TYPE,
        primary_identifier_fingerprint: identifiers.first.fingerprint,
        location_fingerprint: location_fingerprint,
        project_id: @project.id
      )

      Vulnerabilities::Finding.new(
        project: @project,
        identifiers: identifiers,
        primary_identifier: identifiers.first,
        vulnerability: vulnerability,
        name: vulnerability.title,
        severity: vulnerability.severity,
        confidence: vulnerability.confidence,
        report_type: vulnerability.report_type,
        project_fingerprint: Digest::SHA1.hexdigest(identifiers.first.name),
        location_fingerprint: location_fingerprint,
        metadata_version: 'manual:1.0',
        raw_metadata: {},
        scanner: scanner,
        uuid: uuid,
        message: message
      )
    end
  end
end
