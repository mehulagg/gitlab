# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['Project'] do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }
  let_it_be(:vulnerability) { create(:vulnerability, project: project, severity: :high) }

  before do
    stub_licensed_features(security_dashboard: true)

    project.add_developer(user)
  end

  it 'includes the ee specific fields' do
    expected_fields = %w[
      vulnerabilities sast_ci_configuration vulnerability_scanners requirement_states_count
      vulnerability_severities_count packages compliance_frameworks
      security_dashboard_path iterations
    ]

    expect(described_class).to include_graphql_fields(*expected_fields)
  end

  describe 'sast_ci_configuration' do
    include_context 'read ci configuration for sast enabled project'
    let(:error_message) { "This is an error for YamlProcessor." }

    let_it_be(:query) do
      %(
        query {
            project(fullPath: "#{project.full_path}") {
                sastCiConfiguration {
                  global {
                    nodes {
                      type
                      options {
                        nodes {
                          label
                          value
                        }
                      }
                      field
                      label
                      defaultValue
                      value
                      size
                    }
                  }
                  pipeline {
                    nodes {
                      type
                      options {
                        nodes {
                          label
                          value
                        }
                      }
                      field
                      label
                      defaultValue
                      value
                      size
                    }
                  }
                  analyzers {
                    nodes {
                      name
                      label
                      enabled
                    }
                  }
                }
              }
        }
      )
    end

    before do
      allow(project.repository).to receive(:blob_data_at).and_return(gitlab_ci_yml_content)
    end

    subject { GitlabSchema.execute(query, context: { current_user: user }).as_json }

    it "returns the project's sast configuration for global variables" do
      secure_analyzers_prefix = subject.dig('data', 'project', 'sastCiConfiguration', 'global', 'nodes').first
      expect(secure_analyzers_prefix['type']).to eq('string')
      expect(secure_analyzers_prefix['field']).to eq('SECURE_ANALYZERS_PREFIX')
      expect(secure_analyzers_prefix['label']).to eq('Image prefix')
      expect(secure_analyzers_prefix['size']).to eq("MEDIUM")
      expect(secure_analyzers_prefix['defaultValue']).to eq('registry.gitlab.com/gitlab-org/security-products/analyzers')
      expect(secure_analyzers_prefix['value']).to be_nil
      expect(secure_analyzers_prefix['options']).to be_nil
    end

    it "returns the project's sast configuration for pipeline variables" do
      pipeline_stage = subject.dig('data', 'project', 'sastCiConfiguration', 'pipeline', 'nodes').first
      expect(pipeline_stage['type']).to eq('string')
      expect(pipeline_stage['field']).to eq('stage')
      expect(pipeline_stage['label']).to eq('Stage')
      expect(pipeline_stage['defaultValue']).to eq('test')
      expect(pipeline_stage['size']).to eq('MEDIUM')
      expect(pipeline_stage['value']).to be_nil
    end

    it "returns the project's sast configuration for analyzer variables" do
      analyzer = subject.dig('data', 'project', 'sastCiConfiguration', 'analyzers', 'nodes').first
      expect(analyzer['name']).to eq('brakeman')
      expect(analyzer['label']).to eq('Brakeman')
      expect(analyzer['enabled']).to eq(true)
    end

    it 'returns an error if there is an exception in YamlProcessor' do
      allow_next_instance_of(::Security::CiConfiguration::SastParserService) do |service|
        allow(service).to receive(:configuration).and_raise(::Gitlab::Ci::YamlProcessor::ValidationError.new(error_message))
      end

      expect(subject["errors"].first["message"]).to eql(error_message)
    end
  end

  describe 'security_scanners' do
    let_it_be(:project) { create(:project, :repository) }
    let_it_be(:pipeline) { create(:ci_pipeline, project: project, sha: project.commit.id, ref: project.default_branch) }
    let_it_be(:user) { create(:user) }

    let_it_be(:query) do
      %(
        query {
            project(fullPath: "#{project.full_path}") {
             securityScanners {
                   enabled
                   available
                   pipelineRun
               }
             }
       }
      )
    end

    subject { GitlabSchema.execute(query, context: { current_user: user }).as_json }

    before do
      create(:ci_build, :success, :sast, pipeline: pipeline)
      create(:ci_build, :success, :dast, pipeline: pipeline)
      create(:ci_build, :success, :license_scanning, pipeline: pipeline)
      create(:ci_build, :success, :license_management, pipeline: pipeline)
      create(:ci_build, :pending, :secret_detection, pipeline: pipeline)
    end

    it 'returns a list of analyzers enabled for the project' do
      query_result = subject.dig('data', 'project', 'securityScanners', 'enabled')
      expect(query_result).to match_array(%w(SAST DAST SECRET_DETECTION))
    end

    it 'returns a list of analyzers which were run in the last pipeline for the project' do
      query_result = subject.dig('data', 'project', 'securityScanners', 'pipelineRun')
      expect(query_result).to match_array(%w(DAST SAST))
    end
  end

  describe 'vulnerabilities' do
    let_it_be(:project) { create(:project) }
    let_it_be(:user) { create(:user) }
    let_it_be(:vulnerability) do
      create(:vulnerability, :detected, :critical, project: project, title: 'A terrible one!')
    end

    let_it_be(:query) do
      %(
        query {
          project(fullPath:"#{project.full_path}") {
            vulnerabilities {
              nodes {
                title
                severity
                state
              }
            }
          }
        }
      )
    end

    subject { GitlabSchema.execute(query, context: { current_user: user }).as_json }

    it "returns the project's vulnerabilities" do
      vulnerabilities = subject.dig('data', 'project', 'vulnerabilities', 'nodes')

      expect(vulnerabilities.count).to be(1)
      expect(vulnerabilities.first['title']).to eq('A terrible one!')
      expect(vulnerabilities.first['state']).to eq('DETECTED')
      expect(vulnerabilities.first['severity']).to eq('CRITICAL')
    end
  end
end
