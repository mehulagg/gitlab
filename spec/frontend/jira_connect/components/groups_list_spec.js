import { GlAlert, GlLoadingIcon, GlPagination } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import waitForPromises from 'helpers/wait_for_promises';

import { fetchGroups } from '~/jira_connect/api';
import GroupsList from '~/jira_connect/components/groups_list.vue';
import GroupsListItem from '~/jira_connect/components/groups_list_item.vue';
import { DEFAULT_GROUPS_PER_PAGE } from '~/jira_connect/constants';
import { mockGroup1, mockGroup2 } from '../mock_data';

const createMockGroup = (groupId) => {
  return {
    ...mockGroup1,
    id: groupId,
  };
};

const createMockGroups = (count) => {
  return [...new Array(count)].map((_, idx) => createMockGroup(idx));
};

jest.mock('~/jira_connect/api', () => {
  return {
    fetchGroups: jest.fn(),
  };
});
describe('GroupsList', () => {
  let wrapper;

  const mockEmptyResponse = { data: [] };

  const createComponent = (options = {}) => {
    wrapper = shallowMount(GroupsList, {
      ...options,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findGlAlert = () => wrapper.find(GlAlert);
  const findGlLoadingIcon = () => wrapper.find(GlLoadingIcon);
  const findAllItems = () => wrapper.findAll(GroupsListItem);
  const findFirstItem = () => findAllItems().at(0);
  const findSecondItem = () => findAllItems().at(1);

  describe('when groups are loading', () => {
    it('renders loading icon', async () => {
      fetchGroups.mockReturnValue(new Promise(() => {}));
      createComponent();

      await wrapper.vm.$nextTick();

      expect(findGlLoadingIcon().exists()).toBe(true);
    });
  });

  describe('error fetching groups', () => {
    it('renders error message', async () => {
      fetchGroups.mockRejectedValue();
      createComponent();

      await waitForPromises();

      expect(findGlLoadingIcon().exists()).toBe(false);
      expect(findGlAlert().exists()).toBe(true);
      expect(findGlAlert().text()).toBe('Failed to load namespaces. Please try again.');
    });
  });

  describe('no groups returned', () => {
    it('renders empty state', async () => {
      fetchGroups.mockResolvedValue(mockEmptyResponse);
      createComponent();

      await waitForPromises();

      expect(findGlLoadingIcon().exists()).toBe(false);
      expect(wrapper.text()).toContain('No available namespaces');
    });
  });

  describe('with groups returned', () => {
    beforeEach(async () => {
      fetchGroups.mockResolvedValue({ data: [mockGroup1, mockGroup2] });
      createComponent();

      await waitForPromises();
    });

    it('renders groups list', () => {
      expect(findAllItems()).toHaveLength(2);
      expect(findFirstItem().props('group')).toBe(mockGroup1);
      expect(findSecondItem().props('group')).toBe(mockGroup2);
    });

    it('shows error message on $emit from item', async () => {
      const errorMessage = 'error message';

      findFirstItem().vm.$emit('error', errorMessage);

      await wrapper.vm.$nextTick();

      expect(findGlAlert().exists()).toBe(true);
      expect(findGlAlert().text()).toContain(errorMessage);
    });
  });

  describe('pagination', () => {
    it.each`
      scenario                        | totalItems                     | shouldShowPagination
      ${'renders pagination'}         | ${DEFAULT_GROUPS_PER_PAGE + 1} | ${true}
      ${'does not render pagination'} | ${DEFAULT_GROUPS_PER_PAGE - 1} | ${false}
      ${'does not render pagination'} | ${0}                           | ${false}
    `('$scenario with $totalItems groups', async ({ totalItems, shouldShowPagination }) => {
      const mockGroups = createMockGroups(totalItems);
      fetchGroups.mockResolvedValue({
        headers: { 'X-TOTAL': totalItems, 'X-PAGE': 1 },
        data: mockGroups,
      });
      createComponent();

      await waitForPromises();

      expect(wrapper.find(GlPagination).exists()).toBe(shouldShowPagination);
    });
  });
});
