import Vue from 'vue';
import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import AxiosMockAdapter from 'axios-mock-adapter';

import Board from 'ee/boards/components/board_column.vue';
import List from '~/boards/models/list';
import { ListType, inactiveListId } from '~/boards/constants';
import axios from '~/lib/utils/axios_utils';
import sidebarEventHub from '~/sidebar/event_hub';

import { TEST_HOST } from 'helpers/test_constants';
import { listObj } from 'jest/boards/mock_data';

// board_promotion_state tries to mount on the real DOM,
// so we are mocking it in this test
jest.mock('ee/boards/components/board_promotion_state', () => ({}));

const localVue = createLocalVue();

localVue.use(Vuex);

describe('Board Column Component', () => {
  let store;
  let wrapper;
  let axiosMock;

  beforeEach(() => {
    window.gon = {};
    axiosMock = new AxiosMockAdapter(axios);
    axiosMock.onGet(`${TEST_HOST}/lists/1/issues`).reply(200, { issues: [] });
    store = new Vuex.Store({ state: { activeListId: inactiveListId } });
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

    wrapper = shallowMount(Board, {
      store,
      localVue,
      propsData: {
        boardId,
        disabled: false,
        issueLinkBase: '/',
        rootPath: '/',
        list,
      },
    });
  };

  const findSettingsButton = () => wrapper.find({ ref: 'settingsBtn' });

  describe('Settings Button', () => {
    it.each(Object.values(ListType))(
      'when feature flag is off: does not render for List Type `%s`',
      listType => {
        window.gon = {
          features: {
            wipLimits: false,
          },
        };
        createComponent({ listType });

        expect(findSettingsButton().exists()).toBe(false);
      },
    );

    describe('when feature flag is on', () => {
      const hasSettings = [ListType.assignee, ListType.milestone, ListType.label];
      const hasNoSettings = [ListType.backlog, ListType.blank, ListType.closed, ListType.promotion];

      beforeEach(() => {
        window.gon = {
          features: {
            wipLimits: true,
          },
        };
      });

      it.each(hasSettings)('does render for List Type `%s`', listType => {
        createComponent({ listType });

        expect(findSettingsButton().exists()).toBe(true);
      });

      it.each(hasNoSettings)('does not render for List Type `%s`', listType => {
        createComponent({ listType });

        expect(findSettingsButton().exists()).toBe(false);
      });

      it('has a test for each list type', () => {
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

        it('does not emits event when there is an active List', () => {
          store.state.activeListId = listObj.id;
          createComponent({ listType: hasSettings[0] });
          wrapper.vm.openSidebarSettings();

          expect(sidebarEventHub.$emit).not.toHaveBeenCalled();
        });
      });
    });
  });
});
