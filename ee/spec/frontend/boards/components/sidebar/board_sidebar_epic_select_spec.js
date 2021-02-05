import Vuex from 'vuex';
import { shallowMount } from '@vue/test-utils';
import EpicsSelect from 'ee/vue_shared/components/sidebar/epics_select/base.vue';
import BoardSidebarEpicSelect from 'ee/boards/components/sidebar/board_sidebar_epic_select.vue';
import { stubComponent } from 'helpers/stub_component';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import getters from '~/boards/stores/getters';
import { getIdFromGraphQLId } from '~/graphql_shared/utils';
import createFlash from '~/flash';
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

  const fakeStore = ({
    initialState = {
      activeId: mockIssueWithoutEpic.id,
      issues: { [mockIssueWithoutEpic.id]: { ...mockIssueWithoutEpic } },
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
            handleEditClick: epicsSelectHandleEditClick,
          },
        }),
      },
    });
  };

  const findEpicSelect = () => wrapper.find({ ref: 'epicSelect' });
  const findItemWrapper = () => wrapper.find({ ref: 'sidebarItem' });
  const findCollapsed = () => wrapper.find('[data-testid="collapsed-content"]');

  it('renders "None" when no epic is assigned to the active issue', async () => {
    fakeStore();
    createWrapper();

    await wrapper.vm.$nextTick();

    expect(findCollapsed().text()).toBe('None');
  });

  describe('when active issue has an assigned epic', () => {
    it('fetches an epic for active issue', () => {
      const fetchEpicForActiveIssue = jest.fn(() => Promise.resolve());

      fakeStore({
        initialState: {
          activeId: mockIssueWithEpic.id,
          issues: { [mockIssueWithEpic.id]: { ...mockIssueWithEpic } },
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
      fakeStore({
        initialState: {
          activeId: mockIssueWithEpic.id,
          issues: { [mockIssueWithEpic.id]: { ...mockIssueWithEpic } },
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
      fakeStore({
        initialState: {
          activeId: mockIssueWithEpic.id,
          issues: { [mockIssueWithEpic.id]: { ...mockIssueWithEpic } },
          epicsCacheById: { [mockAssignedEpic.id]: { ...mockAssignedEpic } },
          epicFetchInProgress: false,
        },
      });

      createWrapper();

      await wrapper.vm.$nextTick();

      expect(findCollapsed().text()).toBe(mockAssignedEpic.title);
    });
  });

  it('expands the dropdown when editing', () => {
    fakeStore();
    createWrapper();

    findItemWrapper().vm.$emit('open');

    expect(epicsSelectHandleEditClick).toHaveBeenCalled();
  });

  describe('when epic is selected', () => {
    beforeEach(async () => {
      fakeStore({
        initialState: {
          activeId: mockIssueWithoutEpic.id,
          issues: { [mockIssueWithoutEpic.id]: { ...mockIssueWithoutEpic } },
          epicsCacheById: {},
          epicFetchInProgress: false,
        },
      });
      createWrapper();

      jest.spyOn(wrapper.vm, 'setActiveIssueEpic').mockImplementation(async () => {
        // 'setActiveIssueEpic' sets the active issue's epic to the selected epic
        // and stores the assigned epic's data in 'epicsCacheById'
        store.state.epicFetchInProgress = true;
        store.state.issues[mockIssueWithoutEpic.id].epic = { ...mockAssignedEpic };
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
      expect(findCollapsed().isVisible()).toBe(true);
      expect(findCollapsed().text()).toBe(mockAssignedEpic.title);
    });
  });

  describe('when no epic is selected', () => {
    beforeEach(async () => {
      fakeStore({
        initialState: {
          activeId: mockIssueWithEpic.id,
          issues: { [mockIssueWithEpic.id]: { ...mockIssueWithEpic } },
          epicsCacheById: { [mockAssignedEpic.id]: { ...mockAssignedEpic } },
          epicFetchInProgress: false,
        },
      });
      createWrapper();

      jest.spyOn(wrapper.vm, 'setActiveIssueEpic').mockImplementation(async () => {
        // Remove assigned epic from the active issue
        store.state.issues[mockIssueWithoutEpic.id].epic = null;
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
    fakeStore({
      actionsMock: {
        setActiveIssueEpic: jest.fn().mockRejectedValue('mayday'),
      },
    });

    createWrapper();

    findEpicSelect().vm.$emit('epicSelect', null);

    await wrapper.vm.$nextTick();

    expect(createFlash).toHaveBeenCalledTimes(1);
    expect(createFlash).toHaveBeenCalledWith({
      message: wrapper.vm.$options.i18n.updateEpicError,
      error: 'mayday',
      captureError: true,
    });
  });
});
