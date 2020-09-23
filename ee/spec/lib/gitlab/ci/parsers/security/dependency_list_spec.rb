# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Ci::Parsers::Security::DependencyList do
  let(:parser) { described_class.new(project, sha) }
  let(:project) { create(:project) }
  let(:sha) { '4242424242424242' }
  let(:report) { Gitlab::Ci::Reports::DependencyList::Report.new }

  describe '#parse!' do
    before do
      artifact.each_blob do |blob|
        parser.parse!(blob, report)
      end
    end

    context 'with dependency_list artifact' do
      let(:artifact) { create(:ee_ci_job_artifact, :dependency_list) }

      it 'parses all files' do
        blob_path = "/#{project.full_path}/-/blob/#{sha}/yarn/yarn.lock"

        expect(report.dependencies.size).to eq(21)
        expect(report.dependencies[0][:name]).to eq('mini_portile2')
        expect(report.dependencies[0][:version]).to eq('2.2.0')
        expect(report.dependencies[0][:packager]).to eq('Ruby (Bundler)')
        expect(report.dependencies[12][:packager]).to eq('JavaScript (Yarn)')
        expect(report.dependencies[0][:location][:path]).to eq('rails/Gemfile.lock')
        expect(report.dependencies[12][:location][:blob_path]).to eq(blob_path)
      end

      it 'merge vulnerabilities data' do
        vuln_nokogiri = report.dependencies[1][:vulnerabilities]
        vuln_debug = report.dependencies[4][:vulnerabilities]
        vuln_async = report.dependencies[3][:vulnerabilities]

        expect(vuln_nokogiri.size).to eq(4)
        expect(vuln_nokogiri[0][:name]).to eq('Vulnerabilities in libxml2 in nokogiri')
        expect(vuln_nokogiri[0][:severity]).to eq('high')
        expect(vuln_debug.size).to eq(1)
        expect(vuln_debug[0][:name]).to eq('Regular Expression Denial of Service in debug')
        expect(vuln_async.size).to eq(0)
      end
    end

    context 'with dependency scanning artifact without dependency_list' do
      let(:artifact) { create(:ee_ci_job_artifact, :dependency_scanning) }

      it 'list of dependencies with vulnerabilities' do
        expect(report.dependencies.size).to eq(4)
      end
    end
  end

  describe '#parse_licenses!' do
    let(:artifact) { create(:ee_ci_job_artifact, :license_management) }
    let(:dependency_info) { build(:dependency, :nokogiri, :with_vulnerabilities) }

    before do
      report.add_dependency(dependency)

      artifact.each_blob do |blob|
        parser.parse_licenses!(blob, report)
      end
    end

    context 'with existing license' do
      let(:dependency) { dependency_info }

      it 'apply license to dependency' do
        licenses = report.dependencies.last[:licenses]

        expect(licenses.count).to eq(1)
        expect(licenses[0][:name]).to eq('MIT')
        expect(licenses[0][:url]).to eq('http://opensource.org/licenses/mit-license')
      end
    end

    context 'without existing license' do
      let(:dependency) { dependency_info.merge(name: 'irigokon') }

      it 'does not apply any license if name mismatch' do
        expect(report.dependencies.first[:licenses]).to be_empty
      end
    end
  end
end
