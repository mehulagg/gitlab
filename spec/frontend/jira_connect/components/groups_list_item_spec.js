import { shallowMount } from '@vue/test-utils';
import { GlAvatar, GlButton } from '@gitlab/ui';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

import { mockGroup1 } from '../mock_data';

import GroupsListItem from '~/jira_connect/components/groups_list_item.vue';

describe('GroupsListItem', () => {
  let wrapper;

  const mockSubscriptionPath = 'subscriptionPath';

  const createComponent = () => {
    wrapper = extendedWrapper(
      shallowMount(GroupsListItem, {
        propsData: {
          group: mockGroup1,
        },
        provide: {
          subscriptionsPath: mockSubscriptionPath,
        },
      }),
    );
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findGlAvatar = () => wrapper.find(GlAvatar);
  const findLinkButton = () => wrapper.find(GlButton);
  const findGroupName = () => wrapper.findByTestId('group-list-item-name');
  const findGroupDescription = () => wrapper.findByTestId('group-list-item-description');

  it('renders group avatar', () => {
    expect(findGlAvatar().exists()).toBe(true);
    expect(findGlAvatar().props('src')).toBe(mockGroup1.avatar_url);
  });

  it('renders group name', () => {
    expect(findGroupName().text()).toBe(mockGroup1.full_name);
  });

  it('renders group description', () => {
    expect(findGroupDescription().text()).toBe(mockGroup1.description);
  });

  it('renders Link button', () => {
    expect(findLinkButton().exists()).toBe(true);
    expect(findLinkButton().text()).toBe('Link');
  });
});
