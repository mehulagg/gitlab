import { GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { nextTick } from 'vue';
import RemoveMemberModal from 'ee/billings/seat_usage/components/remove_member_modal.vue';

describe('RemoveMemberModal', () => {
  let wrapper;

  const defaultProps = {
    member: {
      id: 1,
      name: 'GitLab',
      username: '@gitlab',
    },
    namespace: 'namespace',
    namespaceId: 2,
  };

  const createComponent = (mountFn = shallowMount) => {
    wrapper = mountFn(RemoveMemberModal, {
      propsData: {
        ...defaultProps,
      },
      stubs: {
        GlSprintf,
      },
    });
  };

  beforeAll(() => {
    gon.api_version = 'v4';
  });

  beforeEach(() => {
    createComponent();

    return nextTick();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('on rendering', () => {
    it('renders the submit button disabled', () => {
      expect(wrapper.attributes('ok-disabled')).toBe('true');
    });

    it('renders the title with username', () => {
      expect(wrapper.attributes('title')).toBe(
        `Remove user ${defaultProps.member.username} from your subscription`,
      );
    });

    it('renders the modal text with username and namespace', () => {
      expect(wrapper.find('p').text()).toMatchInterpolatedText(
        `You are about to remove user ${defaultProps.member.username} from your subscription. If you continue, the user will be removed from the namespace group and all its subgroups and projects. This action can't be undone.`,
      );
    });

    it('renders the confirmation label with username', () => {
      expect(wrapper.find('label').text()).toContain(defaultProps.member.username.substring(1));
    });
  });

  it('has the correct url for removing a member', () => {
    expect(wrapper.vm.removeMemberPath).toBe('/api/v4/groups/2/billable_members/1');
  });
});
