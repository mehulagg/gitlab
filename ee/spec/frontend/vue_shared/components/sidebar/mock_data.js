export const mockEpic1 = {
  group_id: 2,
  id: 15,
  iid: 1,
  reference: '&1',
  title: 'Error omnis quos consequatur ullam a vitae sed omnis libero cupiditate.',
  url: '/groups/gitlab-org/-/epics/1',
  web_edit_url: '/groups/gitlab-org/-/epics/1',
};

export const mockEpic2 = {
  group_id: 2,
  id: 16,
  iid: 2,
  reference: '&2',
  title: 'Enim reiciendis illo modi non voluptas molestiae error est quas.',
  url: '/groups/gitlab-org/-/epics/2',
  web_edit_url: '/groups/gitlab-org/-/epics/2',
};

export const mockIssue = {
  id: 11,
  epic_issue_id: 10,
};

export const mockSidebarStore = {
  isFetching: {
    epic: false,
  },
  epic_issue_id: 10,
  epic: mockEpic1,
};

export const mockAssignRemoveRes = {
  id: 22,
  epic: mockEpic1,
  issue: mockIssue,
};

export const noneEpic = {
  id: 0,
  title: 'No Epic',
};

export const placeholderEpic = {
  id: -1,
  title: 'Select epic',
};

export const mockEpics = [mockEpic1, mockEpic2];
