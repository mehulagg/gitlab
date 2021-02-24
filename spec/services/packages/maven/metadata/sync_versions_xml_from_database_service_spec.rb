# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Packages::Maven::Metadata::SyncVersionsXmlFromDatabaseService do
  let_it_be(:package) { create(:maven_package, version: nil) }

  let(:versions_in_database) { %w[1.3 2.0-SNAPSHOT 1.6 1.4 1.5-SNAPSHOT] }
  let(:versions_in_xml) { %w[1.3 2.0-SNAPSHOT 1.6 1.4 1.5-SNAPSHOT] }
  let(:version_latest) { nil }
  let(:version_release) { '1.4' }
  let(:service) { described_class.new(metadata_content: metadata_xml, package: package) }

  describe '#execute' do
    subject { service.execute }

    before do
      next unless package

      versions_in_database.each do |version|
        create(:maven_package, name: package.name, version: version, project: package.project)
      end
    end

    shared_examples 'returning an xml with versions in the database' do
      it 'returns an metadata versions xml with versions in the database' do
        result = subject

        expect(result).to be_success
        expect(versions_from(result.payload[:metadata_content])).to match_array(versions_in_database)
      end
    end

    shared_examples 'returning an xml with' do |release:, latest:|
      it 'returns an xml with the updated release and latest versions' do
        result = subject

        expect(result).to be_success
        xml = result.payload[:metadata_content]
        expect(release_from(xml)).to eq(release)
        expect(latest_from(xml)).to eq(latest)
      end
    end

    context 'with same versions in both sides' do
      it 'returns no changes' do
        result = subject

        expect(result).to be_success
        expect(result.payload).to eq(changes_exist: false)
      end
    end

    context 'with more versions' do
      let(:additional_versions) { %w[5.5 5.6 5.7-SNAPSHOT] }

      context 'in the xml side' do
        let(:versions_in_xml) { versions_in_database + additional_versions }

        it_behaves_like 'returning an xml with versions in the database'
      end

      context 'in the database side' do
        let(:versions_in_database) { versions_in_xml + additional_versions }

        it_behaves_like 'returning an xml with versions in the database'
      end
    end

    context 'with differences in both sides' do
      let(:shared_versions) { %w[1.3 2.0-SNAPSHOT 1.6 1.4 1.5-SNAPSHOT] }
      let(:additional_versions_in_xml) { %w[5.5 5.6 5.7-SNAPSHOT] }
      let(:versions_in_xml) { shared_versions + additional_versions_in_xml }
      let(:additional_versions_in_database) { %w[6.5 6.6 6.7-SNAPSHOT] }
      let(:versions_in_database) { shared_versions + additional_versions_in_database }

      it_behaves_like 'returning an xml with versions in the database'
    end

    context 'with a new release and latest from the database' do
      let(:versions_in_database) { versions_in_xml + %w[4.1 4.2-SNAPSHOT] }

      it_behaves_like 'returning an xml with', release: '4.1', latest: nil

      context 'with a latest in the xml' do
        let(:version_latest) { '1.6' }

        it_behaves_like 'returning an xml with', release: '4.1', latest: '4.2-SNAPSHOT'
      end
    end

    context 'with addition versions in the database side no more recent than release' do
      let(:versions_in_database) { versions_in_xml + %w[4.1 4.2-SNAPSHOT] }

      before do
        ::Packages::Package.find_by(name: package.name, version: '4.1').update!(created_at: 2.weeks.ago)
        ::Packages::Package.find_by(name: package.name, version: '4.2-SNAPSHOT').update!(created_at: 2.weeks.ago)
      end

      it_behaves_like 'returning an xml with', release: '1.4', latest: nil

      context 'with a latest in the xml' do
        let(:version_latest) { '1.6' }

        it_behaves_like 'returning an xml with', release: '1.4', latest: '1.5-SNAPSHOT'
      end
    end

    context 'last updated timestamp' do
      let(:versions_in_database) { versions_in_xml + %w[4.1 4.2-SNAPSHOT] }

      it 'updates the last updated timestamp' do
        original = last_updated_from(metadata_xml)

        result = subject

        expect(result).to be_success
        expect(original).not_to eq(last_updated_from(result.payload[:metadata_content]))
      end
    end

    context 'with an incomplete metadata content' do
      let(:metadata_xml) { '<metadata></metadata>' }

      it_behaves_like 'returning an error service response', message: 'metadata_content is invalid'
    end

    context 'with an invalid metadata content' do
      let(:metadata_xml) { '<meta></metadata>' }

      it_behaves_like 'returning an error service response', message: 'metadata_content is invalid'
    end

    context 'with no package' do
      let(:metadata_xml) { '' }
      let(:package) { nil }

      it_behaves_like 'returning an error service response', message: 'package not set'
    end

    context 'with no metadata content' do
      let(:metadata_xml) { nil }

      it_behaves_like 'returning an error service response', message: 'metadata_content not set'
    end
  end

  def metadata_xml
    metadata_versioning = {
      'release' => version_release,
      'lastUpdated' => '20210113130531',
      'versions' => versions_in_xml
    }

    metadata_versioning['latest'] = version_latest if version_latest

    metadata = {
      'groupId' => package.maven_metadatum.app_group,
      'artifactdId' => package.maven_metadatum.app_name,
      'versioning' => metadata_versioning
    }
    metadata.to_xml(root: 'metadata')
  end

  def versions_from(xml_content)
    doc = Nokogiri::XML(xml_content)
    doc.xpath('//metadata/versioning/versions/version').map(&:content)
  end

  def release_from(xml_content)
    doc = Nokogiri::XML(xml_content)
    doc.xpath('//metadata/versioning/release').first.content
  end

  def latest_from(xml_content)
    doc = Nokogiri::XML(xml_content)
    doc.xpath('//metadata/versioning/latest').first&.content
  end

  def last_updated_from(xml_content)
    doc = Nokogiri::XML(xml_content)
    doc.xpath('//metadata/versioning/lastUpdated').first.content
  end
end
