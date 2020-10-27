import { mount } from '@vue/test-utils';
import { GlDropdownItem } from '@gitlab/ui';
import BoardAssigneeDropdown from '~/boards/components/board_assignee_dropdown.vue';
import IssuableAssignees from '~/sidebar/components/assignees/issuable_assignees.vue';
import AssigneesDropdown from '~/vue_shared/components/sidebar/assignees_dropdown.vue';
import store from '~/boards/stores';

describe('BoardCardAssigneeDropdown', () => {
  let wrapper;
  const iid = '111';
  const activeIssueName = 'test';

  const createComponent = () => {
    wrapper = mount(BoardAssigneeDropdown, {
      store,
      provide: {
        canUpdate: true,
        rootPath: '',
      },
    });
  };

  const unassign = () => {
    wrapper.find('[data-testid="unassign"]').trigger('click');
  };

  const openDropdown = async () => {
    wrapper.find('[data-testid="edit-button"]').trigger('click');

    await wrapper.vm.$nextTick();
  };

  const findByText = text => {
    return wrapper.findAll(GlDropdownItem).wrappers.find(x => x.text().indexOf(text) === 0);
  };

  beforeEach(() => {
    store.state.activeId = '1';
    store.state.issues = {
      '1': {
        iid,
        assignees: [{ username: activeIssueName, name: activeIssueName, id: activeIssueName }],
      },
    };

    jest.spyOn(store, 'dispatch').mockResolvedValue({
      data: {
        issue: {
          participants: {
            edges: [
              {
                node: {
                  id: '1',
                  username: activeIssueName,
                  name: activeIssueName,
                  avatar: '',
                  avatarUrl: '',
                },
              },
            ],
          },
        },
      },
    });
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when mounted', () => {
    beforeEach(() => {
      createComponent();
    });

    it('calls getParticipants', () => {
      expect(store.dispatch).toHaveBeenCalledWith('getIssueParticipants', 'gid://gitlab/Issue/111');
    });

    // it('sets list to returned data', () => {});
  });

  describe('when collapsed', () => {
    it('renders IssuableAssignees', () => {
      createComponent();

      expect(wrapper.find(IssuableAssignees).isVisible()).toBe(true);
    });
  });

  describe('when dropdown is open', () => {
    beforeEach(async () => {
      createComponent();

      openDropdown();

      await wrapper.vm.$nextTick();
    });

    it('shows assignees dropdown', async () => {
      expect(wrapper.find(IssuableAssignees).isVisible()).toBe(false);
      expect(wrapper.find(AssigneesDropdown).isVisible()).toBe(true);
    });

    it('shows the issue returned as the activeIssue', async () => {
      expect(findByText(activeIssueName).props('isChecked')).toBe(true);
    });

    describe('when "Unassign" is clicked', () => {
      it('unassigns assignees', async () => {
        unassign();

        await wrapper.vm.$nextTick();

        expect(findByText('Unassign').props('isChecked')).toBe(true);
      });
    });

    describe('when an unselected item is clicked', () => {
      beforeEach(() => {
        unassign();
      });

      it('assigns assignee in the dropdown', async () => {
        wrapper.find('[data-testid="item_test"]').trigger('click');

        await wrapper.vm.$nextTick();

        expect(findByText(activeIssueName).props('isChecked')).toBe(true);
      });

      it('calls setAssignees with username list', async () => {
        wrapper.find('[data-testid="item_test"]').trigger('click');

        await wrapper.vm.$nextTick();

        document.body.click();

        await wrapper.vm.$nextTick();

        expect(store.dispatch).toHaveBeenCalledWith('setAssignees', [activeIssueName]);
      });
    });

    describe('when the user off clicks', () => {
      beforeEach(async () => {
        unassign();

        await wrapper.vm.$nextTick();

        document.body.click();

        await wrapper.vm.$nextTick();
      });

      it('calls setAssignees with username list', async () => {
        expect(store.dispatch).toHaveBeenCalledWith('setAssignees', []);
      });

      it('closed the dropdown', async () => {
        expect(wrapper.find(IssuableAssignees).isVisible()).toBe(true);
      });
    });
  });
});
