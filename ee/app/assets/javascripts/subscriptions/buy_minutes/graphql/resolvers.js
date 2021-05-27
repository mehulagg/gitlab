import { produce } from 'immer';
import { merge } from 'lodash';
import Api from 'ee/api';
import * as SubscriptionsApi from 'ee/api/subscriptions_api';
import {
  ERROR_FETCHING_COUNTRIES,
  ERROR_FETCHING_STATES,
  ERROR_FETCHING_PAYMENT_METHOD,
} from 'ee/subscriptions/constants';
import PLANS_QUERY from 'ee/subscriptions/graphql/queries/plans.customer.query.graphql';
import STATE_QUERY from 'ee/subscriptions/graphql/queries/state.query.graphql';
import createFlash from '~/flash';
import { getParameterValues } from '~/lib/utils/url_utility';

// NOTE: These resolvers are temporary and will be removed in the future.
// See https://gitlab.com/gitlab-org/gitlab/-/issues/321643
export const resolvers = {
  Query: {
    countries: () => {
      return Api.fetchCountries()
        .then(({ data }) =>
          data.map(([name, alpha2]) =>
            // eslint-disable-next-line @gitlab/require-i18n-strings
            ({ name, alpha2, __typename: 'Country' }),
          ),
        )
        .catch(() => createFlash({ message: ERROR_FETCHING_COUNTRIES }));
    },
    states: (countryId) => {
      return Api.fetchStates(countryId)
        .then(({ data }) => {
          // eslint-disable-next-line @gitlab/require-i18n-strings
          return data.map((state) => ({ ...state, ...{ __typename: 'State' } }));
        })
        .catch(() => createFlash({ message: ERROR_FETCHING_STATES }));
    },
    paymentMethodDetails: (paymentMethodId) => {
      return Api.fetchPaymentMethodDetails(paymentMethodId)
        .then(({ data }) => {
          // eslint-disable-next-line @gitlab/require-i18n-strings
          return data;
        })
        .catch(() => createFlash({ message: ERROR_FETCHING_PAYMENT_METHOD }));
    },
    selectedPlanId: (_, __, { cache }) => {
      const { selectedPlanId } = cache.readQuery({ query: STATE_QUERY });
      const { plans } = cache.readQuery({ query: PLANS_QUERY });

      if (selectedPlanId) {
        return selectedPlanId;
      }

      const planIdFromSearchParams = getParameterValues('planId');
      if (planIdFromSearchParams.length > 0) {
        return planIdFromSearchParams[0].id;
      }

      return plans[0].id;
    },
  },
  Mutation: {
    purchaseMinutes: (_, { groupId, customer, subscription }) => {
      return SubscriptionsApi.createSubscription(groupId, customer, subscription);
    },
    updateState: (_, { input }, { cache }) => {
      const oldState = cache.readQuery({ query: STATE_QUERY });

      const state = produce(oldState, (draftState) => {
        merge(draftState, input);
      });

      cache.writeQuery({ query: STATE_QUERY, data: state });
    },
  },
};
