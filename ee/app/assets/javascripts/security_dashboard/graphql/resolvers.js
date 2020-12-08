const resolvers = {
  Vulnerability: {
    solutions: () => true,
    mergeRequestLinks: () => {
      return {
        nodes: [
          {
            merge_request: {
              url: 'https://gitlab.com/gitlab-org/gitlab/-/merge_requests/48820',
              status: 'status_warning',
              auto_fix: true,
              __typename: 'mergeRequestDetail',
            },
            __typename: 'mergeRequest',
          },
          {
            merge_request: {
              url: 'https://gitlab.com/gitlab-org/gitlab/-/merge_requests/48821',
              status: 'merge',
              auto_fix: false,
              __typename: 'mergeRequestDetail',
            },
            __typename: 'mergeRequest',
          },
          {
            merge_request: {
              url: 'https://gitlab.com/gitlab-org/gitlab/-/merge_requests/48822',
              status: 'status_canceled',
              auto_fix: true,
              __typename: 'mergeRequestDetail',
            },
            __typename: 'mergeRequest',
          },
        ],
        __typename: 'mergeRequestLinks',
      };
    },
  },
};

export default resolvers;
