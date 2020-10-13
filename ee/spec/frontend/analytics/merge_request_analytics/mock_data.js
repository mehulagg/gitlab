export const startDate = new Date('2020-05-01');
export const endDate = new Date('2020-08-01');

export const fullPath = 'gitlab-org/gitlab';

export const throughputChartData = {
  May: { count: 2, __typename: 'MergeRequestConnection' },
  Jun: { count: 4, __typename: 'MergeRequestConnection' },
  Jul: { count: 3, __typename: 'MergeRequestConnection' },
  __typename: 'Project',
};

export const expectedMonthData = [
  {
    year: 2020,
    month: 'May',
    mergedAfter: '2020-05-17',
    mergedBefore: '2020-06-01',
  },
  {
    year: 2020,
    month: 'Jun',
    mergedAfter: '2020-06-01',
    mergedBefore: '2020-07-01',
  },
  {
    year: 2020,
    month: 'Jul',
    mergedAfter: '2020-07-01',
    mergedBefore: '2020-07-17',
  },
];

export const throughputChartQuery = `query ($fullPath: ID!, $labels: [String!], $authorUsername: String, $assigneeUsername: String, $milestoneTitle: String, $sourceBranches: [String!], $targetBranches: [String!]) {
  throughputChartData: project(fullPath: $fullPath) {
    May_2020: mergeRequests(first: 0, mergedBefore: "2020-06-01", mergedAfter: "2020-05-17", labels: $labels, authorUsername: $authorUsername, assigneeUsername: $assigneeUsername, milestoneTitle: $milestoneTitle, sourceBranches: $sourceBranches, targetBranches: $targetBranches) {
      count
    }
    Jun_2020: mergeRequests(first: 0, mergedBefore: "2020-07-01", mergedAfter: "2020-06-01", labels: $labels, authorUsername: $authorUsername, assigneeUsername: $assigneeUsername, milestoneTitle: $milestoneTitle, sourceBranches: $sourceBranches, targetBranches: $targetBranches) {
      count
    }
    Jul_2020: mergeRequests(first: 0, mergedBefore: "2020-07-17", mergedAfter: "2020-07-01", labels: $labels, authorUsername: $authorUsername, assigneeUsername: $assigneeUsername, milestoneTitle: $milestoneTitle, sourceBranches: $sourceBranches, targetBranches: $targetBranches) {
      count
    }
  }
}
`;

export const throughputTableHeaders = [
  'Merge Request',
  'Date Merged',
  'Time to merge',
  'Milestone',
  'Commits',
  'Pipelines',
  'Line changes',
  'Assignees',
];

export const pageInfo = {
  hasNextPage: true,
  hasPreviousPage: false,
  startCursor: 'abc',
  endCursor: 'bcd',
};

export const throughputTableData = [
  {
    iid: '1',
    title: 'Update README.md',
    createdAt: '2020-08-06T16:53:50Z',
    mergedAt: '2020-08-06T16:57:53Z',
    webUrl: 'http://127.0.0.1:3001/gitlab-org/gitlab-shell/-/merge_requests/11',
    milestone: null,
    assignees: {
      nodes: [
        {
          avatarUrl:
            'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
          name: 'Administrator',
          webUrl: 'http://127.0.0.1:3001/root',
        },
      ],
    },
    diffStatsSummary: { additions: 2, deletions: 1 },
    labels: {
      count: 0,
    },
    pipelines: {
      nodes: [],
    },
    commitCount: 1,
    userNotesCount: 0,
    approvedBy: {
      nodes: [],
    },
  },
];
