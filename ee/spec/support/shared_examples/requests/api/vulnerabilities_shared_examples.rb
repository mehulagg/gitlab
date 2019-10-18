# frozen_string_literal: true

shared_examples 'forbids access to project vulnerabilities endpoint in expected cases' do
  context 'with authorized user without read permissions' do
    before do
      project.add_reporter(user)
    end

    it 'responds with 403 Forbidden' do
      get api(project_vulnerabilities_path, user)

      expect(response).to have_gitlab_http_status(403)
    end
  end

  context 'with authorized user but when security dashboard is not available' do
    before do
      project.add_developer(user)
      stub_licensed_features(security_dashboard: false)
    end

    it 'responds with 403 Forbidden' do
      get api(project_vulnerabilities_path, user)

      expect(response).to have_gitlab_http_status(403)
    end
  end

  context 'with no project access' do
    let(:project) { create(:project) }

    it 'responds with 404 Not Found' do
      get api(project_vulnerabilities_path, user)

      expect(response).to have_gitlab_http_status(404)
    end
  end

  context 'with unknown project' do
    before do
      project.id = 0
    end

    let(:project) { build(:project) }

    it 'responds with 404 Not Found' do
      get api(project_vulnerabilities_path, user)

      expect(response).to have_gitlab_http_status(404)
    end
  end
end

shared_examples 'getting list of vulnerability findings' do
  before do
    stub_licensed_features(security_dashboard: true, sast: true, dependency_scanning: true, container_scanning: true)

    create(:ee_ci_job_artifact, :dependency_scanning, job: build_ds, project: project)
    create(:ee_ci_job_artifact, :sast, job: build_sast, project: project)
    dismissal
  end

  let(:pipeline) { create(:ci_empty_pipeline, status: :created, project: project) }
  let(:pipeline_without_vulnerabilities) { create(:ci_pipeline_without_jobs, status: :created, project: project) }

  let(:build_ds) { create(:ci_build, :success, name: 'ds_job', pipeline: pipeline, project: project) }
  let(:build_sast) { create(:ci_build, :success, name: 'sast_job', pipeline: pipeline, project: project) }

  let(:ds_report) { pipeline.security_reports.reports["dependency_scanning"] }
  let(:sast_report) { pipeline.security_reports.reports["sast"] }

  let(:dismissal) do
    create(:vulnerability_feedback, :dismissal, :sast,
           project: project,
           pipeline: pipeline,
           project_fingerprint: sast_report.occurrences.first.project_fingerprint,
           vulnerability_data: sast_report.occurrences.first.raw_metadata
    )
  end

  context 'with an authorized user with proper permissions' do
    before do
      project.add_developer(user)
    end

    # Because fixture reports that power :ee_ci_job_artifact factory contain long report lists,
    # we need to make sure that all occurrences for both SAST and Dependency Scanning are included in the response.
    # That's why the page size is 40.
    let(:pagination) { { per_page: 40 } }

    it 'returns all non-dismissed vulnerabilities' do
      # all occurrences except one that was dismissed
      occurrence_count = (sast_report.occurrences.count + ds_report.occurrences.count - 1).to_s

      get api(project_vulnerabilities_path, user), params: pagination

      expect(response).to have_gitlab_http_status(200)
      expect(response).to include_pagination_headers
      expect(response).to match_response_schema('vulnerabilities/occurrence_list', dir: 'ee')

      expect(response.headers['X-Total']).to eq occurrence_count

      expect(json_response.map { |v| v['report_type'] }.uniq).to match_array %w[dependency_scanning sast]
    end

    it 'does not have N+1 queries' do
      control_count = ActiveRecord::QueryRecorder.new do
        get api(project_vulnerabilities_path, user), params: { report_type: 'dependency_scanning' }
      end.count

      expect { get api(project_vulnerabilities_path, user) }.not_to exceed_query_limit(control_count)
    end

    describe 'filtering' do
      it 'returns vulnerabilities with sast report_type' do
        occurrence_count = (sast_report.occurrences.count - 1).to_s # all SAST occurrences except one that was dismissed

        get api(project_vulnerabilities_path, user), params: { report_type: 'sast' }

        expect(response).to have_gitlab_http_status(200)

        expect(response.headers['X-Total']).to eq occurrence_count

        expect(json_response.map { |v| v['report_type'] }.uniq).to match_array %w[sast]

        # occurrences are implicitly sorted by Security::MergeReportsService,
        # occurrences order differs from what is present in fixture file
        expect(json_response.first['name']).to eq 'ECB mode is insecure'
      end

      it 'returns vulnerabilities with dependency_scanning report_type' do
        occurrence_count = ds_report.occurrences.count.to_s

        get api(project_vulnerabilities_path, user), params: { report_type: 'dependency_scanning' }

        expect(response).to have_gitlab_http_status(200)

        expect(response.headers['X-Total']).to eq occurrence_count

        expect(json_response.map { |v| v['report_type'] }.uniq).to match_array %w[dependency_scanning]

        # occurrences are implicitly sorted by Security::MergeReportsService,
        # occurrences order differs from what is present in fixture file
        expect(json_response.first['name']).to eq 'ruby-ffi DDL loading issue on Windows OS'
      end

      it 'returns a "bad request" response for an unknown report type' do
        get api(project_vulnerabilities_path, user), params: { report_type: 'blah' }

        expect(response).to have_gitlab_http_status(400)
      end

      it 'returns dismissed vulnerabilities with `all` scope' do
        occurrence_count = (sast_report.occurrences.count + ds_report.occurrences.count).to_s

        get api(project_vulnerabilities_path, user), params: { scope: 'all' }.merge(pagination)

        expect(response).to have_gitlab_http_status(200)

        expect(response.headers['X-Total']).to eq occurrence_count
      end

      it 'returns vulnerabilities with low severity' do
        get api(project_vulnerabilities_path, user), params: { severity: 'low' }.merge(pagination)

        expect(response).to have_gitlab_http_status(200)

        expect(json_response.map { |v| v['severity'] }.uniq).to eq %w[low]
      end

      it 'returns a "bad request" response for an unknown severity value' do
        get api(project_vulnerabilities_path, user), params: { severity: 'foo' }

        expect(response).to have_gitlab_http_status(400)
      end

      it 'returns vulnerabilities with high confidence' do
        get api(project_vulnerabilities_path, user), params: { confidence: 'high' }.merge(pagination)

        expect(response).to have_gitlab_http_status(200)

        expect(json_response.map { |v| v['confidence'] }.uniq).to eq %w[high]
      end

      it 'returns a "bad request" response for an unknown confidence value' do
        get api(project_vulnerabilities_path, user), params: { confidence: 'qux' }

        expect(response).to have_gitlab_http_status(400)
      end

      context 'when pipeline_id is supplied' do
        it 'returns vulnerabilities from supplied pipeline' do
          occurrence_count = (sast_report.occurrences.count + ds_report.occurrences.count - 1).to_s

          get api(project_vulnerabilities_path, user), params: { pipeline_id: pipeline.id }.merge(pagination)

          expect(response).to have_gitlab_http_status(200)

          expect(response.headers['X-Total']).to eq occurrence_count
        end

        context 'pipeline has no reports' do
          it 'returns empty results' do
            get api(project_vulnerabilities_path, user), params: { pipeline_id: pipeline_without_vulnerabilities.id }.merge(pagination)

            expect(json_response).to eq []
          end
        end

        context 'with unknown pipeline' do
          it 'returns empty results' do
            get api(project_vulnerabilities_path, user), params: { pipeline_id: 0 }.merge(pagination)

            expect(json_response).to eq []
          end
        end
      end
    end
  end
end
