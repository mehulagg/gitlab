export const mockGroupPath = 'gitlab-org';
export const mockProjectPath = `${mockGroupPath}/some-project`;

export const mockIssue = {
  projectPath: mockProjectPath,
  iid: '1',
  groupPath: mockGroupPath,
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

export const mockGroupIterationsResponse = {
  data: {
    workspace: {
      iterations: {
        nodes: [mockIteration1, mockIteration2],
      },
      __typename: 'IterationConnection',
    },
    __typename: 'Group',
  },
};

export const emptyGroupIterationsResponse = {
  data: {
    workspace: {
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
    workspace: {
      issuable: { id: mockIssueId, iteration: null, __typename: 'Issue' },
      __typename: 'Project',
    },
  },
};

export const mockMutationResponse = {
  data: {
    issuableSetIteration: {
      errors: [],
      issuable: {
        id: 'gid://gitlab/Issue/1',
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
