import { shallowMount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import Vuex from 'vuex';

import BoardListHeader from 'ee/boards/components/board_list_header.vue';
import getters from 'ee/boards/stores/getters';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import { boardListQueryResponse, mockLabelList } from 'jest/boards/mock_data';
import { ListType, inactiveId } from '~/boards/constants';
import listQuery from '~/boards/graphql/board_lists_deferred.query.graphql';
import sidebarEventHub from '~/sidebar/event_hub';

const localVue = createLocalVue();

localVue.use(VueApollo);
localVue.use(Vuex);

describe('Board List Header Component', () => {
  let store;
  let wrapper;
  let fakeApollo;

  beforeEach(() => {
    store = new Vuex.Store({ state: { activeId: inactiveId }, getters });
    jest.spyOn(store, 'dispatch').mockImplementation();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
    fakeApollo = null;

    localStorage.clear();
  });

  const createComponent = ({
    listType = ListType.backlog,
    collapsed = false,
    withLocalStorage = true,
    isSwimlanesHeader = false,
    weightFeatureAvailable = false,
    listQueryHandler = jest.fn().mockResolvedValue(boardListQueryResponse()),
  } = {}) => {
    const boardId = '1';

    const listMock = {
      ...mockLabelList,
      listType,
      collapsed,
    };

    if (listType === ListType.assignee) {
      delete listMock.label;
      listMock.assignee = {};
    }

    if (withLocalStorage) {
      localStorage.setItem(
        `boards.${boardId}.${listMock.listType}.${listMock.id}.expanded`,
        (!collapsed).toString(),
      );
    }

    fakeApollo = createMockApollo([[listQuery, listQueryHandler]]);

    wrapper = shallowMount(BoardListHeader, {
      apolloProvider: fakeApollo,
      store,
      localVue,
      propsData: {
        disabled: false,
        list: listMock,
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
      createComponent();

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
        store.state.activeId = mockLabelList.id;
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
    it('weightFeatureAvailable is true', async () => {
      createComponent({ weightFeatureAvailable: true });

      await waitForPromises();

      const weightTooltip = wrapper.find({ ref: 'weightTooltip' });

      expect(weightTooltip.exists()).toBe(true);
      expect(weightTooltip.text()).toContain(boardListQueryResponse().data.boardList.totalWeight);
    });

    it('weightFeatureAvailable is false', () => {
      createComponent();

      expect(wrapper.find({ ref: 'weightTooltip' }).exists()).toBe(false);
    });
  });
});
