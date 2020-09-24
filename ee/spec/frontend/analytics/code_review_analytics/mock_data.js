export const mockMergeRequests = [
  {
    title:
      'This is just a super long merge request title that does not fit into one line so it needs to be truncated',
    iid: 12345,
    web_url: 'https://gitlab.com/gitlab-org/gitlab/merge_requests/38062',
    created_at: '2020-01-08',
    milestone: {
      id: 123,
      iid: 1234,
      title: '11.1',
      web_url: 'https://gitlab.com/gitlab-org/gitlab/merge_requests?milestone_title=12.7',
      due_date: '2020-01-31',
    },
    review_time: 64,
    author: {
      id: 123,
      username: 'foo',
      name: 'foo',
      web_url: 'https://gitlab.com/foo',
      avatar_url: '',
    },
    approved_by: [
      {
        id: 123,
        username: 'bar',
        name: 'bar',
        web_url: 'https://gitlab.com/bar',
        avatar_url: '',
      },
    ],
    notes_count: 21,
    diff_stats: { additions: 504, deletions: 10, total: 514, commits_count: 7 },
  },
];

export const mockMilestones = [
  {
    id: 41,
    title: 'Sprint - Eligendi et aut pariatur ab rerum vel.',
    project_id: 1,
    description: 'Accusamus qui sapiente porro et in voluptates.',
    due_date: '2020-01-14',
    created_at: '2020-01-08T15:47:37.697Z',
    updated_at: '2020-01-08T15:47:37.697Z',
    state: 'active',
    iid: 6,
    start_date: '2020-01-08',
    group_id: null,
    name: 'Sprint - Eligendi et aut pariatur ab rerum vel.',
  },
  {
    id: 5,
    title: 'v4.0',
    project_id: 1,
    description: 'Atque laudantium reiciendis consequatur temporibus qui qui.',
    due_date: null,
    created_at: '2020-01-18T15:46:07.448Z',
    updated_at: '2020-01-18T15:46:07.448Z',
    state: 'active',
    iid: 5,
    start_date: null,
    group_id: null,
    name: 'v4.0',
  },
];

export const mockLabels = [
  { id: 74, title: 'Alero', color: '#6235f2', text_color: '#FFFFFF' },
  { id: 9, title: 'Amsche', color: '#581cc8', text_color: '#FFFFFF' },
];
