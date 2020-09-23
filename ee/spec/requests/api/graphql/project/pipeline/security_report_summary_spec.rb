# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Query.project(fullPath).pipeline(iid).securityReportSummary' do
  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:pipeline) { create(:ci_pipeline, :success, project: project) }
  let_it_be(:user) { create(:user) }

  before_all do
    create(:ci_build, :success, name: 'dast_job', pipeline: pipeline, project: project) do |job|
      create(:ee_ci_job_artifact, :dast_large_scanned_resources_field, job: job, project: project)
      create(:security_scan, scan_type: 'dast', scanned_resources_count: 26, build: job)
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
            securityReportSummary {
              dast {
                scannedResourcesCount
                vulnerabilitiesCount
                scannedResources {
                  nodes {
                    url
                    requestMethod
                  }
                }
              }
              sast {
                vulnerabilitiesCount
              }
            }
          }
        }
      }
    )
  end

  before do
    stub_licensed_features(sast: true, dependency_scanning: true, container_scanning: true, dast: true)
    project.add_developer(user)
  end

  subject { GitlabSchema.execute(query, context: { current_user: user }).as_json }

  let(:security_report_summary) { subject.dig('data', 'project', 'pipeline', 'securityReportSummary') }

  it 'shows the vulnerabilitiesCount and scannedResourcesCount' do
    expect(security_report_summary.dig('dast', 'vulnerabilitiesCount')).to eq(20)
    expect(security_report_summary.dig('dast', 'scannedResourcesCount')).to eq(26)
    expect(security_report_summary.dig('sast', 'vulnerabilitiesCount')).to eq(33)
  end

  it 'shows the first 20 scanned resources' do
    dast_scanned_resources = security_report_summary.dig('dast', 'scannedResources', 'nodes')

    expect(dast_scanned_resources.length).to eq(20)
  end

  it 'returns nil for the scannedResourcesCsvPath' do
    expect(security_report_summary.dig('dast', 'scannedResourcesCsvPath')).to be_nil
  end
end
