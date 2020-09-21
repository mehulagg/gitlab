import { shallowMount } from '@vue/test-utils';
import BoardSidebarEpicSelect from 'ee/boards/components/sidebar/board_sidebar_epic_select.vue';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import issueSetEpic from '~/boards/queries/issue_set_epic.mutation.graphql';
import { createStore } from '~/boards/stores';

const TEST_GROUP_ID = 7;
const TEST_EPIC_ID = 8;
const TEST_EPIC = { id: 'gid://gitlab/Epic/1', title: 'Test epic' };
const TEST_ISSUE = { id: 'gid://gitlab/Issue/1', iid: 9, referencePath: 'h/b#2' };
const TEST_EPIC_SET = { data: { issueSetEpic: { issue: { ...TEST_ISSUE, epic: TEST_EPIC } } } };
const TEST_FAILED_EPIC_SET = { data: { issueSetEpic: { errors: ['mutation failed'] } } };

describe('ee/boards/components/sidebar/board_sidebar_epic_select.vue', () => {
  let wrapper;
  let store;

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const createWrapper = ({ mutationResult = TEST_EPIC_SET } = {}) => {
    store = createStore();
    jest.spyOn(store, 'dispatch').mockImplementation(() => {});
    wrapper = shallowMount(BoardSidebarEpicSelect, {
      store,
      provide: {
        groupId: TEST_GROUP_ID,
        canUpdate: true,
      },
      stubs: {
        'board-editable-item': BoardEditableItem,
      },
      mocks: {
        $apollo: {
          mutate: jest.fn().mockResolvedValue(mutationResult),
        },
      },
    });

    store.state.epics = [TEST_EPIC];
    store.state.issues = { [TEST_ISSUE.id]: TEST_ISSUE };
    store.state.activeId = TEST_ISSUE.id;
  };

  const findEpicSelect = () => wrapper.find({ ref: 'epicSelect' });
  const findCollapsed = () => wrapper.find('[data-testid="collapsed-content"]');

  it('renders "None" when no epic is selected', () => {
    createWrapper();
    expect(findCollapsed().text()).toBe('None');
  });

  describe('when epic is selected', () => {
    beforeEach(async () => {
      createWrapper();
      findEpicSelect().vm.$emit('onEpicSelect', { ...TEST_EPIC, id: TEST_EPIC_ID });
      await wrapper.vm.$nextTick();
    });

    it('collapses sidebar and renders epic title', () => {
      expect(findCollapsed().isVisible()).toBe(true);
      expect(findCollapsed().text()).toBe(TEST_EPIC.title);
    });

    it('commits change to the server', () => {
      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
        mutation: issueSetEpic,
        variables: {
          input: {
            epicId: `gid://gitlab/Epic/${TEST_EPIC_ID}`,
            iid: String(TEST_ISSUE.iid),
            projectPath: 'h/b',
          },
        },
      });
    });

    it('updates issue with the selected epic', () => {
      expect(store.state.issues[TEST_ISSUE.id].epic).toEqual(TEST_EPIC);
    });
  });

  describe('when no epic is selected', () => {
    beforeEach(async () => {
      createWrapper();
      findEpicSelect().vm.$emit('onEpicSelect', null);
      await wrapper.vm.$nextTick();
    });

    it('collapses sidebar and renders "None"', () => {
      expect(findCollapsed().isVisible()).toBe(true);
      expect(findCollapsed().text()).toBe('None');
    });

    it('does not commit changes to the server', () => {
      expect(wrapper.vm.$apollo.mutate).not.toHaveBeenCalled();
    });

    it('updates issue with a null epic', () => {
      expect(store.state.issues[TEST_ISSUE.id].epic).toBe(null);
    });
  });

  describe('when the mutation fails', () => {
    const issueWithEpic = { ...TEST_ISSUE, epic: TEST_EPIC };
    const faultyEpic = { id: 'gid://gitlab/Epic/?', title: 'Faulty epic' };

    beforeEach(async () => {
      createWrapper({ mutationResult: TEST_FAILED_EPIC_SET });
      store.state.issues = { [TEST_ISSUE.id]: { ...issueWithEpic } };
      findEpicSelect().vm.$emit('onEpicSelect', faultyEpic);
      await wrapper.vm.$nextTick();
    });

    it('collapses sidebar and renders former issue epic', () => {
      expect(findCollapsed().isVisible()).toBe(true);
      expect(findCollapsed().text()).toBe(TEST_EPIC.title);
    });

    it('does not commit changes to the store', () => {
      expect(store.state.issues[issueWithEpic.id]).toEqual(issueWithEpic);
    });
  });
});
