import '~/boards/models/list';
import MockAdapter from 'axios-mock-adapter';
import axios from 'axios';
import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import { GlDrawer, GlLabel } from '@gitlab/ui';
import BoardSettingsSidebar from '~/boards/components/board_settings_sidebar.vue';
import boardsStore from '~/boards/stores/boards_store';
import getters from '~/boards/stores/getters';
import realActions from '~/boards/stores/actions';
import mutations from '~/boards/stores/mutations';
import sidebarEventHub from '~/sidebar/event_hub';
import { inactiveId, sidebarTypes } from '~/boards/constants';

const localVue = createLocalVue();

localVue.use(Vuex);

describe('BoardSettingsSidebar', () => {
  let wrapper;
  let mock;
  let storeActions;
  const labelTitle = 'test';
  const labelColor = '#FFFF';
  const listId = 1;

  const createComponent = (
    state = { activeId: inactiveId, sidebarType: sidebarTypes.list },
    actions = {},
  ) => {
    storeActions = actions;

    const store = new Vuex.Store({
      state,
      getters,
      mutations,
      actions: { ...realActions, ...storeActions },
    });

    wrapper = shallowMount(BoardSettingsSidebar, {
      store,
      localVue,
    });
  };
  const findLabel = () => wrapper.find(GlLabel);
  const findDrawer = () => wrapper.find(GlDrawer);

  beforeEach(() => {
    boardsStore.create();
  });

  afterEach(() => {
    jest.restoreAllMocks();
    wrapper.destroy();
  });

  describe('when sidebarType is "list"', () => {
    it('finds a GlDrawer component', () => {
      createComponent();

      expect(findDrawer().exists()).toBe(true);
    });

    describe('on close', () => {
      it('closes the sidebar', async () => {
        const spy = jest.fn();
        createComponent(
          { activeId: inactiveId, sidebarType: sidebarTypes.list },
          // { unsetActiveId: spy },
        );

        findDrawer().vm.$emit('close');

        await wrapper.vm.$nextTick();

        expect(wrapper.find(GlDrawer).exists()).toBe(false);
      });

      it('closes the sidebar when emitting the correct event', async () => {
        createComponent({ activeId: inactiveId });

        sidebarEventHub.$emit('sidebar.closeAll');

        await wrapper.vm.$nextTick();

        expect(wrapper.find(GlDrawer).exists()).toBe(false);
      });
    });

    describe('when activeId is zero', () => {
      it('renders GlDrawer with open false', () => {
        createComponent();

        expect(findDrawer().props('open')).toBe(false);
      });
    });

    describe('when activeId is greater than zero', () => {
      beforeEach(() => {
        mock = new MockAdapter(axios);

        boardsStore.addList({
          id: listId,
          label: { title: labelTitle, color: labelColor },
          list_type: 'label',
        });
      });

      afterEach(() => {
        boardsStore.removeList(listId);
      });

      it('renders GlDrawer with open false', () => {
        createComponent({ activeId: 1, sidebarType: sidebarTypes.list });

        expect(findDrawer().props('open')).toBe(true);
      });
    });

    describe('when activeId is in boardsStore', () => {
      beforeEach(() => {
        mock = new MockAdapter(axios);

        boardsStore.addList({
          id: listId,
          label: { title: labelTitle, color: labelColor },
          list_type: 'label',
        });

        createComponent({ activeId: listId, sidebarType: sidebarTypes.list });
      });

      afterEach(() => {
        mock.restore();
      });

      it('renders label title', () => {
        expect(findLabel().props('title')).toBe(labelTitle);
      });

      it('renders label background color', () => {
        expect(findLabel().props('backgroundColor')).toBe(labelColor);
      });
    });

    describe('when activeId is not in boardsStore', () => {
      beforeEach(() => {
        mock = new MockAdapter(axios);

        boardsStore.addList({ id: listId, label: { title: labelTitle, color: labelColor } });

        createComponent({ activeId: inactiveId });
      });

      afterEach(() => {
        mock.restore();
      });

      it('does not render GlLabel', () => {
        expect(findLabel().exists()).toBe(false);
      });
    });
  });

  describe('when sidebarType is not List', () => {
    beforeEach(() => {
      createComponent({ activeId: listId });
    });

    it('does not render GlDrawer', () => {
      expect(findDrawer().exists()).toBe(false);
    });
  });
});
