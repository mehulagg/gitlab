import Vuex from 'vuex';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import { GlDropdown } from '@gitlab/ui';
import BoardSidebarIteration from 'ee/boards/components/sidebar/board_sidebar_iteration.vue';
import IterationSelect from 'ee/sidebar/components/iteration_select.vue';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import getters from '~/boards/stores/getters';
import { mockIssue, mockIteration } from '../../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('~/boards/components/sidebar/board_sidebar_iteration.vue', () => {
  let wrapper;
  let store;

  afterEach(() => {
    wrapper.destroy();
    store = null;
    wrapper = null;
  });

  const fakeStore = ({
    initialState = {
      issues: { [mockIssue.id]: { ...mockIssue } },
      activeId: mockIssue.id,
    },
  } = {}) => {
    store = new Vuex.Store({
      state: {
        ...initialState,
      },
      getters,
    });
  };

  const createWrapper = ({
    data = {},
    stubs = {
      BoardEditableItem,
    },
  } = {}) => {
    fakeStore();

    wrapper = shallowMount(BoardSidebarIteration, {
      store,
      localVue,
      provide: {
        canUpdate: true,
      },
      data: () => ({
        currentIteration: null,
        editing: false,
        ...data,
      }),
      stubs,
    });
  };

  const findCollapsed = () => wrapper.find('[data-testid="collapsed-content"]');
  const findDropdown = () => wrapper.find(GlDropdown);
  const findEditableItem = () => wrapper.find(BoardEditableItem);
  const findIterationSelect = () => wrapper.find(IterationSelect);

  describe('when the issue belongs to an iteration', () => {
    beforeEach(() => {
      createWrapper({ data: { currentIteration: mockIteration } });
    });

    it('renders the title of the iteration', () => {
      expect(findCollapsed().isVisible()).toBe(true);
      expect(findCollapsed().text()).toContain(mockIteration.title);
    });

    describe('when user removes the iteration', () => {
      beforeEach(async () => {
        findEditableItem().vm.$emit('open');

        await wrapper.vm.$nextTick();

        findIterationSelect().vm.$emit('iterationUpdate', null);
        findIterationSelect().vm.$emit('dropdownClose');

        await wrapper.vm.$nextTick();
      });

      it("renders 'None'", () => {
        expect(findCollapsed().isVisible()).toBe(true);
        expect(findCollapsed().text()).toBe('None');
      });

      it('closes the dropdown', () => {
        expect(findDropdown().exists()).toBe(false);
      });
    });
  });

  describe("when the issue doesn't belong to any iteration", () => {
    beforeEach(() => {
      createWrapper();
    });

    it("renders 'None' by default", () => {
      expect(findCollapsed().isVisible()).toBe(true);
      expect(findCollapsed().text()).toBe('None');
    });

    describe('when user selects an iteration', () => {
      beforeEach(async () => {
        findEditableItem().vm.$emit('open');

        await wrapper.vm.$nextTick();

        findIterationSelect().vm.$emit('iterationUpdate', mockIteration);
        findIterationSelect().vm.$emit('dropdownClose');

        await wrapper.vm.$nextTick();
      });

      it('renders the title of the selected iteration', () => {
        expect(findCollapsed().isVisible()).toBe(true);
        expect(findCollapsed().text()).toBe(mockIteration.title);
      });

      it('Closes the dropdown', () => {
        expect(findDropdown().exists()).toBe(false);
      });
    });
  });

  describe('when edit button is clicked', () => {
    beforeEach(async () => {
      createWrapper({ stubs: { BoardEditableItem, IterationSelect } });

      jest.spyOn(findIterationSelect().vm, 'setFocus').mockImplementation();
      jest.spyOn(findIterationSelect().vm, 'showDropdown').mockImplementation();

      findEditableItem().vm.$emit('open');
      await wrapper.vm.$nextTick();
    });

    it('expands the dropdown', async () => {
      expect(findDropdown().exists()).toBe(true);
    });

    describe('when edit button is clicked again', () => {
      beforeEach(async () => {
        findEditableItem().vm.$emit('close');
        await wrapper.vm.$nextTick();
      });

      it('collapses the dropdown', async () => {
        expect(findDropdown().exists()).toBe(false);
      });

      it("renders 'None'", async () => {
        expect(findCollapsed().isVisible()).toBe(true);
        expect(findCollapsed().text()).toBe('None');
      });
    });
  });
});
