export const mockGroupPath = 'gitlab-org';
export const mockProjectPath = `${mockGroupPath}/some-project`;

export const mockIssue = {
  projectPath: mockProjectPath,
  iid: '1',
  groupPath: mockGroupPath,
};

// This mock issue has a different format b/c
// it is used in board_sidebar_iteration_select_spec.js (swimlane sidebar)
export const mockIssue2 = {
  referencePath: `${mockProjectPath}#1`,
  iid: '1',
};

export const mockIssueId = 'gid://gitlab/Issue/1';

export const mockIteration1 = {
  __typename: 'Iteration',
  id: 'gid://gitlab/Iteration/1',
  title: 'Foobar Iteration',
  webUrl: 'http://gdk.test:3000/groups/gitlab-org/-/iterations/1',
  state: 'opened',
};

export const mockIteration2 = {
  __typename: 'Iteration',
  id: 'gid://gitlab/Iteration/2',
  title: 'Awesome Iteration',
  webUrl: 'http://gdk.test:3000/groups/gitlab-org/-/iterations/2',
  state: 'opened',
};

export const mockIterationsResponse = {
  data: {
    group: {
      iterations: {
        nodes: [mockIteration1, mockIteration2],
      },
      __typename: 'IterationConnection',
    },
    __typename: 'Group',
  },
};

export const emptyIterationsResponse = {
  data: {
    group: {
      iterations: {
        nodes: [],
      },
      __typename: 'IterationConnection',
    },
    __typename: 'Group',
  },
};

export const noCurrentIterationResponse = {
  data: {
    project: {
      issue: { id: mockIssueId, iteration: null, __typename: 'Issue' },
      __typename: 'Project',
    },
  },
};

export const mockMutationResponse = {
  data: {
    issueSetIteration: {
      errors: [],
      issue: {
        id: mockIssueId,
        iteration: {
          id: 'gid://gitlab/Iteration/2',
          title: 'Awesome Iteration',
          state: 'opened',
          __typename: 'Iteration',
        },
        __typename: 'Issue',
      },
      __typename: 'IssueSetIterationPayload',
    },
  },
};

export const issuableQueryResponse = {
  data: {
    project: {
      issuable: {
        __typename: 'Issue',
        id: 'gid://gitlab/Issue/1',
        iid: '1',
        participants: {
          nodes: [
            {
              id: 'gid://gitlab/User/1',
              avatarUrl:
                'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon',
              name: 'Administrator',
              username: 'root',
              webUrl: '/root',
            },
            {
              id: 'gid://gitlab/User/2',
              avatarUrl:
                'https://www.gravatar.com/avatar/a95e5b71488f4b9d69ce5ff58bfd28d6?s=80\u0026d=identicon',
              name: 'Jacki Kub',
              username: 'francina.skiles',
              webUrl: '/franc',
            },
          ],
        },
        assignees: {
          nodes: [
            {
              id: 'gid://gitlab/User/2',
              avatarUrl:
                'https://www.gravatar.com/avatar/a95e5b71488f4b9d69ce5ff58bfd28d6?s=80\u0026d=identicon',
              name: 'Jacki Kub',
              username: 'francina.skiles',
              webUrl: '/franc',
            },
          ],
        },
      },
    },
  },
};

export const searchQueryResponse = {
  data: {
    users: {
      nodes: [
        {
          id: '1',
          avatarUrl: '/avatar',
          name: 'root',
          username: 'root',
          webUrl: 'root',
        },
        {
          id: '3',
          avatarUrl: '/avatar',
          name: 'rookie',
          username: 'rookie',
          webUrl: 'rookie',
        },
      ],
    },
  },
};

export const updateIssueAssigneesMutationResponse = {
  data: {
    issueSetAssignees: {
      issue: {
        id: 'gid://gitlab/Issue/1',
        iid: '1',
        assignees: {
          nodes: [
            {
              __typename: 'User',
              id: 'gid://gitlab/User/1',
              avatarUrl:
                'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon',
              name: 'Administrator',
              username: 'root',
              webUrl: '/root',
            },
          ],
          __typename: 'UserConnection',
        },
        participants: {
          nodes: [
            {
              __typename: 'User',
              id: 'gid://gitlab/User/1',
              avatarUrl:
                'https://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80\u0026d=identicon',
              name: 'Administrator',
              username: 'root',
              webUrl: '/root',
            },
            {
              __typename: 'User',
              id: 'gid://gitlab/User/2',
              avatarUrl:
                'https://www.gravatar.com/avatar/a95e5b71488f4b9d69ce5ff58bfd28d6?s=80\u0026d=identicon',
              name: 'Jacki Kub',
              username: 'francina.skiles',
              webUrl: '/franc',
            },
          ],
          __typename: 'UserConnection',
        },
        __typename: 'Issue',
      },
      __typename: 'IssueSetAssigneesPayload',
    },
  },
};
