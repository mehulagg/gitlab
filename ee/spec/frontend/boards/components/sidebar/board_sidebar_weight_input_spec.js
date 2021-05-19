import { GlFormInput, GlForm } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import BoardSidebarWeightInput from 'ee/boards/components/sidebar/board_sidebar_weight_input.vue';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import { createStore } from '~/boards/stores';

const TEST_WEIGHT = 1;
const TEST_ISSUE = { id: 'gid://gitlab/Issue/1', iid: 9, weight: 0, referencePath: 'h/b#2' };

describe('ee/boards/components/sidebar/board_sidebar_weight_input.vue', () => {
  let wrapper;
  let store;

  afterEach(() => {
    wrapper.destroy();
    store = null;
    wrapper = null;
  });

  const createWrapper = ({ weight = 0 } = {}) => {
    store = createStore();
    store.state.boardItems = { [TEST_ISSUE.id]: { ...TEST_ISSUE, weight } };
    store.state.activeId = TEST_ISSUE.id;

    wrapper = shallowMount(BoardSidebarWeightInput, {
      store,
      provide: {
        canUpdate: true,
      },
      stubs: {
        'board-editable-item': BoardEditableItem,
      },
    });
  };

  const findWeightForm = () => wrapper.find(GlForm);
  const findWeightInput = () => wrapper.find(GlFormInput);
  const findResetButton = () => wrapper.find('[data-testid="reset-button"]');
  const findCollapsed = () => wrapper.find('[data-testid="collapsed-content"]');

  it('renders "None" when no weight is selected', () => {
    createWrapper();
    expect(findCollapsed().text()).toBe('None');
  });

  it('renders weight with reset button when weight is set', () => {
    createWrapper({ weight: TEST_WEIGHT });
    expect(findCollapsed().text()).toContain(TEST_WEIGHT);
    expect(findResetButton().exists()).toBe(true);
  });

  describe('when weight is submitted', () => {
    beforeEach(async () => {
      createWrapper();
      jest.spyOn(wrapper.vm, 'setActiveIssueWeight');
      findWeightInput().vm.$emit('input', TEST_WEIGHT);
      findWeightForm().vm.$emit('submit', { preventDefault: () => {} });
      store.state.boardItems[TEST_ISSUE.id].weight = TEST_WEIGHT;
      await wrapper.vm.$nextTick();
    });

    it('collapses sidebar and renders weight with reset button', () => {
      expect(findCollapsed().isVisible()).toBe(true);
      expect(findCollapsed().text()).toContain(TEST_WEIGHT);
      expect(findResetButton().exists()).toBe(true);
    });

    it('commits change to the server', () => {
      expect(wrapper.vm.setActiveIssueWeight).toHaveBeenCalledWith({
        weight: TEST_WEIGHT,
        projectPath: 'h/b',
      });
    });
  });

  describe('when weight is set to 0', () => {
    beforeEach(async () => {
      createWrapper({ weight: TEST_WEIGHT });
      jest.spyOn(wrapper.vm, 'setActiveIssueWeight');
      findWeightInput().vm.$emit('input', 0);
      findWeightForm().vm.$emit('submit', { preventDefault: () => {} });
      store.state.boardItems[TEST_ISSUE.id].weight = 0;
      await wrapper.vm.$nextTick();
    });

    it('collapses sidebar and renders "None"', () => {
      expect(wrapper.vm.setActiveIssueWeight).toHaveBeenCalled();
      expect(findCollapsed().isVisible()).toBe(true);
      expect(findCollapsed().text()).toBe('None');
    });
  });

  describe('when weight is resetted', () => {
    beforeEach(async () => {
      createWrapper({ weight: TEST_WEIGHT });
      jest.spyOn(wrapper.vm, 'setActiveIssueWeight');
      findResetButton().vm.$emit('click');
      store.state.boardItems[TEST_ISSUE.id].weight = 0;
      await wrapper.vm.$nextTick();
    });

    it('collapses sidebar and renders "None"', () => {
      expect(wrapper.vm.setActiveIssueWeight).toHaveBeenCalled();
      expect(findCollapsed().isVisible()).toBe(true);
      expect(findCollapsed().text()).toBe('None');
    });
  });

  describe('when the mutation fails', () => {
    beforeEach(async () => {
      createWrapper({ weight: TEST_WEIGHT });
      jest.spyOn(wrapper.vm, 'setActiveIssueWeight').mockImplementation(() => {
        throw new Error(['failed mutation']);
      });
      jest.spyOn(wrapper.vm, 'setError').mockImplementation(() => {});
      findWeightInput().vm.$emit('input', -1);
      findWeightForm().vm.$emit('submit', { preventDefault: () => {} });
      await wrapper.vm.$nextTick();
    });

    it('collapses sidebar and renders former issue weight', () => {
      expect(findCollapsed().isVisible()).toBe(true);
      expect(findCollapsed().text()).toContain(TEST_WEIGHT);
      expect(wrapper.vm.setError).toHaveBeenCalled();
    });
  });
});
