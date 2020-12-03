import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import ToggleLabels from 'ee/boards/components/toggle_labels';
import LocalStorageSync from '~/vue_shared/components/local_storage_sync.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('ToggleLabels component', () => {
  let wrapper;
  let setShowLabels;

  function createComponent() {
    setShowLabels = jest.fn();
    return shallowMount(ToggleLabels, {
      localVue,
      store: new Vuex.Store({
        state: {
          isShowingLabels: true,
        },
        actions: {
          setShowLabels,
        },
      }),
      stubs: {
        LocalStorageSync,
      },
    });
  }

  describe('onStorageUpdate', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    afterEach(() => {
      wrapper.destroy();
      wrapper = null;
    });

    it('parses empty value as false', async () => {
      const localStorageSync = wrapper.find(LocalStorageSync);
      localStorageSync.vm.$emit('input', '');

      await wrapper.vm.$nextTick();

      expect(setShowLabels).toHaveBeenCalledWith(expect.any(Object), false);
    });
  });
});
