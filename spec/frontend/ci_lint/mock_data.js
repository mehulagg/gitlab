export const mockJobs = [
  {
    name: 'job_1',
    stage: 'build',
    before_script: [],
    script: ["echo 'Building'"],
    after_script: [],
    tag_list: [],
    environment: null,
    when: 'on_success',
    allow_failure: true,
    only: { refs: ['web', 'chat', 'pushes'] },
    except: null,
  },
  {
    name: 'multi_project_job',
    stage: 'test',
    before_script: [],
    script: ["echo 'multi-project job'"],
    after_script: [],
    tag_list: [],
    environment: null,
    when: 'on_success',
    allow_failure: false,
    only: { refs: ['branches', 'tags'] },
    except: null,
  },
  {
    name: 'job_2',
    stage: 'test',
    before_script: ["echo 'before script'"],
    script: ["echo 'script'"],
    after_script: ["echo 'after script"],
    tag_list: [],
    environment: null,
    when: 'on_success',
    allow_failure: false,
    only: { refs: ['branches@gitlab-org/gitlab'] },
    except: { refs: ['master@gitlab-org/gitlab', '/^release/.*$/@gitlab-org/gitlab'] },
  },
];

export const mockErrors = [
  '"job_1 job: chosen stage does not exist; available stages are .pre, build, test, deploy, .post"',
];

export const mockWarnings = [
  '"jobs:multi_project_job may allow multiple pipelines to run for a single action due to `rules:when` clause with no `workflow:rules` - read more: https://docs.gitlab.com/ee/ci/troubleshooting.html#pipeline-warnings"',
];
