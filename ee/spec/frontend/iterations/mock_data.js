export const mockIterationNode = {
  description: 'some description',
  descriptionHtml: '<p>some description</p>',
  dueDate: '2021-02-17',
  id: 'gid://gitlab/Iteration/4',
  iid: '1',
  startDate: '2021-02-10',
  state: 'upcoming',
  title: 'top-level-iteration',
  webPath: '/groups/top-level-group/-/iterations/4',
  __typename: 'Iteration',
};

export const mockGroupIterations = {
  data: {
    group: {
      iterations: {
        nodes: [mockIterationNode],
        __typename: 'IterationConnection',
      },
      __typename: 'Group',
    },
  },
};

export const mockProjectIterations = {
  data: {
    project: {
      iterations: {
        nodes: [mockIterationNode],
        __typename: 'IterationConnection',
      },
      __typename: 'Project',
    },
  },
};
