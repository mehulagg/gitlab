import { GlLink } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import BoardSidebarEpicSelect from 'ee/boards/components/sidebar/board_sidebar_epic_select.vue';
import EpicsSelect from 'ee/vue_shared/components/sidebar/epics_select/base.vue';
import { stubComponent } from 'helpers/stub_component';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import getters from '~/boards/stores/getters';
import createFlash from '~/flash';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import {
  mockIssue3 as mockIssueWithoutEpic,
  mockIssueWithEpic,
  mockAssignedEpic,
} from '../../mock_data';

jest.mock('~/flash');

const mockGroupId = 7;

describe('ee/boards/components/sidebar/board_sidebar_epic_select.vue', () => {
  let wrapper;
  let store;

  afterEach(() => {
    wrapper.destroy();
    store = null;
    wrapper = null;
  });

  const createStore = ({
    initialState = {
      activeId: mockIssueWithoutEpic.id,
      boardItems: { [mockIssueWithoutEpic.id]: { ...mockIssueWithoutEpic } },
      epicsCacheById: {},
      epicFetchInProgress: false,
    },
    actionsMock = {},
  } = {}) => {
    store = new Vuex.Store({
      state: initialState,
      getters,
      actions: {
        ...actionsMock,
      },
    });
  };

  let epicsSelectHandleEditClick;

  const createWrapper = () => {
    epicsSelectHandleEditClick = jest.fn();
    wrapper = shallowMount(BoardSidebarEpicSelect, {
      store,
      provide: {
        groupId: mockGroupId,
        canUpdate: true,
      },
      stubs: {
        BoardEditableItem,
        EpicsSelect: stubComponent(EpicsSelect, {
          methods: {
            toggleFormDropdown: epicsSelectHandleEditClick,
          },
        }),
      },
    });
  };

  const findEpicSelect = () => wrapper.find({ ref: 'epicSelect' });
  const findItemWrapper = () => wrapper.find({ ref: 'sidebarItem' });
  const findCollapsed = () => wrapper.find('[data-testid="collapsed-content"]');
  const findEpicLink = () => wrapper.find(GlLink);
  const findBoardEditableItem = () => wrapper.find(BoardEditableItem);

  describe('when not editing', () => {
    it('expands the milestone dropdown on clicking edit', async () => {
      createStore();
      createWrapper();

      await findBoardEditableItem().vm.$emit('open');

      expect(epicsSelectHandleEditClick).toHaveBeenCalled();
    });
  });

  describe('when editing', () => {
    beforeEach(() => {
      createStore();
      createWrapper();

      findItemWrapper().vm.$emit('open');
      jest.spyOn(wrapper.vm.$refs.sidebarItem, 'collapse');
    });

    it('collapses BoardEditableItem on clicking edit', async () => {
      await findBoardEditableItem().vm.$emit('close');

      expect(wrapper.vm.$refs.sidebarItem.collapse).toHaveBeenCalledTimes(1);
    });

    it('collapses BoardEditableItem on hiding dropdown', async () => {
      await wrapper.find(EpicsSelect).vm.$emit('hide');

      expect(wrapper.vm.$refs.sidebarItem.collapse).toHaveBeenCalledTimes(1);
    });
  });

  it('renders "None" when no epic is assigned to the active issue', async () => {
    createStore();
    createWrapper();

    await wrapper.vm.$nextTick();

    expect(findCollapsed().text()).toBe('None');
  });

  describe('when active issue has an assigned epic', () => {
    it('fetches an epic for active issue', () => {
      const fetchEpicForActiveIssue = jest.fn(() => Promise.resolve());

      createStore({
        initialState: {
          activeId: mockIssueWithEpic.id,
          boardItems: { [mockIssueWithEpic.id]: { ...mockIssueWithEpic } },
          epicsCacheById: {},
          epicFetchInProgress: true,
        },
        actionsMock: {
          fetchEpicForActiveIssue,
        },
      });

      createWrapper();

      expect(fetchEpicForActiveIssue).toHaveBeenCalledTimes(1);
    });

    it('flashes an error message when fetch fails', async () => {
      createStore({
        initialState: {
          activeId: mockIssueWithEpic.id,
          boardItems: { [mockIssueWithEpic.id]: { ...mockIssueWithEpic } },
          epicsCacheById: {},
          epicFetchInProgress: true,
        },
        actionsMock: {
          fetchEpicForActiveIssue: jest.fn().mockRejectedValue('mayday'),
        },
      });

      createWrapper();

      await wrapper.vm.$nextTick();

      expect(createFlash).toHaveBeenCalledTimes(1);
      expect(createFlash).toHaveBeenCalledWith({
        message: wrapper.vm.$options.i18n.fetchEpicError,
        error: 'mayday',
        captureError: true,
      });
    });

    it('renders epic title when issue has an assigned epic', async () => {
      createStore({
        initialState: {
          activeId: mockIssueWithEpic.id,
          boardItems: { [mockIssueWithEpic.id]: { ...mockIssueWithEpic } },
          epicsCacheById: { [mockAssignedEpic.id]: { ...mockAssignedEpic } },
          epicFetchInProgress: false,
        },
      });

      createWrapper();

      await wrapper.vm.$nextTick();

      expect(findEpicLink().isVisible()).toBe(true);
      expect(findEpicLink().text()).toBe(mockAssignedEpic.title);
      expect(findEpicLink().attributes('href')).toBe(mockAssignedEpic.webPath);
    });
  });

  describe('when epic is selected', () => {
    beforeEach(async () => {
      createStore({
        initialState: {
          activeId: mockIssueWithoutEpic.id,
          boardItems: { [mockIssueWithoutEpic.id]: { ...mockIssueWithoutEpic } },
          epicsCacheById: {},
          epicFetchInProgress: false,
        },
      });
      createWrapper();

      jest.spyOn(wrapper.vm, 'setActiveIssueEpic').mockImplementation(async () => {
        // 'setActiveIssueEpic' sets the active issue's epic to the selected epic
        // and stores the assigned epic's data in 'epicsCacheById'
        store.state.epicFetchInProgress = true;
        store.state.boardItems[mockIssueWithoutEpic.id].epic = { ...mockAssignedEpic };
        store.state.epicsCacheById = { [mockAssignedEpic.id]: { ...mockAssignedEpic } };
        store.state.epicFetchInProgress = false;
      });

      findEpicSelect().vm.$emit('epicSelect', {
        ...mockAssignedEpic,
        id: getIdFromGraphQLId(mockAssignedEpic.id),
      });

      await wrapper.vm.$nextTick();
    });

    it('commits change to the server', () => {
      expect(wrapper.vm.setActiveIssueEpic).toHaveBeenCalledWith(mockAssignedEpic.id);
      expect(wrapper.vm.setActiveIssueEpic).toHaveBeenCalledTimes(1);
    });

    it('collapses sidebar and renders epic title', () => {
      expect(findEpicLink().isVisible()).toBe(true);
      expect(findEpicLink().text()).toBe(mockAssignedEpic.title);
      expect(findEpicLink().attributes('href')).toBe(mockAssignedEpic.webPath);
    });

    describe('when the selected epic did not change', () => {
      it('does not commit change to the server', async () => {
        createStore();
        createWrapper();
        jest.spyOn(wrapper.vm, 'setActiveIssueEpic').mockImplementation();

        findEpicSelect().vm.$emit('epicSelect', null);

        await wrapper.vm.$nextTick();

        expect(wrapper.vm.setActiveIssueEpic).not.toHaveBeenCalled();
      });
    });
  });

  describe('when no epic is selected', () => {
    beforeEach(async () => {
      createStore({
        initialState: {
          activeId: mockIssueWithEpic.id,
          boardItems: { [mockIssueWithEpic.id]: { ...mockIssueWithEpic } },
          epicsCacheById: { [mockAssignedEpic.id]: { ...mockAssignedEpic } },
          epicFetchInProgress: false,
        },
      });
      createWrapper();

      jest.spyOn(wrapper.vm, 'setActiveIssueEpic').mockImplementation(async () => {
        // Remove assigned epic from the active issue
        store.state.boardItems[mockIssueWithoutEpic.id].epic = null;
      });

      findEpicSelect().vm.$emit('epicSelect', null);

      await wrapper.vm.$nextTick();
    });

    it('collapses sidebar and renders "None"', () => {
      expect(findCollapsed().isVisible()).toBe(true);
      expect(findCollapsed().text()).toBe('None');
    });

    it('commits change to the server', () => {
      expect(wrapper.vm.setActiveIssueEpic).toHaveBeenCalledWith(null);
      expect(wrapper.vm.setActiveIssueEpic).toHaveBeenCalledTimes(1);
    });
  });

  it('flashes an error when update fails', async () => {
    createStore({
      actionsMock: {
        setActiveIssueEpic: jest.fn().mockRejectedValue('mayday'),
      },
    });

    createWrapper();

    findEpicSelect().vm.$emit('epicSelect', { id: 'foo' });

    await wrapper.vm.$nextTick();

    expect(createFlash).toHaveBeenCalledTimes(1);
    expect(createFlash).toHaveBeenCalledWith({
      message: wrapper.vm.$options.i18n.updateEpicError,
      error: 'mayday',
      captureError: true,
    });
  });
});
