# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::DependencyListService do
  describe '#execute' do
    let_it_be(:pipeline) { create(:ee_ci_pipeline, :with_dependency_list_report) }
    let_it_be(:nokogiri_finding) { create(:vulnerabilities_finding, :detected, :with_dependency_scanning_metadata, :with_pipeline, raw_severity: 'High') }
    let_it_be(:nokogiri_pipeline) { create(:vulnerabilities_finding_pipeline, finding: nokogiri_finding, pipeline: pipeline) }

    let_it_be(:unknown_severity_finding) { create(:vulnerabilities_finding, :detected, :with_dependency_scanning_metadata, package: 'saml2-js', file: 'yarn/yarn.lock', version: '1.5.0', raw_severity: 'Unknown') }
    let_it_be(:medium_severity_finding) { create(:vulnerabilities_finding, :detected, :with_dependency_scanning_metadata, package: 'saml2-js', file: 'yarn/yarn.lock',  version: '1.5.0', raw_severity: 'Medium') }
    let_it_be(:critical_severity_finding) { create(:vulnerabilities_finding, :detected, :with_dependency_scanning_metadata, package: 'saml2-js', file: 'yarn/yarn.lock', version: '1.5.0', raw_severity: 'Critical') }

    let_it_be(:unknown_severity_pipeline) { create(:vulnerabilities_finding_pipeline, finding: unknown_severity_finding, pipeline: pipeline) }
    let_it_be(:medium_severity_pipeline) { create(:vulnerabilities_finding_pipeline, finding: medium_severity_finding, pipeline: pipeline) }
    let_it_be(:critical_severity_pipeline) { create(:vulnerabilities_finding_pipeline, finding: critical_severity_finding, pipeline: pipeline) }

    subject { described_class.new(pipeline: pipeline, params: params).execute }

    before do
      stub_licensed_features(dependency_scanning: true)
    end

    context 'without params' do
      let(:params) { {} }

      it 'returns array of dependencies' do
        is_expected.to be_an(Array)
      end

      it 'is sorted by names by default' do
        expect(subject.size).to eq(21)
        expect(subject.first[:name]).to eq('async')
        expect(subject.last[:name]).to eq('xpath.js')
      end
    end

    context 'with params' do
      context 'filtered by package_managers' do
        let(:params) { { package_manager: 'bundler' } }

        it 'returns filtered items' do
          expect(subject.size).to eq(2)
          expect(subject.first[:packager]).to eq('Ruby (Bundler)')
        end
      end

      context 'filtered by vulnerable' do
        let(:params) { { filter: 'vulnerable' } }

        it 'returns filtered items' do
          expect(subject.size).to eq(2)
          expect(subject.last[:vulnerabilities]).not_to be_empty
        end
      end

      context 'sorted desc by packagers' do
        let(:params) do
          {
            sort: 'desc',
            sort_by: 'packager'
          }
        end

        it 'returns array of data properly sorted' do
          expect(subject.first[:packager]).to eq('Ruby (Bundler)')
          expect(subject.last[:packager]).to eq('JavaScript (Yarn)')
        end
      end

      context 'sorted asc by packagers' do
        let(:params) do
          {
            sort: 'asc',
            sort_by: 'packager'
          }
        end

        it 'returns array of data properly sorted' do
          expect(subject.first[:packager]).to eq('JavaScript (Yarn)')
          expect(subject.last[:packager]).to eq('Ruby (Bundler)')
        end
      end

      context 'sorted desc by names' do
        let(:params) do
          {
            sort: 'desc',
            sort_by: 'name'
          }
        end

        it 'returns array of data properly sorted' do
          expect(subject.first[:name]).to eq('xpath.js')
          expect(subject.last[:name]).to eq('async')
        end
      end

      # this test ensures the dependency list severity sort order is `info, unknown, low, medium, high, critical`
      # which is asending severity order, however, the UI label for this sort order is currently `desc`.
      # TODO: change the UI label to use `asc` for this sort order and use `desc` for the default sort order
      # of `critical, high, medium, low, unknown, info`
      # See https://gitlab.com/gitlab-org/gitlab/-/issues/332653
      context 'sorted by asc severity' do
        let(:params) do
          {
            sort: 'desc',
            sort_by: 'severity'
          }
        end

        it 'returns array of data sorted by package severity level in ascending order' do
          dependencies = subject.last(2).map do |dependency|
            {
              name: dependency[:name],
              vulnerabilities: dependency[:vulnerabilities].map do |vulnerability|
                vulnerability[:severity]
              end
            }
          end

          expect(dependencies).to eq([{ name: "nokogiri", vulnerabilities: ["high"] },
                                      { name: "saml2-js", vulnerabilities: %w(critical medium unknown) }])
        end

        it 'returns array of data with package vulnerabilities sorted in descending order' do
          saml2js_dependency = subject.find { |dep| dep[:name] == 'saml2-js' }
          saml2js_severities = saml2js_dependency[:vulnerabilities].map {|v| v[:severity] }

          expect(saml2js_severities).to eq(%w(critical medium unknown))
        end
      end
    end
  end
end
