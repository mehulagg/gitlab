import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';

import BoardListHeader from 'ee/boards/components/board_list_header_new.vue';
import getters from 'ee/boards/stores/getters';
import { listObj } from 'jest/boards/mock_data';
import { ListType, inactiveId } from '~/boards/constants';
import List from '~/boards/models/list';
import sidebarEventHub from '~/sidebar/event_hub';

// board_promotion_state tries to mount on the real DOM,
// so we are mocking it in this test
jest.mock('ee/boards/components/board_promotion_state', () => ({}));

const localVue = createLocalVue();

localVue.use(Vuex);

describe('Board List Header Component', () => {
  let store;
  let wrapper;

  beforeEach(() => {
    store = new Vuex.Store({ state: { activeId: inactiveId }, getters });
    jest.spyOn(store, 'dispatch').mockImplementation();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;

    localStorage.clear();
  });

  const createComponent = ({
    listType = ListType.backlog,
    collapsed = false,
    withLocalStorage = true,
    isSwimlanesHeader = false,
    weightFeatureAvailable = false,
  } = {}) => {
    const boardId = '1';

    const listMock = {
      ...listObj,
      list_type: listType,
      collapsed,
    };

    if (listType === ListType.assignee) {
      delete listMock.label;
      listMock.user = {};
    }

    const list = new List({ ...listMock, doNotFetchIssues: true });

    if (withLocalStorage) {
      localStorage.setItem(
        `boards.${boardId}.${list.type}.${list.id}.expanded`,
        (!collapsed).toString(),
      );
    }

    wrapper = shallowMount(BoardListHeader, {
      store,
      localVue,
      propsData: {
        disabled: false,
        list,
        isSwimlanesHeader,
      },
      provide: {
        boardId,
        weightFeatureAvailable,
      },
    });
  };

  const findSettingsButton = () => wrapper.find({ ref: 'settingsBtn' });

  describe('Settings Button', () => {
    const hasSettings = [ListType.assignee, ListType.milestone, ListType.label];
    const hasNoSettings = [ListType.backlog, ListType.blank, ListType.closed, ListType.promotion];

    it.each(hasSettings)('does render for List Type `%s`', listType => {
      createComponent({ listType });

      expect(findSettingsButton().exists()).toBe(true);
    });

    it.each(hasNoSettings)('does not render for List Type `%s`', listType => {
      createComponent({ listType });

      expect(findSettingsButton().exists()).toBe(false);
    });

    it('has a test for each list type', () => {
      createComponent();

      Object.values(ListType).forEach(value => {
        expect([...hasSettings, ...hasNoSettings]).toContain(value);
      });
    });

    describe('emits sidebar.closeAll event on openSidebarSettings', () => {
      beforeEach(() => {
        jest.spyOn(sidebarEventHub, '$emit');
      });

      it('emits event if no active List', () => {
        // Shares the same behavior for any settings-enabled List type
        createComponent({ listType: hasSettings[0] });
        wrapper.vm.openSidebarSettings();

        expect(sidebarEventHub.$emit).toHaveBeenCalledWith('sidebar.closeAll');
      });

      it('does not emit event when there is an active List', () => {
        store.state.activeId = listObj.id;
        createComponent({ listType: hasSettings[0] });
        wrapper.vm.openSidebarSettings();

        expect(sidebarEventHub.$emit).not.toHaveBeenCalled();
      });
    });
  });

  describe('Swimlanes header', () => {
    it('when collapsed, it displays info icon', () => {
      createComponent({ isSwimlanesHeader: true, collapsed: true });

      expect(wrapper.find('.board-header-collapsed-info-icon').exists()).toBe(true);
    });
  });

  describe('weightFeatureAvailable', () => {
    it('weightFeatureAvailable is true', () => {
      createComponent({ weightFeatureAvailable: true });

      expect(wrapper.find({ ref: 'weightTooltip' }).exists()).toBe(true);
    });

    it('weightFeatureAvailable is false', () => {
      createComponent();

      expect(wrapper.find({ ref: 'weightTooltip' }).exists()).toBe(false);
    });
  });
});
