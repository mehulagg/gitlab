import activeStepQuery from 'ee/vue_shared/purchase_flow/graphql/queries/active_step.query.graphql';
import stepListQuery from 'ee/vue_shared/purchase_flow/graphql/queries/step_list.query.graphql';
import resolvers from 'ee/vue_shared/purchase_flow/graphql/resolvers';
import createMockApollo from 'helpers/mock_apollo_helper';

export function createMockApolloProvider(stepList, initialStepIndex = 0) {
  const mockApollo = createMockApollo([], resolvers);
  mockApollo.clients.defaultClient.cache.writeQuery({
    query: stepListQuery,
    data: { stepList },
  });
  mockApollo.clients.defaultClient.cache.writeQuery({
    query: activeStepQuery,
    data: { activeStep: stepList[initialStepIndex] },
  });

  return mockApollo;
}
