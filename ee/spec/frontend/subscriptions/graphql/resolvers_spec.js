import * as SubscriptionsApi from 'ee/api/subscriptions_api';
import { resolvers } from 'ee/subscriptions/buy_minutes/graphql/resolvers';

jest.mock('ee/api/subscriptions_api', () => {
  return {
    createSubscription: jest.fn(),
  };
});

describe('~/subscriptions/buy_minutes/graphql/resolvers', () => {
  const customer = {
    country: 'NL',
    address_1: 'Address line 1',
    address_2: 'Address line 2',
    city: 'City',
    state: 'State',
    zip_code: 'Zip code',
    company: 'My organization',
  };

  const subscription = {
    plan_id: 'abc',
    payment_method_id: 'payment_method_id',
    products: {
      main: {
        quantity: 1,
      },
    },
    gl_namespace_id: 1,
    gl_namespace_name: 'test',
    preview: 'false',
  };

  describe('Mutation', () => {
    it('calls the REST api', async () => {
      const expectedArgs = { groupId: 1, customer, subscription };

      await resolvers.Mutation.purchaseMinutes(null, expectedArgs);

      expect(SubscriptionsApi.createSubscription).toHaveBeenCalledWith(1, customer, subscription);
    });

    describe('on error', () => {
      beforeAll(() => {
        SubscriptionsApi.createSubscription.mockResolvedValue({ errors: [1] });
      });

      it('returns an error array', async () => {
        const result = await resolvers.Mutation.purchaseMinutes(null, {
          groupId: 1,
          customer,
          subscription,
        });

        expect(result).toEqual({ errors: [1] });
      });
    });

    describe('on success', () => {
      beforeAll(() => {
        SubscriptionsApi.createSubscription.mockResolvedValue({ data: '/foo' });
      });

      it('returns a redirect location', async () => {
        const result = await resolvers.Mutation.purchaseMinutes(null, {
          groupId: 1,
          customer,
          subscription,
        });

        expect(result).toEqual({ data: '/foo' });
      });
    });
  });
});
