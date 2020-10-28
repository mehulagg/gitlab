import Vuex from 'vuex';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import { GlAlert } from '@gitlab/ui';
import EpicsSwimlanes from 'ee_component/boards/components/epics_swimlanes.vue';
import BoardColumn from 'ee_else_ce/boards/components/board_column.vue';
import getters from 'ee_else_ce/boards/stores/getters';
import { mockListsWithModel } from '../mock_data';
import BoardContent from '~/boards/components/board_content.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('BoardContent', () => {
  let wrapper;

  const defaultState = {
    isShowingEpicsSwimlanes: false,
    boardLists: mockListsWithModel,
    error: undefined,
    message: {},
  };

  const createStore = (state = defaultState) => {
    return new Vuex.Store({
      getters,
      state,
      actions: {
        dismissMessage: jest.fn(),
      },
    });
  };

  const createComponent = state => {
    const store = createStore({
      ...defaultState,
      ...state,
    });
    wrapper = shallowMount(BoardContent, {
      localVue,
      propsData: {
        lists: mockListsWithModel,
        canAdminList: true,
        disabled: false,
      },
      store,
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders a BoardColumn component per list', () => {
    expect(wrapper.findAll(BoardColumn)).toHaveLength(mockListsWithModel.length);
  });

  it('does not display EpicsSwimlanes component', () => {
    expect(wrapper.find(EpicsSwimlanes).exists()).toBe(false);
    expect(wrapper.find(GlAlert).exists()).toBe(false);
  });

  describe('with message from store', () => {
    beforeEach(() => {
      jest.spyOn(wrapper.vm.$store, 'dispatch').mockImplementation();

      wrapper.vm.$store.state.message = {
        text: 'List removed from board',
        variant: 'info',
      };
    });

    it('shows message in alert', () => {
      expect(wrapper.find(GlAlert).exists()).toBe(true);
      expect(wrapper.find(GlAlert).props('variant')).toBe('info');
    });

    it('dismisses message on close', () => {
      wrapper.find(GlAlert).vm.$emit('dismiss');

      expect(wrapper.vm.$store.dispatch).toHaveBeenCalledWith('dismissMessage');
    });
  });
});
