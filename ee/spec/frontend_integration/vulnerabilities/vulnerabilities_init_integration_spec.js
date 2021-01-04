import initVulnerabilities from 'ee/vulnerabilities/vulnerabilities_init';
import { TEST_HOST } from 'jest/helpers/test_constants';

const EMPTY_DIV = document.createElement('div');
const TEST_DATASET = {
  // @TODO: Use vulnerability mock
  vulnerability: JSON.stringify({
    id: 1,
    created_at: new Date().toISOString(),
    report_type: 'sast',
    severity: 'medium',
    state: 'detected',
    create_mr_url: '/create_mr_url',
    new_issue_url: '/new_issue_url',
    project_fingerprint: 'abc123',
    pipeline: {
      id: 2,
      created_at: new Date().toISOString(),
      url: 'pipeline_url',
      sourceBranch: 'master',
    },
    description: 'description',
    identifiers: 'identifiers',
    links: 'links',
    location: 'location',
    name: 'name',
    project: {
      full_path: '/project_full_path',
      full_name: 'Test Project',
    },
    discussions_url: '/discussion_url',
    notes_url: '/notes_url',
    can_modify_related_issues: false,
    related_issues_help_path: '/help_path',
    merge_request_feedback: null,
    issue_feedback: null,
    remediation: null,
  }),
};

describe('Vulnerability Report', () => {
  let vm;
  let root;

  beforeEach(() => {
    root = document.createElement('div');
    document.body.appendChild(root);

    global.jsdom.reconfigure({
      // @TODO: change this
      url: `${TEST_HOST}/-/security/vulnerabilities`,
    });
  });

  afterEach(() => {
    if (vm) {
      vm.$destroy();
    }
    vm = null;
    root.remove();
  });

  const createComponent = ({ data }) => {
    const el = document.createElement('div');
    Object.assign(el.dataset, { ...TEST_DATASET, ...data });
    root.appendChild(el);
    vm = initVulnerabilities(el);
  };

  describe('default states', () => {
    it('sets up project-level', () => {
      createComponent({
        data: {
          autoFixDocumentation: '/test/auto_fix_page',
          pipelineSecurityBuildsFailedCount: 1,
          pipelineSecurityBuildsFailedPath: '/test/faild_pipeline_02',
          projectFullPath: '/test/project',
        },
      });

      expect(root).not.toStrictEqual(EMPTY_DIV);
    });
  });
});
