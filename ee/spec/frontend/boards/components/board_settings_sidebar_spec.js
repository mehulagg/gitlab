import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';
import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import { GlDrawer, GlLabel } from '@gitlab/ui';
import BoardSettingsSidebar from 'ee/boards/components/board_settings_sidebar.vue';
import boardsStore from '~/boards/stores/boards_store';

// NOTE: needed for calling boardsStore.addList
import '~/boards/models/list';

const localVue = createLocalVue();

localVue.use(Vuex);

describe('BoardSettingsSideBar', () => {
  let wrapper;
  let mock;
  let storeActions;
  const labelTitle = 'test';
  const labelColor = '#FFFF';
  const listId = 1;

  const createComponent = (state = {}, actions = {}) => {
    storeActions = actions;

    const store = new Vuex.Store({
      state,
      actions: storeActions,
    });

    wrapper = shallowMount(BoardSettingsSidebar, {
      sync: false,
      store,
      localVue,
    });
  };

  beforeEach(() => {
    boardsStore.create();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('GlDrawer', () => {
    it('finds a GlDrawer component', () => {
      createComponent();

      expect(wrapper.find(GlDrawer).exists()).toBe(true);
    });

    describe('on close', () => {
      it('calls closeSidebar', done => {
        const spy = jest.fn();
        createComponent({}, { setActiveListId: spy });

        wrapper.find(GlDrawer).vm.$emit('close');

        return wrapper.vm
          .$nextTick()
          .then(() => {
            expect(storeActions.setActiveListId).toHaveBeenCalledWith(
              expect.anything(),
              0,
              undefined,
            );
          })
          .then(done)
          .catch(done.fail);
      });
    });

    describe('when activeListId is zero', () => {
      it('renders GlDrawer with open false', () => {
        createComponent();

        expect(wrapper.find(GlDrawer).props('open')).toBe(false);
      });
    });

    describe('when activeListId is greater than zero', () => {
      it('renders GlDrawer with open false', () => {
        createComponent({ activeListId: 1 });

        expect(wrapper.find(GlDrawer).props('open')).toBe(true);
      });
    });

    describe('when activeListId is in boardsStore', () => {
      beforeEach(() => {
        mock = new MockAdapter(axios);

        boardsStore.addList({ id: listId, label: { title: labelTitle, color: labelColor } });

        createComponent({ activeListId: listId });
      });

      afterEach(() => {
        mock.restore();
      });

      it('renders label title', () => {
        expect(wrapper.find(GlLabel).props('title')).toEqual(labelTitle);
      });

      it('renders label background color', () => {
        expect(wrapper.find(GlLabel).props('backgroundColor')).toEqual(labelColor);
      });
    });

    describe('when activeListId is not in boardsStore', () => {
      beforeEach(() => {
        mock = new MockAdapter(axios);

        boardsStore.addList({ id: listId, label: { title: labelTitle, color: labelColor } });

        createComponent({ activeListId: 0 });
      });

      afterEach(() => {
        mock.restore();
      });

      it('renders label title', () => {
        expect(wrapper.find(GlLabel).props('title')).toEqual('');
      });

      it('renders label background color', () => {
        expect(wrapper.find(GlLabel).props('backgroundColor')).toEqual('');
      });
    });
  });
});
