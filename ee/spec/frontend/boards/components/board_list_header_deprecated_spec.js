import { shallowMount, createLocalVue } from '@vue/test-utils';
import AxiosMockAdapter from 'axios-mock-adapter';
import Vue from 'vue';
import Vuex from 'vuex';

import BoardListHeader from 'ee/boards/components/board_list_header_deprecated.vue';
import getters from 'ee/boards/stores/getters';
import { TEST_HOST } from 'helpers/test_constants';
import { listObj } from 'jest/boards/mock_data';
import { ListType, inactiveId } from '~/boards/constants';
import List from '~/boards/models/list';
import axios from '~/lib/utils/axios_utils';
import sidebarEventHub from '~/sidebar/event_hub';

const localVue = createLocalVue();

localVue.use(Vuex);

describe('Board List Header Component', () => {
  let store;
  let wrapper;
  let axiosMock;

  beforeEach(() => {
    window.gon = {};
    axiosMock = new AxiosMockAdapter(axios);
    axiosMock.onGet(`${TEST_HOST}/lists/1/issues`).reply(200, { issues: [] });
    store = new Vuex.Store({ state: { activeId: inactiveId }, getters });
    jest.spyOn(store, 'dispatch').mockImplementation();
  });

  afterEach(() => {
    axiosMock.restore();

    wrapper.destroy();

    localStorage.clear();
  });

  const createComponent = ({
    listType = ListType.backlog,
    collapsed = false,
    withLocalStorage = true,
    currentUserId = 1,
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

    // Making List reactive
    const list = Vue.observable(new List(listMock));

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
      },
      provide: {
        currentUserId,
        boardId,
      },
    });
  };

  const findSettingsButton = () => wrapper.find({ ref: 'settingsBtn' });

  describe('Settings Button', () => {
    const hasSettings = [ListType.assignee, ListType.milestone, ListType.iteration, ListType.label];
    const hasNoSettings = [ListType.backlog, ListType.closed];

    it.each(hasSettings)('does render for List Type `%s`', (listType) => {
      createComponent({ listType });

      expect(findSettingsButton().exists()).toBe(true);
    });

    it.each(hasNoSettings)('does not render for List Type `%s`', (listType) => {
      createComponent({ listType });

      expect(findSettingsButton().exists()).toBe(false);
    });

    it('has a test for each list type', () => {
      Object.values(ListType).forEach((value) => {
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
});
