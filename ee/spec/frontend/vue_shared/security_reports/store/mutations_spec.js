import * as types from 'ee/vue_shared/security_reports/store/mutation_types';
import mutations from 'ee/vue_shared/security_reports/store/mutations';
import state from 'ee/vue_shared/security_reports/store/state';
import { visitUrl } from '~/lib/utils/url_utility';
import { mockFindings } from '../mock_data';

jest.mock('~/lib/utils/url_utility', () => ({
  visitUrl: jest.fn().mockName('visitUrlMock'),
}));

// See also the corresponding CE specs in
// spec/frontend/vue_shared/security_reports/store/modules/sast/mutations_spec.js
describe('EE sast reports mutations', () => {
  let stateCopy;

  beforeEach(() => {
    stateCopy = state();
  });

  describe('SET_HEAD_BLOB_PATH', () => {
    it('should set head blob path', () => {
      mutations[types.SET_HEAD_BLOB_PATH](stateCopy, 'head_blob_path');

      expect(stateCopy.blobPath.head).toEqual('head_blob_path');
    });
  });

  describe('SET_BASE_BLOB_PATH', () => {
    it('should set base blob path', () => {
      mutations[types.SET_BASE_BLOB_PATH](stateCopy, 'base_blob_path');

      expect(stateCopy.blobPath.base).toEqual('base_blob_path');
    });
  });

  describe('SET_CAN_READ_VULNERABILITY_FEEDBACK', () => {
    it('should set the vulnerabilities endpoint', () => {
      mutations[types.SET_CAN_READ_VULNERABILITY_FEEDBACK](stateCopy, false);

      expect(stateCopy.canReadVulnerabilityFeedback).toEqual(false);
    });
  });

  describe('SET_VULNERABILITY_FEEDBACK_PATH', () => {
    it('should set the vulnerabilities endpoint', () => {
      mutations[types.SET_VULNERABILITY_FEEDBACK_PATH](stateCopy, 'vulnerability_path');

      expect(stateCopy.vulnerabilityFeedbackPath).toEqual('vulnerability_path');
    });
  });

  describe('SET_PIPELINE_ID', () => {
    it('should set the pipeline id', () => {
      mutations[types.SET_PIPELINE_ID](stateCopy, 123);

      expect(stateCopy.pipelineId).toEqual(123);
    });
  });

  describe('REQUEST_CONTAINER_SCANNING_DIFF', () => {
    it('should set container scanning loading flag to true', () => {
      mutations[types.REQUEST_CONTAINER_SCANNING_DIFF](stateCopy);

      expect(stateCopy.containerScanning.isLoading).toEqual(true);
    });
  });

  describe('REQUEST_DAST_DIFF', () => {
    it('should set dast loading flag to true', () => {
      mutations[types.REQUEST_DAST_DIFF](stateCopy);

      expect(stateCopy.dast.isLoading).toEqual(true);
    });
  });

  describe('REQUEST_DEPENDENCY_SCANNING_DIFF', () => {
    it('should set dependency scanning loading flag to true', () => {
      mutations[types.REQUEST_DEPENDENCY_SCANNING_DIFF](stateCopy);

      expect(stateCopy.dependencyScanning.isLoading).toEqual(true);
    });
  });

  describe('SET_ISSUE_MODAL_DATA', () => {
    it('has default data', () => {
      expect(stateCopy.modal.vulnerability.isDismissed).toEqual(false);
      expect(stateCopy.modal.vulnerability.hasIssue).toEqual(false);

      expect(stateCopy.isDismissingVulnerability).toEqual(false);

      expect(stateCopy.modal.title).toEqual(null);
      expect(stateCopy.modal.learnMoreUrl).toEqual(null);
      expect(stateCopy.modal.error).toEqual(null);
    });

    it('sets modal data', () => {
      stateCopy.vulnerabilityFeedbackPath = 'path';

      const issue = {
        tool: 'bundler_audit',
        message: 'Arbitrary file existence disclosure in Action Pack',
        cve: 'CVE-2014-7829',
        solution: 'upgrade to ~> 3.2.21, ~> 4.0.11.1, ~> 4.0.12, ~> 4.1.7.1, >= 4.1.8',
        title: 'Arbitrary file existence disclosure in Action Pack',
        path: 'Gemfile.lock',
        urlPath: 'path/Gemfile.lock',
        location: {
          file: 'Gemfile.lock',
          class: 'User',
          method: 'do_something',
          image: 'https://example.org/docker/example:v1.2.3',
          operating_system: 'debian:8',
          hostname: 'https://gitlab.com',
          path: '/user6',
        },
        links: [
          {
            url: 'https://groups.google.com/forum/#!topic/rubyonrails-security/rMTQy4oRCGk',
          },
        ],
        identifiers: [
          {
            type: 'CVE',
            name: 'CVE-2014-9999',
            value: 'CVE-2014-9999',
            url: 'https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2014-9999',
          },
        ],
        instances: [
          {
            param: 'X-Content-Type-Options',
            method: 'GET',
            uri: 'http://example.com/some-path',
          },
        ],
        isDismissed: true,
      };
      const status = 'success';

      mutations[types.SET_ISSUE_MODAL_DATA](stateCopy, { issue, status });

      expect(stateCopy.modal.title).toEqual(issue.title);
      expect(stateCopy.modal.vulnerability).toEqual(issue);
      expect(stateCopy.modal.isResolved).toEqual(true);
    });
  });

  describe('REQUEST_DISMISS_VULNERABILITY', () => {
    it('sets isDismissingVulnerability prop to true and resets error', () => {
      mutations[types.REQUEST_DISMISS_VULNERABILITY](stateCopy);

      expect(stateCopy.isDismissingVulnerability).toEqual(true);
      expect(stateCopy.modal.error).toBeNull();
    });
  });

  describe('RECEIVE_DISMISS_VULNERABILITY_SUCCESS', () => {
    it('sets isDismissingVulnerability prop to false', () => {
      mutations[types.RECEIVE_DISMISS_VULNERABILITY_SUCCESS](stateCopy);

      expect(stateCopy.isDismissingVulnerability).toEqual(false);
    });
  });

  describe('RECEIVE_DISMISS_VULNERABILITY_ERROR', () => {
    it('sets isDismissingVulnerability prop to false and sets error', () => {
      mutations[types.RECEIVE_DISMISS_VULNERABILITY_ERROR](stateCopy, 'error');

      expect(stateCopy.isDismissingVulnerability).toEqual(false);
      expect(stateCopy.modal.error).toEqual('error');
    });
  });

  describe(types.REQUEST_ADD_DISMISSAL_COMMENT, () => {
    beforeEach(() => {
      mutations[types.REQUEST_ADD_DISMISSAL_COMMENT](stateCopy);
    });

    it('should set isDismissingVulnerability to true', () => {
      expect(stateCopy.isDismissingVulnerability).toBe(true);
    });

    it('should nullify the error state on the modal', () => {
      expect(stateCopy.modal.error).toBeNull();
    });
  });

  describe(types.RECEIVE_ADD_DISMISSAL_COMMENT_SUCCESS, () => {
    let payload;
    let vulnerability;
    let data;

    beforeEach(() => {
      vulnerability = { id: 1 };
      data = { name: 'dismissal feedback' };
      payload = { id: vulnerability.id, data };
      mutations[types.RECEIVE_ADD_DISMISSAL_COMMENT_SUCCESS](stateCopy, payload);
    });

    it('should set isDismissingVulnerability to false', () => {
      expect(stateCopy.isDismissingVulnerability).toBe(false);
    });

    it('should set isDismissed on the modal vulnerability to be true', () => {
      expect(stateCopy.modal.vulnerability.isDismissed).toBe(true);
    });
  });

  describe(types.RECEIVE_ADD_DISMISSAL_COMMENT_ERROR, () => {
    const error = 'There was an error adding the comment.';

    beforeEach(() => {
      mutations[types.RECEIVE_ADD_DISMISSAL_COMMENT_ERROR](stateCopy, error);
    });

    it('should set isDismissingVulnerability to false', () => {
      expect(stateCopy.isDismissingVulnerability).toBe(false);
    });

    it('should set the error state on the modal', () => {
      expect(stateCopy.modal.error).toEqual(error);
    });
  });

  describe(types.REQUEST_DELETE_DISMISSAL_COMMENT, () => {
    beforeEach(() => {
      mutations[types.REQUEST_DELETE_DISMISSAL_COMMENT](stateCopy);
    });

    it('should set isDismissingVulnerability to true', () => {
      expect(stateCopy.isDismissingVulnerability).toBe(true);
    });

    it('should nullify the error state on the modal', () => {
      expect(stateCopy.modal.error).toBeNull();
    });
  });

  describe(types.RECEIVE_DELETE_DISMISSAL_COMMENT_SUCCESS, () => {
    let payload;
    let vulnerability;
    let data;

    beforeEach(() => {
      vulnerability = { id: 1 };
      data = { name: 'dismissal feedback' };
      payload = { id: vulnerability.id, data };
      mutations[types.RECEIVE_DELETE_DISMISSAL_COMMENT_SUCCESS](stateCopy, payload);
    });

    it('should set isDismissingVulnerability to false', () => {
      expect(stateCopy.isDismissingVulnerability).toBe(false);
    });

    it('should set isDismissed on the modal vulnerability to be true', () => {
      expect(stateCopy.modal.vulnerability.isDismissed).toBe(true);
    });
  });

  describe(types.RECEIVE_DELETE_DISMISSAL_COMMENT_ERROR, () => {
    const error = 'There was an error deleting the comment.';

    beforeEach(() => {
      mutations[types.RECEIVE_DELETE_DISMISSAL_COMMENT_ERROR](stateCopy, error);
    });

    it('should set isDismissingVulnerability to false', () => {
      expect(stateCopy.isDismissingVulnerability).toBe(false);
    });

    it('should set the error state on the modal', () => {
      expect(stateCopy.modal.error).toEqual(error);
    });
  });

  describe(types.SHOW_DISMISSAL_DELETE_BUTTONS, () => {
    beforeEach(() => {
      mutations[types.SHOW_DISMISSAL_DELETE_BUTTONS](stateCopy);
    });

    it('should set isShowingDeleteButtonsto to true', () => {
      expect(stateCopy.modal.isShowingDeleteButtons).toBe(true);
    });
  });

  describe(types.HIDE_DISMISSAL_DELETE_BUTTONS, () => {
    beforeEach(() => {
      mutations[types.HIDE_DISMISSAL_DELETE_BUTTONS](stateCopy);
    });

    it('should set isShowingDeleteButtons to false', () => {
      expect(stateCopy.modal.isShowingDeleteButtons).toBe(false);
    });
  });

  describe('OPEN_DISMISSAL_COMMENT_BOX', () => {
    beforeEach(() => {
      mutations[types.OPEN_DISMISSAL_COMMENT_BOX](stateCopy);
    });

    it('should set isCommentingOnDismissal to true', () => {
      expect(stateCopy.modal.isCommentingOnDismissal).toBe(true);
    });
  });

  describe('CLOSE_DISMISSAL_COMMENT_BOX', () => {
    beforeEach(() => {
      mutations[types.CLOSE_DISMISSAL_COMMENT_BOX](stateCopy);
    });

    it('should set isCommentingOnDismissal to false', () => {
      expect(stateCopy.modal.isCommentingOnDismissal).toBe(false);
    });

    it('should set isShowingDeleteButtons to false', () => {
      expect(stateCopy.modal.isShowingDeleteButtons).toBe(false);
    });
  });

  describe('REQUEST_CREATE_ISSUE', () => {
    it('sets isCreatingIssue prop to true and resets error', () => {
      mutations[types.REQUEST_CREATE_ISSUE](stateCopy);

      expect(stateCopy.isCreatingIssue).toEqual(true);
      expect(stateCopy.modal.error).toBeNull();
    });
  });

  describe('RECEIVE_CREATE_ISSUE_SUCCESS', () => {
    it('sets isCreatingIssue prop to false', () => {
      mutations[types.RECEIVE_CREATE_ISSUE_SUCCESS](stateCopy);

      expect(stateCopy.isCreatingIssue).toEqual(false);
    });
  });

  describe('RECEIVE_CREATE_ISSUE_ERROR', () => {
    it('sets isCreatingIssue prop to false and sets error', () => {
      mutations[types.RECEIVE_CREATE_ISSUE_ERROR](stateCopy, 'error');

      expect(stateCopy.isCreatingIssue).toEqual(false);
      expect(stateCopy.modal.error).toEqual('error');
    });
  });

  describe('REQUEST_CREATE_MERGE_REQUEST', () => {
    it('sets isCreatingMergeRequest prop to true and resets error', () => {
      mutations[types.REQUEST_CREATE_MERGE_REQUEST](stateCopy);

      expect(stateCopy.isCreatingMergeRequest).toEqual(true);
      expect(stateCopy.modal.error).toBeNull();
    });
  });

  describe('RECEIVE_CREATE_MERGE_REQUEST_SUCCESS', () => {
    it('should fire the visitUrl function on the merge request URL', () => {
      const payload = { merge_request_path: 'fakepath.html' };
      mutations[types.RECEIVE_CREATE_MERGE_REQUEST_SUCCESS](stateCopy, payload);

      expect(visitUrl).toHaveBeenCalledWith(payload.merge_request_path);
    });
  });

  describe('RECEIVE_CREATE_MERGE_REQUEST_ERROR', () => {
    it('sets isCreatingMergeRequest prop to false and sets error', () => {
      mutations[types.RECEIVE_CREATE_MERGE_REQUEST_ERROR](stateCopy, 'error');

      expect(stateCopy.isCreatingMergeRequest).toEqual(false);
      expect(stateCopy.modal.error).toEqual('error');
    });
  });

  describe('UPDATE_DEPENDENCY_SCANNING_ISSUE', () => {
    it('updates issue in the new issues list', () => {
      stateCopy.dependencyScanning.newIssues = mockFindings;
      stateCopy.dependencyScanning.resolvedIssues = [];
      stateCopy.dependencyScanning.allIssues = [];
      const updatedIssue = {
        ...mockFindings[0],
        foo: 'bar',
      };

      mutations[types.UPDATE_DEPENDENCY_SCANNING_ISSUE](stateCopy, updatedIssue);

      expect(stateCopy.dependencyScanning.newIssues[0]).toEqual(updatedIssue);
    });

    it('updates issue in the resolved issues list', () => {
      stateCopy.dependencyScanning.newIssues = [];
      stateCopy.dependencyScanning.resolvedIssues = mockFindings;
      stateCopy.dependencyScanning.allIssues = [];
      const updatedIssue = {
        ...mockFindings[0],
        foo: 'bar',
      };

      mutations[types.UPDATE_DEPENDENCY_SCANNING_ISSUE](stateCopy, updatedIssue);

      expect(stateCopy.dependencyScanning.resolvedIssues[0]).toEqual(updatedIssue);
    });

    it('updates issue in the all issues list', () => {
      stateCopy.dependencyScanning.newIssues = [];
      stateCopy.dependencyScanning.resolvedIssues = [];
      stateCopy.dependencyScanning.allIssues = mockFindings;
      const updatedIssue = {
        ...mockFindings[0],
        foo: 'bar',
      };

      mutations[types.UPDATE_DEPENDENCY_SCANNING_ISSUE](stateCopy, updatedIssue);

      expect(stateCopy.dependencyScanning.allIssues[0]).toEqual(updatedIssue);
    });
  });

  describe('UPDATE_CONTAINER_SCANNING_ISSUE', () => {
    it('updates issue in the new issues list', () => {
      stateCopy.containerScanning.newIssues = mockFindings;
      stateCopy.containerScanning.resolvedIssues = [];
      const updatedIssue = {
        ...mockFindings[0],
        foo: 'bar',
      };

      mutations[types.UPDATE_CONTAINER_SCANNING_ISSUE](stateCopy, updatedIssue);

      expect(stateCopy.containerScanning.newIssues[0]).toEqual(updatedIssue);
    });

    it('updates issue in the resolved issues list', () => {
      stateCopy.containerScanning.newIssues = [];
      stateCopy.containerScanning.resolvedIssues = mockFindings;
      const updatedIssue = {
        ...mockFindings[0],
        foo: 'bar',
      };

      mutations[types.UPDATE_CONTAINER_SCANNING_ISSUE](stateCopy, updatedIssue);

      expect(stateCopy.containerScanning.resolvedIssues[0]).toEqual(updatedIssue);
    });
  });

  describe('UPDATE_DAST_ISSUE', () => {
    it('updates issue in the new issues list', () => {
      stateCopy.dast.newIssues = mockFindings;
      stateCopy.dast.resolvedIssues = [];
      const updatedIssue = {
        ...mockFindings[0],
        foo: 'bar',
      };

      mutations[types.UPDATE_DAST_ISSUE](stateCopy, updatedIssue);

      expect(stateCopy.dast.newIssues[0]).toEqual(updatedIssue);
    });

    it('updates issue in the resolved issues list', () => {
      stateCopy.dast.newIssues = [];
      stateCopy.dast.resolvedIssues = mockFindings;
      const updatedIssue = {
        ...mockFindings[0],
        foo: 'bar',
      };

      mutations[types.UPDATE_DAST_ISSUE](stateCopy, updatedIssue);

      expect(stateCopy.dast.resolvedIssues[0]).toEqual(updatedIssue);
    });
  });

  describe('SET_CONTAINER_SCANNING_DIFF_ENDPOINT', () => {
    const endpoint = 'container_scanning_diff_endpoint.json';

    beforeEach(() => {
      mutations[types.SET_CONTAINER_SCANNING_DIFF_ENDPOINT](stateCopy, endpoint);
    });

    it('should set the correct endpoint', () => {
      expect(stateCopy.containerScanning.paths.diffEndpoint).toEqual(endpoint);
    });
  });

  describe('RECEIVE_CONTAINER_SCANNING_DIFF_SUCCESS', () => {
    const reports = {
      diff: {
        added: [
          { name: 'added vuln 1', report_type: 'container_scanning' },
          { name: 'added vuln 2', report_type: 'container_scanning' },
        ],
        fixed: [{ name: 'fixed vuln 1', report_type: 'container_scanning' }],
        base_report_out_of_date: true,
      },
    };

    beforeEach(() => {
      mutations[types.RECEIVE_CONTAINER_SCANNING_DIFF_SUCCESS](stateCopy, reports);
    });

    it('should set isLoading to false', () => {
      expect(stateCopy.containerScanning.isLoading).toBe(false);
    });

    it('should set baseReportOutofDate to true', () => {
      expect(stateCopy.containerScanning.baseReportOutofDate).toBe(true);
    });

    it('should parse and set the added vulnerabilities', () => {
      reports.diff.added.forEach((vuln, i) => {
        expect(stateCopy.containerScanning.newIssues[i]).toEqual(
          expect.objectContaining({
            name: vuln.name,
            title: vuln.name,
            category: vuln.report_type,
          }),
        );
      });
    });

    it('should parse and set the fixed vulnerabilities', () => {
      reports.diff.fixed.forEach((vuln, i) => {
        expect(stateCopy.containerScanning.resolvedIssues[i]).toEqual(
          expect.objectContaining({
            name: vuln.name,
            title: vuln.name,
            category: vuln.report_type,
          }),
        );
      });
    });
  });

  describe('RECEIVE_CONTAINER_SCANNING_DIFF_ERROR', () => {
    it('should set container scanning loading flag to false and error flag to true', () => {
      mutations[types.RECEIVE_CONTAINER_SCANNING_DIFF_ERROR](stateCopy);

      expect(stateCopy.containerScanning.isLoading).toEqual(false);
      expect(stateCopy.containerScanning.hasError).toEqual(true);
    });
  });

  describe('SET_DEPENDENCY_SCANNING_DIFF_ENDPOINT', () => {
    const endpoint = 'dependency_scannning_diff_endpoint.json';

    beforeEach(() => {
      mutations[types.SET_DEPENDENCY_SCANNING_DIFF_ENDPOINT](stateCopy, endpoint);
    });

    it('should set the correct endpoint', () => {
      expect(stateCopy.dependencyScanning.paths.diffEndpoint).toEqual(endpoint);
    });
  });

  describe('RECEIVE_DEPENDENCY_SCANNING_DIFF_SUCCESS', () => {
    let reports = {};

    beforeEach(() => {
      reports = {
        diff: {
          added: [
            { name: 'added vuln 1', report_type: 'dependency_scanning' },
            { name: 'added vuln 2', report_type: 'dependency_scanning' },
          ],
          fixed: [{ name: 'fixed vuln 1', report_type: 'dependency_scanning' }],
          existing: [{ name: 'existing vuln 1', report_type: 'dependency_scanning' }],
          base_report_out_of_date: true,
        },
      };
      mutations[types.RECEIVE_DEPENDENCY_SCANNING_DIFF_SUCCESS](stateCopy, reports);
    });

    it('should set isLoading to false', () => {
      expect(stateCopy.dependencyScanning.isLoading).toBe(false);
    });

    it('should set baseReportOutofDate to true', () => {
      expect(stateCopy.dependencyScanning.baseReportOutofDate).toBe(true);
    });

    it('should parse and set the added vulnerabilities', () => {
      reports.diff.added.forEach((vuln, i) => {
        expect(stateCopy.dependencyScanning.newIssues[i]).toEqual(
          expect.objectContaining({
            name: vuln.name,
            title: vuln.name,
            category: vuln.report_type,
          }),
        );
      });
    });

    it('should parse and set the fixed vulnerabilities', () => {
      reports.diff.fixed.forEach((vuln, i) => {
        expect(stateCopy.dependencyScanning.resolvedIssues[i]).toEqual(
          expect.objectContaining({
            name: vuln.name,
            title: vuln.name,
            category: vuln.report_type,
          }),
        );
      });
    });
  });

  describe('RECEIVE_DEPENDENCY_SCANNING_DIFF_ERROR', () => {
    it('should set dependency scanning loading flag to false and error flag to true', () => {
      mutations[types.RECEIVE_DEPENDENCY_SCANNING_DIFF_ERROR](stateCopy);

      expect(stateCopy.dependencyScanning.isLoading).toEqual(false);
      expect(stateCopy.dependencyScanning.hasError).toEqual(true);
    });
  });

  describe('SET_DAST_DIFF_ENDPOINT', () => {
    const endpoint = 'dast_diff_endpoint.json';

    beforeEach(() => {
      mutations[types.SET_DAST_DIFF_ENDPOINT](stateCopy, endpoint);
    });

    it('should set the correct endpoint', () => {
      expect(stateCopy.dast.paths.diffEndpoint).toEqual(endpoint);
    });
  });

  describe('RECEIVE_DAST_DIFF_SUCCESS', () => {
    let reports = {};
    const scans = [
      {
        scanned_resources_count: 123,
        job_path: '/group/project/-/jobs/123546789',
      },
      {
        scanned_resources_count: 321,
        job_path: '/group/project/-/jobs/987654321',
      },
    ];

    beforeEach(() => {
      reports = {
        diff: {
          added: [
            { name: 'added vuln 1', report_type: 'dast' },
            { name: 'added vuln 2', report_type: 'dast' },
          ],
          fixed: [{ name: 'fixed vuln 1', report_type: 'dast' }],
          existing: [{ name: 'existing vuln 1', report_type: 'dast' }],
          base_report_out_of_date: true,
          scans,
        },
      };
      mutations[types.RECEIVE_DAST_DIFF_SUCCESS](stateCopy, reports);
    });

    it('should set isLoading to false', () => {
      expect(stateCopy.dast.isLoading).toBe(false);
    });

    it('should set scans', () => {
      expect(stateCopy.dast.scans).toEqual(scans);
    });

    it('should set baseReportOutofDate to true', () => {
      expect(stateCopy.dast.baseReportOutofDate).toBe(true);
    });

    it('should parse and set the added vulnerabilities', () => {
      reports.diff.added.forEach((vuln, i) => {
        expect(stateCopy.dast.newIssues[i]).toEqual(
          expect.objectContaining({
            name: vuln.name,
            title: vuln.name,
            category: vuln.report_type,
          }),
        );
      });
    });

    it('should parse and set the fixed vulnerabilities', () => {
      reports.diff.fixed.forEach((vuln, i) => {
        expect(stateCopy.dast.resolvedIssues[i]).toEqual(
          expect.objectContaining({
            name: vuln.name,
            title: vuln.name,
            category: vuln.report_type,
          }),
        );
      });
    });
  });

  describe('RECEIVE_DAST_DIFF_ERROR', () => {
    it('should set dast loading flag to false and error flag to true', () => {
      mutations[types.RECEIVE_DAST_DIFF_ERROR](stateCopy);

      expect(stateCopy.dast.isLoading).toEqual(false);
      expect(stateCopy.dast.hasError).toEqual(true);
    });
  });

  describe('SET_COVERAGE_FUZZING_DIFF_ENDPOINT', () => {
    const endpoint = 'coverage_fuzzing_diff_endpoint.json';

    beforeEach(() => {
      mutations[types.SET_COVERAGE_FUZZING_DIFF_ENDPOINT](stateCopy, endpoint);
    });

    it('should set the correct endpoint', () => {
      expect(stateCopy.coverageFuzzing.paths.diffEndpoint).toEqual(endpoint);
    });
  });

  describe('RECEIVE_COVERAGE_FUZZING_DIFF_SUCCESS', () => {
    let reports = {};
    const scans = [
      {
        scanned_resources_count: 123,
        job_path: '/group/project/-/jobs/123546789',
      },
      {
        scanned_resources_count: 321,
        job_path: '/group/project/-/jobs/987654321',
      },
    ];

    beforeEach(() => {
      reports = {
        diff: {
          added: [
            { name: 'added vuln 1', report_type: 'coverage_fuzzing' },
            { name: 'added vuln 2', report_type: 'coverage_fuzzing' },
          ],
          fixed: [{ name: 'fixed vuln 1', report_type: 'coverage_fuzzing' }],
          existing: [{ name: 'existing vuln 1', report_type: 'coverage_fuzzing' }],
          base_report_out_of_date: true,
          scans,
        },
      };
      mutations[types.RECEIVE_COVERAGE_FUZZING_DIFF_SUCCESS](stateCopy, reports);
    });

    it('should set isLoading to false', () => {
      expect(stateCopy.coverageFuzzing.isLoading).toBe(false);
    });

    it('should set scans', () => {
      expect(stateCopy.coverageFuzzing.scans).toEqual(scans);
    });

    it('should set baseReportOutofDate to true', () => {
      expect(stateCopy.coverageFuzzing.baseReportOutofDate).toBe(true);
    });

    it('should parse and set the added vulnerabilities', () => {
      reports.diff.added.forEach((vuln, i) => {
        expect(stateCopy.coverageFuzzing.newIssues[i]).toEqual(
          expect.objectContaining({
            name: vuln.name,
            title: vuln.name,
            category: vuln.report_type,
          }),
        );
      });
    });

    it('should parse and set the fixed vulnerabilities', () => {
      reports.diff.fixed.forEach((vuln, i) => {
        expect(stateCopy.coverageFuzzing.resolvedIssues[i]).toEqual(
          expect.objectContaining({
            name: vuln.name,
            title: vuln.name,
            category: vuln.report_type,
          }),
        );
      });
    });
  });

  describe('RECEIVE_COVERAGE_FUZZING_DIFF_ERROR', () => {
    it('should set coverage fuzzing loading flag to false and error flag to true', () => {
      mutations[types.RECEIVE_COVERAGE_FUZZING_DIFF_ERROR](stateCopy);

      expect(stateCopy.coverageFuzzing.isLoading).toEqual(false);
      expect(stateCopy.coverageFuzzing.hasError).toEqual(true);
    });
  });
});
