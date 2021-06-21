import { GlButton, GlButtonGroup } from '@gitlab/ui';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';

import BoardListHeader from 'ee/boards/components/board_list_header.vue';
import defaultGetters from 'ee/boards/stores/getters';
import { mockLabelList } from 'jest/boards/mock_data';
import { ListType, inactiveId } from '~/boards/constants';
import boardsEventHub from '~/boards/eventhub';
import sidebarEventHub from '~/sidebar/event_hub';

const localVue = createLocalVue();

localVue.use(Vuex);

describe('Board List Header Component', () => {
  let store;
  let wrapper;

  const createComponent = ({
    listType = ListType.backlog,
    collapsed = false,
    withLocalStorage = true,
    isSwimlanesHeader = false,
    weightFeatureAvailable = false,
    currentUserId = 1,
    state = { activeId: inactiveId },
    getters = {},
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

    store = new Vuex.Store({
      state,
      getters: {
        ...defaultGetters,
        ...getters,
      },
    });

    jest.spyOn(store, 'dispatch').mockImplementation();

    wrapper = shallowMount(BoardListHeader, {
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
        currentUserId,
      },
    });
  };

  const findSettingsButton = () => wrapper.find({ ref: 'settingsBtn' });

  afterEach(() => {
    wrapper.destroy();

    localStorage.clear();
  });

  describe('New epic button', () => {
    let newEpicButton;

    beforeEach(() => {
      jest.spyOn(boardsEventHub, '$emit');
      createComponent({
        getters: {
          isIssueBoard: () => false,
          isEpicBoard: () => true,
          isGroupBoard: () => true,
        },
      });
      newEpicButton = wrapper.findComponent(GlButtonGroup).findComponent(GlButton);
    });

    it('renders New epic button', () => {
      expect(newEpicButton.exists()).toBe(true);
      expect(newEpicButton.attributes()).toMatchObject({
        title: 'New epic',
        'aria-label': 'New epic',
      });
    });

    it('emits `toggle-epic-form` event on Sidebar eventHub when clicked', async () => {
      await newEpicButton.vm.$emit('click');

      expect(boardsEventHub.$emit).toHaveBeenCalledWith(`toggle-epic-form-${mockLabelList.id}`);
      expect(boardsEventHub.$emit).toHaveBeenCalledTimes(1);
    });
  });

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
        createComponent({
          listType: hasSettings[0],
          state: {
            activeId: mockLabelList.id,
          },
        });
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
