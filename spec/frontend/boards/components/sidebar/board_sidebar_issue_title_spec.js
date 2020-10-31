import { shallowMount } from '@vue/test-utils';
import { GlFormInput, GlForm } from '@gitlab/ui';
import BoardSidebarIssueTitle from '~/boards/components/sidebar/board_sidebar_issue_title.vue';
import BoardEditableItem from '~/boards/components/sidebar/board_editable_item.vue';
import createFlash from '~/flash';
import { createStore } from '~/boards/stores';

const TEST_TITLE = 'New issue title';
const TEST_ISSUE = { id: 'gid://gitlab/Issue/1', iid: 9, title: 'Issue 1', referencePath: 'h/b#2' };

jest.mock('~/flash');

describe('~/boards/components/sidebar/board_sidebar_issue_title.vue', () => {
  let wrapper;
  let store;

  afterEach(() => {
    wrapper.destroy();
    store = null;
    wrapper = null;
  });

  const createWrapper = ({ title = 'Issue 1' } = {}) => {
    store = createStore();
    store.state.issues = { [TEST_ISSUE.id]: { ...TEST_ISSUE, title } };
    store.state.activeId = TEST_ISSUE.id;

    wrapper = shallowMount(BoardSidebarIssueTitle, {
      store,
      provide: {
        canUpdate: true,
      },
      stubs: {
        'board-editable-item': BoardEditableItem,
      },
    });
  };

  const findForm = () => wrapper.find(GlForm);
  const findFormInput = () => wrapper.find(GlFormInput);
  const findCancelButton = () => wrapper.find('[data-testid="cancel-button"]');
  const findTitle = () => wrapper.find('[data-testid="issue-title"]');
  const findCollapsed = () => wrapper.find('[data-testid="collapsed-content"]');

  it('renders title and reference', () => {
    createWrapper();

    expect(findTitle().text()).toContain(TEST_ISSUE.title);
    expect(findCollapsed().text()).toContain(TEST_ISSUE.referencePath);
  });

  describe('when new title is submitted', () => {
    beforeEach(async () => {
      createWrapper();

      jest.spyOn(wrapper.vm, 'setActiveIssueTitle').mockImplementation(() => {
        store.state.issues[TEST_ISSUE.id].title = TEST_TITLE;
      });
      findFormInput().vm.$emit('input', TEST_TITLE);
      findForm().vm.$emit('submit', { preventDefault: () => {} });
      await wrapper.vm.$nextTick();
    });

    it('collapses sidebar and renders new title', () => {
      expect(findCollapsed().isVisible()).toBe(true);
      expect(findTitle().text()).toContain(TEST_TITLE);
    });

    it('commits change to the server', () => {
      expect(wrapper.vm.setActiveIssueTitle).toHaveBeenCalledWith({
        title: TEST_TITLE,
        projectPath: 'h/b',
      });
    });
  });

  describe('when cancel button is clicked', () => {
    beforeEach(async () => {
      createWrapper({ title: 'Issue 2' });

      jest.spyOn(wrapper.vm, 'setActiveIssueTitle').mockImplementation(() => {
        store.state.issues[TEST_ISSUE.id].title = TEST_TITLE;
      });
      findFormInput().vm.$emit('input', TEST_TITLE);
      findCancelButton().vm.$emit('click');
      await wrapper.vm.$nextTick();
    });

    it('collapses sidebar and render former title', () => {
      expect(wrapper.vm.setActiveIssueTitle).not.toHaveBeenCalled();
      expect(findCollapsed().isVisible()).toBe(true);
      expect(findTitle().text()).toBe('Issue 2');
    });
  });

  describe('when the mutation fails', () => {
    beforeEach(async () => {
      createWrapper({ title: TEST_TITLE });

      jest.spyOn(wrapper.vm, 'setActiveIssueTitle').mockImplementation(() => {
        throw new Error(['failed mutation']);
      });
      findFormInput().vm.$emit('input', '');
      findForm().vm.$emit('submit', { preventDefault: () => {} });
      await wrapper.vm.$nextTick();
    });

    it('collapses sidebar and renders former issue title', () => {
      expect(findCollapsed().isVisible()).toBe(true);
      expect(findTitle().text()).toContain(TEST_TITLE);
      expect(createFlash).toHaveBeenCalled();
    });
  });
});
