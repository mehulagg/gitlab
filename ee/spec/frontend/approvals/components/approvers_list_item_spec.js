import { shallowMount, createLocalVue } from '@vue/test-utils';
import { GlButton } from '@gitlab/ui';
import { TYPE_USER, TYPE_GROUP, TYPE_HIDDEN_GROUPS } from 'ee/approvals/constants';
import ApproversListItem from 'ee/approvals/components/approvers_list_item.vue';
import HiddenGroupsItem from 'ee/approvals/components/hidden_groups_item.vue';
import Avatar from '~/vue_shared/components/project_avatar/default.vue';

const localVue = createLocalVue();
const TEST_USER = {
  id: 1,
  type: TYPE_USER,
  name: 'Lorem Ipsum',
};
const TEST_GROUP = {
  id: 1,
  type: TYPE_GROUP,
  name: 'Lorem Group',
  full_path: 'dolar/sit/amit',
};

describe('Approvals ApproversListItem', () => {
  let wrapper;

  const factory = (options = {}) => {
    wrapper = shallowMount(localVue.extend(ApproversListItem), {
      ...options,
      localVue,
      sync: false,
    });
  };

  describe('when user', () => {
    beforeEach(() => {
      factory({
        propsData: {
          approver: TEST_USER,
        },
      });
    });

    it('renders avatar', () => {
      const avatar = wrapper.find(Avatar);

      expect(avatar.exists()).toBe(true);
      expect(avatar.props('project')).toEqual(TEST_USER);
    });

    it('renders name', () => {
      expect(wrapper.text()).toContain(TEST_USER.name);
    });

    it('when remove clicked, emits remove', () => {
      const button = wrapper.find(GlButton);
      button.vm.$emit('click');

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.emittedByOrder()).toEqual([{ name: 'remove', args: [TEST_USER] }]);
      });
    });
  });

  describe('when group', () => {
    beforeEach(() => {
      factory({
        propsData: {
          approver: TEST_GROUP,
        },
      });
    });

    it('renders full_path', () => {
      expect(wrapper.text()).toContain(TEST_GROUP.full_path);
      expect(wrapper.text()).not.toContain(TEST_GROUP.name);
    });

    it('does not render hidden-groups-item', () => {
      expect(wrapper.find(HiddenGroupsItem).exists()).toBe(false);
    });
  });

  describe('when hidden groups', () => {
    beforeEach(() => {
      factory({
        propsData: {
          approver: { type: TYPE_HIDDEN_GROUPS },
        },
      });
    });

    it('renders hidden-groups-item', () => {
      expect(wrapper.find(HiddenGroupsItem).exists()).toBe(true);
    });

    it('does not render avatar', () => {
      expect(wrapper.find(Avatar).exists()).toBe(false);
    });
  });
});
