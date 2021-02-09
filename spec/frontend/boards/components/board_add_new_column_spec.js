import Vue, { nextTick } from 'vue';
import Vuex from 'vuex';
import { mount } from '@vue/test-utils';

import defaultState from '~/boards/stores/state';
import BoardAddNewColumn from '~/boards/components/board_add_new_column.vue';
import { mockLabelList, mockIssue } from '../mock_data';

Vue.use(Vuex);

describe('Board card layout', () => {
  let wrapper;
  let store;

  const createStore = ({ getters = {}, actions = {} } = {}) => {
    return new Vuex.Store({
      state: defaultState,
      actions,
      getters,
    });
  };

  const mountComponent = ({ actions = {}, getters = { shouldUseGraphQL: () => false } } = {}) => {
    wrapper = mount(BoardAddNewColumn, {
      stubs: {
        GlFormGroup: true,
      },
      data() {
        return {
          loading: true,
        };
      },
      store: createStore({
        actions: { fetchLabels: jest.fn() },
        getters: { shouldUseGraphQL: () => true },
      }),
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  // shows column title
  // shows label dropdown
  // searching labels
  // makes coorect query or some shit
  // cancel button
  // submit button
  // disabled
  // on click

  const formTitle = () => wrapper.findByTestId('board-add-column-form-title').text();
  const skeletonLoader = () => wrapper.find('gl-skeleton-loader');

  // shouldUseGraphQL true
  describe('with vuex store', () => {
    beforeEach(() => {
      mountComponent();
    });

    it('shows form title, search field, and skeleton loader', async () => {
      expect(formTitle()).toEqual(BoardAddNewColumn.i18n.newLabelList);
    });
  });

  // shouldUseGraphQL false
  // describe('with boards_store', () => {

  // });
});
