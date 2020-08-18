import { nextTick } from 'vue';
import { shallowMount } from '@vue/test-utils';
import WatchStoreMutation from '~/vue_shared/components/watch_store_mutation.vue';

describe('WatchStoreMutation', () => {
  let wrapper;

  const createComponent = ({ store, mutationType }) =>
    shallowMount(WatchStoreMutation, {
      mocks: { $store: store },
      propsData: {
        type: mutationType,
      },
    });

  const generateStoreMock = () => {
    const unsubscribeMock = jest.fn();
    const storeMock = {
      subscribe: jest.fn().mockImplementation(fn => {
        storeMock.subscriber = fn;
        return unsubscribeMock;
      }),
      unsubscribeMock,
    };

    return storeMock;
  };

  const store = generateStoreMock();
  const EXPECTED_MUTATION_TYPE = 'DEMO_MUTATION';

  beforeEach(() => {
    wrapper = createComponent({ store, mutationType: EXPECTED_MUTATION_TYPE });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when used with single vuex store', () => {
    it('reacts to expected mutation by emitting event with mutation payload', async () => {
      const PAYLOAD = {};

      store.subscriber({
        type: EXPECTED_MUTATION_TYPE,
        payload: PAYLOAD,
      });

      await nextTick();

      expect(wrapper.emitted().mutation).toStrictEqual([[PAYLOAD]]);
    });

    it('does not react to other mutation', async () => {
      store.subscriber({ type: 'SOME_OTHER_MUTATION' });
      await nextTick();

      expect(wrapper.emitted().mutation).toBeUndefined();
    });

    it('subscribes to store exactly one time', async () => {
      const otherWrapper = createComponent({ store, mutationType: 'SOME_OTHER_MUTATION' });

      try {
        await nextTick();

        expect(store.subscribe.mock.calls).toHaveLength(1);
      } finally {
        otherWrapper.destroy();
      }
    });

    describe('when mutation type dynamically changes', () => {
      const NEW_MUTATION_TYPE = 'NEW_MUTATION_TYPE';

      beforeEach(() => {
        wrapper.setProps({ type: NEW_MUTATION_TYPE });
        return nextTick();
      });

      it('reacts to new mutation type', async () => {
        store.subscriber({ type: NEW_MUTATION_TYPE });
        await nextTick();

        expect(wrapper.emitted().mutation).toStrictEqual([[undefined]]);
      });

      it('does not react to old mutation type', async () => {
        store.subscriber({ type: EXPECTED_MUTATION_TYPE });
        await nextTick();

        expect(wrapper.emitted().mutation).toBeUndefined();
      });
    });

    it('does not unsubscribes from store when other component instances are present', () => {
      const otherWrapper = createComponent({ store, mutationType: EXPECTED_MUTATION_TYPE });

      otherWrapper.destroy();

      expect(store.unsubscribeMock).not.toHaveBeenCalled();
    });

    it('unsubscribes from store when last instance of component is destroyed', async () => {
      wrapper.destroy();

      await nextTick();

      expect(store.unsubscribeMock).toHaveBeenCalled();
    });
  });

  describe('when used with multiple stores', () => {
    const otherStore = generateStoreMock();
    let otherWrapper;

    beforeEach(() => {
      otherWrapper = createComponent({ store: otherStore, mutationType: EXPECTED_MUTATION_TYPE });
    });

    afterEach(() => {
      otherWrapper.destroy();
    });

    it('does not react to same mutation on other store', () => {
      otherStore.subscriber({ type: EXPECTED_MUTATION_TYPE });

      expect(wrapper.emitted().mutation).toBeUndefined();
    });

    it('unsubscribes from relevant stores', () => {
      otherWrapper.destroy();

      expect(otherStore.unsubscribeMock).toHaveBeenCalled();
      expect(store.unsubscribeMock).not.toHaveBeenCalled();
    });
  });
});
