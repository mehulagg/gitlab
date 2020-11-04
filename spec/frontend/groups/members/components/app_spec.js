import { shallowMount, createLocalVue } from '@vue/test-utils';
import { nextTick } from 'vue';
import Vuex from 'vuex';
import { GlAlert } from '@gitlab/ui';
import App from '~/groups/members/components/app.vue';
import * as commonUtils from '~/lib/utils/common_utils';
import {
  RECEIVE_MEMBER_ROLE_ERROR,
  HIDE_ERROR,
} from '~/vuex_shared/modules/members/mutation_types';
import mutations from '~/vuex_shared/modules/members/mutations';

describe('GroupMembersApp', () => {
  const localVue = createLocalVue();
  localVue.use(Vuex);

  let wrapper;
  let store;

  const createComponent = (state = {}, options = {}) => {
    store = new Vuex.Store({
      state: {
        showError: true,
        errorMessage: 'Something went wrong, please try again.',
        ...state,
      },
      mutations,
    });

    wrapper = shallowMount(App, {
      localVue,
      store,
      ...options,
    });
  };

  const findAlert = () => wrapper.find(GlAlert);

  beforeEach(() => {
    commonUtils.scrollToElement = jest.fn();
  });

  afterEach(() => {
    wrapper.destroy();
    store = null;
  });

  describe('when `showError` is changed to `true`', () => {
    it('renders and scrolls to error alert', async () => {
      createComponent({ showError: false, errorMessage: '' });

      store.commit(RECEIVE_MEMBER_ROLE_ERROR);

      await nextTick();

      const alert = findAlert();

      expect(alert.exists()).toBe(true);
      expect(alert.text()).toBe(
        "An error occurred while updating the member's role, please try again.",
      );
      expect(commonUtils.scrollToElement).toHaveBeenCalledWith(alert.element);
    });
  });

  describe('when `showError` is changed to `false`', () => {
    it('does not render and scroll to error alert', async () => {
      createComponent();

      store.commit(HIDE_ERROR);

      await nextTick();

      expect(findAlert().exists()).toBe(false);
      expect(commonUtils.scrollToElement).not.toHaveBeenCalled();
    });
  });

  describe('when alert is dismissed', () => {
    it('hides alert', async () => {
      createComponent();

      findAlert().vm.$emit('dismiss');

      await nextTick();

      expect(findAlert().exists()).toBe(false);
    });
  });

  it('removes loading icon when component is mounted', () => {
    const loadingEl = document.createElement('div');
    loadingEl.classList.add('js-group-members-list-loading');
    document.body.appendChild(loadingEl);

    createComponent({}, { propsData: { loadingEl } });

    expect(document.querySelector('.js-group-members-list-loading')).toBeNull();
  });
});
