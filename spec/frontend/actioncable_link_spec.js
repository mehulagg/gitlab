import { print } from 'graphql';
import gql from 'graphql-tag';
import waitForPromises from 'helpers/wait_for_promises';
import cable from '~/actioncable_consumer';
import ActionCableLink from '~/actioncable_link';

describe('~/actioncable_link', () => {
  let cableLink;
  let subscription;

  const createActionCableLink = () => new ActionCableLink();
  const createOperation = () => ({
    query: gql`
      query foo {
        project {
          id
        }
      }
    `,
    variables: [],
    operationName: 'foo',
  });
  const request = (operation, onNext) => {
    if (subscription) {
      throw new Error('observable already exists!');
    }

    const observable = cableLink.request(operation);
    subscription = observable.subscribe(onNext);
  };

  beforeEach(() => {
    jest.spyOn(cable.subscriptions, 'create');

    cableLink = createActionCableLink();
  });

  afterEach(() => {
    subscription.unsubscribe();
    subscription = null;
  });

  describe('request', () => {
    it('creates a subscription', () => {
      const onNext = jest.fn();
      const operation = createOperation();

      request(operation, onNext);

      expect(cable.subscriptions.create).toHaveBeenCalledWith(
        {
          channel: 'GraphqlChannel',
          nonce: expect.any(String),
          operationName: operation.operationName,
          variables: operation.variables,
          query: print(operation.query),
        },
        { received: expect.any(Function) },
      );
    });

    it('on subscription notify', async () => {
      const onNext = jest.fn();
      const operation = createOperation();

      request(operation, onNext);

      // WHY!!! YOU NO WORKING!?

      cable.subscriptions.notifyAll('received', { result: 'test result' });

      await waitForPromises();

      cable.subscriptions.notifyAll('received', { result: 'test result 2' });

      expect(onNext.mock.calls).toEqual([['test result'], ['test result 2']]);
    });

    xit('on subscription notify with error', () => {
      const onNext = jest.fn();
      const operation = createOperation();

      request(operation, onNext);

      cable.subscriptions.notifyAll('received', { errors: [] });

      expect(onNext).toHaveBeenCalledWith('test result');
    });

    it.todo('can unsubscribe');

    it.todo('when completes it closes');
  });
});
