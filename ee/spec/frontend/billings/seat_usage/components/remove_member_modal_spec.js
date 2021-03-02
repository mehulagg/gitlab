import { GlSprintf } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import { nextTick } from 'vue';
import Vuex from 'vuex';
import RemoveMemberModal from 'ee/billings/seat_usage/components/remove_member_modal.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('RemoveMemberModal', () => {
  let wrapper;

  const defaultState = {
    namespaceName: 'foo',
    namespaceId: '1',
    memberToRemove: {
      id: 2,
      username: 'username',
      name: 'First Last',
    },
  };

  const createStore = () => {
    return new Vuex.Store({
      state: defaultState,
    });
  };

  const createComponent = (mountFn = shallowMount) => {
    wrapper = mountFn(RemoveMemberModal, {
      store: createStore(),
      stubs: {
        GlSprintf,
      },
      localVue,
    });
  };

  beforeEach(() => {
    createComponent();

    return nextTick();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('on rendering', () => {
    it('renders the submit button disabled', () => {
      expect(wrapper.attributes('ok-disabled')).toBe('true');
    });

    it('renders the title with username', () => {
      expect(wrapper.attributes('title')).toBe(
        `Remove user @${defaultState.memberToRemove.username} from your subscription`,
      );
    });

    it('renders the confirmation label with username', () => {
      expect(wrapper.find('label').text()).toContain(
        defaultState.memberToRemove.username.substring(1),
      );
    });
  });
});
