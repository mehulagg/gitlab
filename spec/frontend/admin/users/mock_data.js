export const users = [
  {
    id: 1997,
    name: 'Nikki',
    createdAt: '2020-11-13T12:26:54.177Z',
    email: `nikki@example.com`,
    username: 'nikki',
    lastActivityOn: '2020-12-09',
    avatarUrl:
      'https://secure.gravatar.com/avatar/054f062d8b1a42b123f17e13a173cda8?s=80\\u0026d=identicon',
    badges: [
      { text: 'Admin', variant: 'success' },
      { text: "It's you!", variant: 'muted' },
    ],
    projectsCount: 0,
    actions: [],
    note: 'Create per issue #999',
  },
];

export const paths = {
  edit: '/admin/users/id/edit',
  approve: '/admin/users/id/approve',
  reject: '/admin/users/id/reject',
  unblock: '/admin/users/id/unblock',
  block: '/admin/users/id/block',
  deactivate: '/admin/users/id/deactivate',
  activate: '/admin/users/id/activate',
  unlock: '/admin/users/id/unlock',
  delete: '/admin/users/id',
  deleteWithContributions: '/admin/users/id',
  adminUser: '/admin/users/id',
};

export const createGroupCountResponse = (groupCounts) => ({
  data: {
    users: {
      nodes: groupCounts.map(({ id, groupCount }) => ({
        id: `gid://gitlab/User/${id}`,
        groupCount,
        __typename: 'UserCore',
      })),
      __typename: 'UserCoreConnection',
    },
  },
});
export const validGroupCountResponse = {};

export const emptyGroupCountResponse = {
  data: {
    users: {
      nodes: [],
      __typename: 'UserCoreConnection',
    },
  },
};
