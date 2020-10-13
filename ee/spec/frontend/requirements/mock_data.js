export const mockUserPermissions = {
  updateRequirement: true,
  adminRequirement: true,
};

export const mockAuthor = {
  name: 'Administrator',
  username: 'root',
  avatarUrl: 'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
  webUrl: 'http://0.0.0.0:3000/root',
};

export const mockTestReport = {
  id: 'gid://gitlab/RequirementsManagement::TestReport/1',
  state: 'PASSED',
  createdAt: '2020-06-04T10:55:48Z',
  __typename: 'TestReport',
};

export const mockTestReportFailed = {
  id: 'gid://gitlab/RequirementsManagement::TestReport/1',
  state: 'FAILED',
  createdAt: '2020-06-04T10:55:48Z',
  __typename: 'TestReport',
};

export const mockTestReportMissing = {
  id: 'gid://gitlab/RequirementsManagement::TestReport/1',
  state: '',
  createdAt: '2020-06-04T10:55:48Z',
  __typename: 'TestReport',
};

export const requirement1 = {
  iid: '1',
  title: 'Virtutis, magnitudinis animi, patientiae, fortitudinis fomentis dolor mitigari solet.',
  createdAt: '2020-03-19T08:09:09Z',
  updatedAt: '2020-03-20T08:09:09Z',
  state: 'OPENED',
  userPermissions: mockUserPermissions,
  author: mockAuthor,
  testReports: {
    nodes: [mockTestReport],
  },
};

export const requirement2 = {
  iid: '2',
  title: 'Est autem officium, quod ita factum est, ut eius facti probabilis ratio reddi possit.',
  createdAt: '2020-03-19T08:08:14Z',
  updatedAt: '2020-03-20T08:08:14Z',
  state: 'OPENED',
  userPermissions: mockUserPermissions,
  author: mockAuthor,
  testReports: {
    nodes: [mockTestReport],
  },
};

export const requirement3 = {
  iid: '3',
  title: 'Non modo carum sibi quemque, verum etiam vehementer carum esse',
  createdAt: '2020-03-19T08:08:25Z',
  updatedAt: '2020-03-20T08:08:25Z',
  state: 'OPENED',
  userPermissions: mockUserPermissions,
  author: mockAuthor,
  testReports: {
    nodes: [mockTestReport],
  },
};

export const requirementArchived = {
  iid: '23',
  title: 'Cuius quidem, quoniam Stoicus fuit',
  createdAt: '2020-03-31T13:31:40Z',
  updatedAt: '2020-03-31T13:31:40Z',
  state: 'ARCHIVED',
  userPermissions: mockUserPermissions,
  author: mockAuthor,
  testReports: {
    nodes: [mockTestReport],
  },
};

export const mockRequirementsOpen = [requirement1, requirement2, requirement3];

export const mockRequirementsArchived = [requirementArchived];

export const mockRequirementsAll = [...mockRequirementsOpen, ...mockRequirementsArchived];

export const mockRequirementsCount = {
  OPENED: 3,
  ARCHIVED: 1,
  ALL: 4,
};

export const FilterState = {
  opened: 'OPENED',
  archived: 'ARCHIVED',
  all: 'ALL',
};

export const mockPageInfo = {
  startCursor: 'eyJpZCI6IjI1IiwiY3JlYXRlZF9hdCI6IjIwMjAtMDMtMzEgMTM6MzI6MTQgVVRDIn0',
  endCursor: 'eyJpZCI6IjIxIiwiY3JlYXRlZF9hdCI6IjIwMjAtMDMtMzEgMTM6MzE6MTUgVVRDIn0',
};

export const mockFilters = [
  {
    type: 'author_username',
    value: { data: 'root' },
  },
  {
    type: 'author_username',
    value: { data: 'john.doe' },
  },
  'foo',
];
