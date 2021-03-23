// import subscriptionListQuery from 'ee/pages/admin/cloud_licenses/graphql/queries/subscription_list.query.graphql';

export const resolvers = {
  Query: {
    subscriptionList() {
      return [
        {
          // id: cache.readQuery({ query: subscriptionListQuery }),
          id: 1,
        },
      ];
    },
  },
};
