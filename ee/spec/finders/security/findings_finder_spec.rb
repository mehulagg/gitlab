# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::FindingsFinder do
  let_it_be(:pipeline) { create(:ci_pipeline) }
  let_it_be(:build_ds) { create(:ci_build, :success, name: 'dependency_scanning', pipeline: pipeline) }
  let_it_be(:build_sast) { create(:ci_build, :success, name: 'sast', pipeline: pipeline) }
  let_it_be(:artifact_ds) { create(:ee_ci_job_artifact, :dependency_scanning, job: build_ds) }
  let_it_be(:artifact_sast) { create(:ee_ci_job_artifact, :sast, job: build_sast) }
  let_it_be(:report_ds) { create(:ci_reports_security_report, type: :dependency_scanning) }
  let_it_be(:report_sast) { create(:ci_reports_security_report, type: :sast) }

  let(:severity_levels) { nil }
  let(:confidence_levels) { nil }
  let(:report_types) { nil }
  let(:scope) { nil }
  let(:page) { nil }
  let(:per_page) { nil }
  let(:service_object) { described_class.new(pipeline, params: params) }
  let(:params) do
    {
      severity: severity_levels,
      confidence: confidence_levels,
      report_type: report_types,
      scope: scope,
      page: page,
      per_page: per_page
    }
  end

  describe '#execute' do
    context 'when the pipeline does not have security findings' do
      subject { service_object.execute }

      it { is_expected.to be_nil }
    end

    context 'when the pipeline has security findings' do
      let(:finder_result) { service_object.execute }

      before(:all) do
        ds_content = File.read(artifact_ds.file.path)
        Gitlab::Ci::Parsers::Security::DependencyScanning.parse!(ds_content, report_ds)
        report_ds.merge!(report_ds)
        sast_content = File.read(artifact_sast.file.path)
        Gitlab::Ci::Parsers::Security::Sast.parse!(sast_content, report_sast)
        report_sast.merge!(report_sast)

        { artifact_ds => report_ds, artifact_sast => report_sast }.each do |artifact, report|
          scan = create(:security_scan, scan_type: artifact.job.name, build: artifact.job)

          report.findings.each_with_index do |finding, index|
            create(:security_finding,
                   severity: finding.severity,
                   confidence: finding.confidence,
                   project_fingerprint: finding.project_fingerprint,
                   deduplicated: true,
                   position: index,
                   scan: scan)
          end
        end

        Security::Finding.by_project_fingerprints('204732fd9e78053dee33a0cad08930c129da197d')
                         .update_all(deduplicated: false)

        create(:vulnerability_feedback,
               :dismissal,
               project: pipeline.project,
               category: :sast,
               project_fingerprint: 'db759283b7fb13eae48a3f60db4c7506cdab8f26')
      end

      before do
        stub_licensed_features(sast: true, dependency_scanning: true)
      end

      it 'does not cause N+1 queries' do
        expect { finder_result }.not_to exceed_query_limit(8)
      end

      describe '#current_page' do
        subject { finder_result.current_page }

        context 'when the page is not provided' do
          it { is_expected.to be(1) }
        end

        context 'when the page is provided' do
          let(:page) { 2 }

          it { is_expected.to be(2) }
        end
      end

      describe '#limit_value' do
        subject { finder_result.limit_value }

        context 'when the per_page is not provided' do
          it { is_expected.to be(20) }
        end

        context 'when the per_page is provided' do
          let(:per_page) { 100 }

          it { is_expected.to be(100) }
        end
      end

      describe '#total_pages' do
        subject { finder_result.total_pages }

        context 'when the per_page is not provided' do
          it { is_expected.to be(2) }
        end

        context 'when the per_page is provided' do
          let(:per_page) { 100 }

          it { is_expected.to be(1) }
        end
      end

      describe '#total_count' do
        subject { finder_result.total_count }

        context 'when the scope is not provided' do
          it { is_expected.to be(35) }
        end

        context 'when the scope is provided as `all`' do
          let(:scope) { 'all' }

          it { is_expected.to be(36) }
        end
      end

      describe '#next_page' do
        subject { finder_result.next_page }

        context 'when the page is not provided' do
          it { is_expected.to be(2) }
        end

        context 'when the page is provided' do
          let(:page) { 2 }

          it { is_expected.to be_nil }
        end
      end

      describe '#prev_page' do
        subject { finder_result.prev_page }

        context 'when the page is not provided' do
          it { is_expected.to be_nil }
        end

        context 'when the page is provided' do
          let(:page) { 2 }

          it { is_expected.to be(1) }
        end
      end

      describe '#findings' do
        subject { finder_result.findings.map(&:project_fingerprint) }

        context 'with the default parameters' do
          let(:expected_fingerprints) do
            %w[
              4ae096451135db224b9e16818baaca8096896522
              0bfcfbb70b15a7cecef9a1ea39df15ecfd88949f
              117590fc6b3841014366f335f494d1aa36ce7b46
              8fac98c156431a8bdb7a69a935cc564c314ab776
              95566733fc91301623055363a77124410592af7e
              0314c9673160662292cfab1af6dc5c880fb73717
              4e44f4045e2a27d147d08895acf8df502f440f96
              b5f82291ed084fe134af5a9b90a8078ab802a6cc
              98366a28fa80b23a1dafe2b36e239a04909495c4
              b9c0d1cdc7cb9c180ebb6981abbddc2df0172509
              cefacf9f36c487d04f33c59f22e6c402bff5300a
              d533c3a12403b6c6033a50b53f9c73f894a40fc6
              92c7bdc63a9908bddbc5b66c95e93e99a1927879
              dd482eab94e695ae85c1a883c4dbe4c74a7e6b2c
              be6f6e4fb5bdfd8819e70d930b32798b38a361e0
              f603dd8517800823df02a8f1e5621b56c00710d8
              21b17b6ced16fe507dd5b71bca24f0515d04fb7e
              f1dde46676cd2a8e48f0837e5dae77087419b09c
              fec8863c5c1b4ed58eddf7722a9f1598af3aca70
              e325e114daf41074d41d1ebe1869158c4f7594dc
            ]
          end

          it { is_expected.to match_array(expected_fingerprints) }
        end

        context 'when the page is provided' do
          let(:page) { 2 }
          let(:expected_fingerprints) do
            %w[
              51026f8933c463b316c5bc33adb462e4a6f6cff2
              45cb4c0323b0b4a1adcb66fa1d0684d53e15cc27
              48f71ab14afcf0f497fb238dc4289294b93873b0
              18fe6882cdac0f3eac7784a33c9daf20109010ce
              2cae57e97785a8aef9ae4ed947093d6a908bcc52
              857969b55ba97d5e1c06ab920b470b009c2f3274
              e3b452f63d8979e6f3e4839c6ec14b62917758e4
              63dfc168b8c01a446088c9b8cf68a7d4a2a0013b
              7b0792ce8db4e2cb74083490e6a87176accea102
              30ab265fb9e816976b740beb0557ca79e8653bb6
              81a3b7c4885e64f9013ac904bf118a05bcb7732d
              ecd3b645971fc2682f5cb23d938037c6f072207f
              55c41a63d2c9c3ea243b9f9cd3254d68fbee2b6b
              3204893d5894c74aaee86ce5bc28427f9f14e512
              157f362acf654c60e224400f59a088e1c01b369f
            ]
          end

          it { is_expected.to match_array(expected_fingerprints) }
        end

        context 'when the per_page is provided' do
          let(:per_page) { 40 }
          let(:expected_fingerprints) do
            %w[
              3204893d5894c74aaee86ce5bc28427f9f14e512
              157f362acf654c60e224400f59a088e1c01b369f
              4ae096451135db224b9e16818baaca8096896522
              d533c3a12403b6c6033a50b53f9c73f894a40fc6
              b9c0d1cdc7cb9c180ebb6981abbddc2df0172509
              98366a28fa80b23a1dafe2b36e239a04909495c4
              b5f82291ed084fe134af5a9b90a8078ab802a6cc
              4e44f4045e2a27d147d08895acf8df502f440f96
              8fac98c156431a8bdb7a69a935cc564c314ab776
              95566733fc91301623055363a77124410592af7e
              0314c9673160662292cfab1af6dc5c880fb73717
              117590fc6b3841014366f335f494d1aa36ce7b46
              0bfcfbb70b15a7cecef9a1ea39df15ecfd88949f
              92c7bdc63a9908bddbc5b66c95e93e99a1927879
              cefacf9f36c487d04f33c59f22e6c402bff5300a
              dd482eab94e695ae85c1a883c4dbe4c74a7e6b2c
              48f71ab14afcf0f497fb238dc4289294b93873b0
              45cb4c0323b0b4a1adcb66fa1d0684d53e15cc27
              e3b452f63d8979e6f3e4839c6ec14b62917758e4
              857969b55ba97d5e1c06ab920b470b009c2f3274
              63dfc168b8c01a446088c9b8cf68a7d4a2a0013b
              7b0792ce8db4e2cb74083490e6a87176accea102
              2cae57e97785a8aef9ae4ed947093d6a908bcc52
              18fe6882cdac0f3eac7784a33c9daf20109010ce
              e325e114daf41074d41d1ebe1869158c4f7594dc
              51026f8933c463b316c5bc33adb462e4a6f6cff2
              fec8863c5c1b4ed58eddf7722a9f1598af3aca70
              f1dde46676cd2a8e48f0837e5dae77087419b09c
              21b17b6ced16fe507dd5b71bca24f0515d04fb7e
              be6f6e4fb5bdfd8819e70d930b32798b38a361e0
              f603dd8517800823df02a8f1e5621b56c00710d8
              30ab265fb9e816976b740beb0557ca79e8653bb6
              81a3b7c4885e64f9013ac904bf118a05bcb7732d
              55c41a63d2c9c3ea243b9f9cd3254d68fbee2b6b
              ecd3b645971fc2682f5cb23d938037c6f072207f
            ]
          end

          it { is_expected.to match_array(expected_fingerprints) }
        end

        context 'when the `severity_levels` is provided' do
          let(:severity_levels) { [:medium] }
          let(:expected_fingerprints) do
            %w[
              b5f82291ed084fe134af5a9b90a8078ab802a6cc
              4e44f4045e2a27d147d08895acf8df502f440f96
              8fac98c156431a8bdb7a69a935cc564c314ab776
              95566733fc91301623055363a77124410592af7e
              0314c9673160662292cfab1af6dc5c880fb73717
              117590fc6b3841014366f335f494d1aa36ce7b46
              0bfcfbb70b15a7cecef9a1ea39df15ecfd88949f
              d533c3a12403b6c6033a50b53f9c73f894a40fc6
              b9c0d1cdc7cb9c180ebb6981abbddc2df0172509
              98366a28fa80b23a1dafe2b36e239a04909495c4
              92c7bdc63a9908bddbc5b66c95e93e99a1927879
              cefacf9f36c487d04f33c59f22e6c402bff5300a
            ]
          end

          it { is_expected.to match_array(expected_fingerprints) }
        end

        context 'when the `confidence_levels` is provided' do
          let(:confidence_levels) { [:low] }
          let(:expected_fingerprints) do
            %w[
              30ab265fb9e816976b740beb0557ca79e8653bb6
              81a3b7c4885e64f9013ac904bf118a05bcb7732d
              55c41a63d2c9c3ea243b9f9cd3254d68fbee2b6b
              ecd3b645971fc2682f5cb23d938037c6f072207f
            ]
          end

          it { is_expected.to match_array(expected_fingerprints) }
        end

        context 'when the `report_types` is provided' do
          let(:report_types) { :dependency_scanning }
          let(:expected_fingerprints) do
            %w[
              3204893d5894c74aaee86ce5bc28427f9f14e512
              157f362acf654c60e224400f59a088e1c01b369f
              4ae096451135db224b9e16818baaca8096896522
            ]
          end

          it { is_expected.to match_array(expected_fingerprints) }
        end

        context 'when the `scope` is provided as `all`' do
          let(:scope) { 'all' }

          let(:expected_fingerprints) do
            %w[
              4ae096451135db224b9e16818baaca8096896522
              0bfcfbb70b15a7cecef9a1ea39df15ecfd88949f
              117590fc6b3841014366f335f494d1aa36ce7b46
              8fac98c156431a8bdb7a69a935cc564c314ab776
              95566733fc91301623055363a77124410592af7e
              0314c9673160662292cfab1af6dc5c880fb73717
              4e44f4045e2a27d147d08895acf8df502f440f96
              b5f82291ed084fe134af5a9b90a8078ab802a6cc
              98366a28fa80b23a1dafe2b36e239a04909495c4
              b9c0d1cdc7cb9c180ebb6981abbddc2df0172509
              cefacf9f36c487d04f33c59f22e6c402bff5300a
              d533c3a12403b6c6033a50b53f9c73f894a40fc6
              92c7bdc63a9908bddbc5b66c95e93e99a1927879
              dd482eab94e695ae85c1a883c4dbe4c74a7e6b2c
              be6f6e4fb5bdfd8819e70d930b32798b38a361e0
              f603dd8517800823df02a8f1e5621b56c00710d8
              db759283b7fb13eae48a3f60db4c7506cdab8f26
              21b17b6ced16fe507dd5b71bca24f0515d04fb7e
              f1dde46676cd2a8e48f0837e5dae77087419b09c
              fec8863c5c1b4ed58eddf7722a9f1598af3aca70
            ]
          end

          it { is_expected.to match_array(expected_fingerprints) }
        end
      end
    end
  end
end
