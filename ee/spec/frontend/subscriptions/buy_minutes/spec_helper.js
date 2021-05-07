import VueApollo from 'vue-apollo';
import plansQuery from 'ee/subscriptions/graphql/queries/plans.customer.query.graphql';
import { createMockClient } from 'helpers/mock_apollo_helper';
import { mockCiMinutesPlans } from './mock_data';

export function createMockApolloProvider(mockResponses = {}) {
  const {
    plansQueryMock = jest.fn().mockResolvedValue({ data: { plans: mockCiMinutesPlans } }),
  } = mockResponses;

  const mockDefaultClient = createMockClient();
  const mockCustomerClient = createMockClient([[plansQuery, plansQueryMock]]);

  return new VueApollo({
    defaultClient: mockDefaultClient,
    clients: { customerClient: mockCustomerClient },
  });
}
