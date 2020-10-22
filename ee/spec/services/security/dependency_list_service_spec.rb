# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::DependencyListService do
  describe '#execute' do
    let!(:pipeline) { create(:ee_ci_pipeline, :with_dependency_list_report) }

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
          expect(subject.size).to eq(3)
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

      context 'sorted by desc severity' do
        let(:params) do
          {
            sort: 'desc',
            sort_by: 'severity'
          }
        end

        it 'returns array of data properly sorted' do
          nokogiri_index = subject.find_index { |dep| dep[:name] == 'nokogiri' }
          saml2js_index = subject.find_index { |dep| dep[:name] == 'saml2-js' }

          expect(nokogiri_index).to be > saml2js_index
          expect(subject).to end_with(subject[nokogiri_index])
        end
      end
    end
  end
end
