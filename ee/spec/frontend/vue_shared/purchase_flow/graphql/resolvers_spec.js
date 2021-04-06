import { createMockClient } from 'mock-apollo-client';
import activateNextStepMutation from 'ee/vue_shared/purchase_flow/graphql/mutations/activate_next_step.mutation.graphql';
import updateStepMutation from 'ee/vue_shared/purchase_flow/graphql/mutations/update_active_step.mutation.graphql';
import activeStepQuery from 'ee/vue_shared/purchase_flow/graphql/queries/active_step.query.graphql';
import stepListQuery from 'ee/vue_shared/purchase_flow/graphql/queries/step_list.query.graphql';
import resolvers from 'ee/vue_shared/purchase_flow/graphql/resolvers';
import typeDefs from 'ee/vue_shared/purchase_flow/graphql/typedefs.graphql';
import { STEPS } from '../mock_data';

describe('ee/vue_shared/purchase_flow/graphql/resolvers', () => {
  let mockClient;

  beforeEach(async () => {
    mockClient = createMockClient({ resolvers, typeDefs });
    mockClient.cache.writeQuery({
      query: stepListQuery,
      data: {
        stepList: STEPS,
      },
    });
    mockClient.cache.writeQuery({
      query: activeStepQuery,
      data: {
        activeStep: STEPS[0],
      },
    });
  });

  describe('Query', () => {
    describe('stepListQuery', () => {
      it('stores the stepList', async () => {
        const queryResult = await mockClient.query({ query: stepListQuery });
        expect(queryResult.data.stepList).toMatchObject(
          STEPS.map(({ id }) => {
            return { id };
          }),
        );
      });

      it('throws an error when cache is not initiated properly', async () => {
        mockClient.clearStore();
        await mockClient.query({ query: stepListQuery }).catch((e) => {
          expect(e instanceof Error).toBe(true);
        });
      });
    });

    describe('activeStepQuery', () => {
      it('stores the activeStep', async () => {
        const queryResult = await mockClient.query({ query: activeStepQuery });
        expect(queryResult.data.activeStep).toMatchObject({ id: STEPS[0].id });
      });

      it('throws an error when cache is not initiated properly', async () => {
        mockClient.clearStore();
        await mockClient.query({ query: activeStepQuery }).catch((e) => {
          expect(e instanceof Error).toBe(true);
        });
      });
    });
  });

  describe('Mutation', () => {
    describe('updateActiveStep', () => {
      it('updates the active step', async () => {
        await mockClient.mutate({
          mutation: updateStepMutation,
          variables: { id: STEPS[1].id },
        });
        const queryResult = await mockClient.query({ query: activeStepQuery });
        expect(queryResult.data.activeStep).toMatchObject({ id: STEPS[1].id });
      });

      it('throws an error when STEP is not present', async () => {
        const id = 'does not exist';
        await mockClient
          .mutate({
            mutation: updateStepMutation,
            variables: { id },
          })
          .catch((e) => {
            expect(e instanceof Error).toBe(true);
          });
      });

      it('throws an error when cache is not initiated properly', async () => {
        mockClient.clearStore();
        await mockClient
          .mutate({
            mutation: updateStepMutation,
            variables: { id: STEPS[1].id },
          })
          .catch((e) => {
            expect(e instanceof Error).toBe(true);
          });
      });
    });

    describe('activateNextStep', () => {
      it('updates the active step to the next', async () => {
        await mockClient.mutate({
          mutation: activateNextStepMutation,
        });
        const queryResult = await mockClient.query({ query: activeStepQuery });
        expect(queryResult.data.activeStep).toMatchObject({ id: STEPS[1].id });
      });

      it('throws an error when out of bounds', async () => {
        await mockClient.mutate({
          mutation: activateNextStepMutation,
        });

        await mockClient
          .mutate({
            mutation: activateNextStepMutation,
          })
          .catch((e) => {
            expect(e instanceof Error).toBe(true);
          });
      });

      it('throws an error when cache is not initiated properly', async () => {
        mockClient.clearStore();
        await mockClient
          .mutate({
            mutation: activateNextStepMutation,
          })
          .catch((e) => {
            expect(e instanceof Error).toBe(true);
          });
      });
    });
  });
});
