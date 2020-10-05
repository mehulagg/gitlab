import { shallowMount } from '@vue/test-utils';
import AssigneesListItem from 'ee/boards/components/boards_list_selector/assignees_list_item.vue';
import { mockAssigneesList } from 'jest/boards/mock_data';

describe('AssigneesListItem', () => {
  const assignee = mockAssigneesList[0];
  let wrapper;

  beforeEach(() => {
    wrapper = shallowMount(AssigneesListItem, {
      propsData: {
        item: assignee,
      },
    });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders component container element with class `filter-dropdown-item`', () => {
    expect(wrapper.find('.filter-dropdown-item').exists()).toBe(true);
  });

  it('emits `onItemSelect` event on component click and sends `assignee` as event param', () => {
    wrapper.find('.filter-dropdown-item').trigger('click');

    expect(wrapper.emitted().onItemSelect[0]).toEqual([assignee]);
  });

  describe('avatar', () => {
    it('has alt text', () => {
      expect(wrapper.find('.avatar').attributes('alt')).toBe(`${assignee.name}'s avatar`);
    });

    it('has src url', () => {
      expect(wrapper.find('.avatar').attributes('src')).toBe(assignee.avatar_url);
    });
  });

  describe('user details', () => {
    it('shows assignee name', () => {
      expect(wrapper.find('.dropdown-user-details').text()).toContain(assignee.name);
    });

    it('shows assignee username', () => {
      expect(wrapper.find('.dropdown-user-details .dropdown-light-content').text()).toContain(
        `@${assignee.username}`,
      );
    });
  });
});
