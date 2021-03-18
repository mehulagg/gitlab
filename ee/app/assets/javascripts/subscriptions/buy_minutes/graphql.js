import Vue from 'vue';
import VueApollo from 'vue-apollo';
import * as SubscriptionsApi from 'ee/api/subscriptions_api';

Vue.use(VueApollo);

// NOTE: These resolvers are temporary and will be removed in the future.
export const resolvers = {
  Mutation: {
    purchaseMinutes: (_, { groupId, customer, subscription }) => {
      return SubscriptionsApi.createSubscription(groupId, customer, subscription);
    },
  },
};
