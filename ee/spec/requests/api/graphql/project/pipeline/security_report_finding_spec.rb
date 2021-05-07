# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Query.project(fullPath).pipeline(iid).securityReportFindings' do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:pipeline) { create(:ci_pipeline, :success, project: project) }
  let_it_be(:user) { create(:user) }

  before_all do
    create(:ci_build, :success, name: 'dast_job', pipeline: pipeline, project: project) do |job|
      create(:ee_ci_job_artifact, :dast_large_scanned_resources_field, job: job, project: project)
    end
    create(:ci_build, :success, name: 'sast_job', pipeline: pipeline, project: project) do |job|
      create(:ee_ci_job_artifact, :sast, job: job, project: project)
    end
  end

  let_it_be(:query) do
    %(
      query {
        project(fullPath: "#{project.full_path}") {
          pipeline(iid: "#{pipeline.iid}") {
            securityReportFindings(reportType: ["sast", "dast"]) {
              nodes {
                confidence
                severity
                reportType
                name
                scanner {
                  name
                }
                projectFingerprint
                identifiers {
                  name
                }
                uuid
                solution
                description
                project {
                  fullPath
                  visibility
                }
              }
            }
          }
        }
      }
    )
  end

  subject { GitlabSchema.execute(query, context: { current_user: user }).as_json }

  let(:security_report_findings) { subject.dig('data', 'project', 'pipeline', 'securityReportFindings', 'nodes') }

  context 'when `sast` and `dast` features are enabled' do
    before do
      stub_licensed_features(sast: true, dast: true)
    end

    context 'when user is member of the project' do
      before do
        project.add_developer(user)
      end

      it 'returns all the vulnerability findings' do
        expect(security_report_findings.length).to eq(25)
      end

      it 'returns all the queried fields', :aggregate_failures do
        security_report_finding = security_report_findings.first

        expect(security_report_finding.dig('project', 'fullPath')).to eq(project.full_path)
        expect(security_report_finding.dig('project', 'visibility')).to eq(project.visibility)
        expect(security_report_finding['identifiers'].length).to eq(3)
        expect(security_report_finding['confidence']).not_to be_nil
        expect(security_report_finding['severity']).not_to be_nil
        expect(security_report_finding['reportType']).not_to be_nil
        expect(security_report_finding['name']).not_to be_nil
        expect(security_report_finding['projectFingerprint']).not_to be_nil
        expect(security_report_finding['uuid']).not_to be_nil
        expect(security_report_finding['solution']).not_to be_nil
        expect(security_report_finding['description']).not_to be_nil
      end
    end

    context 'when user is not a member of the project' do
      it 'returns no vulnerability findings' do
        expect(security_report_findings).to be_nil
      end
    end
  end

  context 'when `sast` and `dast` both features are disabled' do
    before do
      stub_licensed_features(sast: false, dast: false)
    end

    it 'returns no vulnerability findings' do
      expect(security_report_findings).to be_nil
    end
  end
end
