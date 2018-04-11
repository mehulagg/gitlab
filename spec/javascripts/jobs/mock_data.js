const threeWeeksAgo = new Date();
threeWeeksAgo.setDate(threeWeeksAgo.getDate() - 21);

export default {
  id: 4757,
  name: 'test',
  build_path: '/root/ci-mock/-/jobs/4757',
  retry_path: '/root/ci-mock/-/jobs/4757/retry',
  cancel_path: '/root/ci-mock/-/jobs/4757/cancel',
  new_issue_path: '/root/ci-mock/issues/new',
  playable: false,
  created_at: threeWeeksAgo.toISOString(),
  updated_at: threeWeeksAgo.toISOString(),
  finished_at: threeWeeksAgo.toISOString(),
  queued: 9.54,
  status: {
    icon: 'icon_status_success',
    text: 'passed',
    label: 'passed',
    group: 'success',
    has_details: true,
    details_path: '/root/ci-mock/-/jobs/4757',
    favicon: '/assets/ci_favicons/dev/favicon_status_success-308b4fc054cdd1b68d0865e6cfb7b02e92e3472f201507418f8eddb74ac11a59.ico',
    action: {
      icon: 'retry',
      title: 'Retry',
      path: '/root/ci-mock/-/jobs/4757/retry',
      method: 'post',
    },
  },
  coverage: 20,
  erased_at: threeWeeksAgo.toISOString(),
  duration: 6.785563,
  tags: ['tag'],
  user: {
    name: 'Root',
    username: 'root',
    id: 1,
    state: 'active',
    avatar_url: 'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon',
    web_url: 'http://localhost:3000/root',
  },
  erase_path: '/root/ci-mock/-/jobs/4757/erase',
  artifacts: [null],
  runner: {
    id: 1,
    description: 'local ci runner',
    edit_path: '/root/ci-mock/runners/1/edit',
  },
  pipeline: {
    id: 140,
    user: {
      name: 'Root',
      username: 'root',
      id: 1,
      state: 'active',
      avatar_url: 'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon',
      web_url: 'http://localhost:3000/root',
    },
    active: false,
    coverage: null,
    source: 'unknown',
    created_at: '2017-05-24T09:59:58.634Z',
    updated_at: '2017-06-01T17:32:00.062Z',
    path: '/root/ci-mock/pipelines/140',
    flags: {
      latest: true,
      stuck: false,
      yaml_errors: false,
      retryable: false,
      cancelable: false,
    },
    details: {
      status: {
        icon: 'icon_status_success',
        text: 'passed',
        label: 'passed',
        group: 'success',
        has_details: true,
        details_path: '/root/ci-mock/pipelines/140',
        favicon: '/assets/ci_favicons/dev/favicon_status_success-308b4fc054cdd1b68d0865e6cfb7b02e92e3472f201507418f8eddb74ac11a59.ico',
      },
      duration: 6,
      finished_at: '2017-06-01T17:32:00.042Z',
    },
    ref: {
      name: 'abc',
      path: '/root/ci-mock/commits/abc',
      tag: false,
      branch: true,
    },
    commit: {
      id: 'c58647773a6b5faf066d4ad6ff2c9fbba5f180f6',
      short_id: 'c5864777',
      title: 'Add new file',
      created_at: '2017-05-24T10:59:52.000+01:00',
      parent_ids: ['798e5f902592192afaba73f4668ae30e56eae492'],
      message: 'Add new file',
      author_name: 'Root',
      author_email: 'admin@example.com',
      authored_date: '2017-05-24T10:59:52.000+01:00',
      committer_name: 'Root',
      committer_email: 'admin@example.com',
      committed_date: '2017-05-24T10:59:52.000+01:00',
      author: {
        name: 'Root',
        username: 'root',
        id: 1,
        state: 'active',
        avatar_url: 'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon',
        web_url: 'http://localhost:3000/root',
      },
      author_gravatar_url: 'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon',
      commit_url: 'http://localhost:3000/root/ci-mock/commit/c58647773a6b5faf066d4ad6ff2c9fbba5f180f6',
      commit_path: '/root/ci-mock/commit/c58647773a6b5faf066d4ad6ff2c9fbba5f180f6',
    },
  },
  metadata: {
    timeout_human_readable: '1m 40s',
    timeout_source: 'runner',
  },
  merge_request: {
    iid: 2,
    path: '/root/ci-mock/merge_requests/2',
  },
  raw_path: '/root/ci-mock/builds/4757/raw',
};
