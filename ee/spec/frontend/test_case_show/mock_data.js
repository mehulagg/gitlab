import { mockIssuable, mockCurrentUserTodo } from 'jest/issuable_list/mock_data';

export const mockTestCase = {
  ...mockIssuable,
  currentUserTodos: {
    nodes: [mockCurrentUserTodo],
  },
};

export const mockProvide = {
  projectFullPath: 'gitlab-org/gitlab-test',
  testCaseNewPath: '/gitlab-org/gitlab-test/-/quality/test_cases/new',
  testCaseId: mockIssuable.iid,
  canEditTestCase: true,
  descriptionPreviewPath: '/gitlab-org/gitlab-test/preview_markdown',
  descriptionHelpPath: '/help/user/markdown',
  labelsFetchPath: '/gitlab-org/gitlab-test/-/labels.json',
  labelsManagePath: '/gitlab-org/gitlab-shell/-/labels',
};
