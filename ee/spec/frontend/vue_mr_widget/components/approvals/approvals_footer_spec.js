import _ from 'underscore';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import { GlButton, GlLoadingIcon } from '@gitlab/ui';
import ApprovalsList from 'ee/vue_merge_request_widget/components/approvals/approvals_list.vue';
import ApprovalsFooter from 'ee/vue_merge_request_widget/components/approvals/approvals_footer.vue';
import Icon from '~/vue_shared/components/icon.vue';
import UserAvatarList from '~/vue_shared/components/user_avatar/user_avatar_list.vue';

const localVue = createLocalVue();

const testSuggestedApprovers = () => _.range(1, 11).map(id => ({ id }));
const testApprovalRules = () => [{ name: 'Lorem' }, { name: 'Ipsum' }];

describe('EE MRWidget approvals footer', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = shallowMount(localVue.extend(ApprovalsFooter), {
      propsData: {
        suggestedApprovers: testSuggestedApprovers(),
        approvalRules: testApprovalRules(),
        ...props,
      },
      localVue,
      sync: false,
    });
  };

  const findToggle = () => wrapper.find('button');
  const findToggleIcon = () => findToggle().find(Icon);
  const findToggleLoadingIcon = () => findToggle().find(GlLoadingIcon);
  const findExpandButton = () => wrapper.find(GlButton);
  const findCollapseButton = () => wrapper.find(GlButton);
  const findList = () => wrapper.find(ApprovalsList);
  const findAvatars = () => wrapper.find(UserAvatarList);

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when expanded', () => {
    describe('and has rules', () => {
      beforeEach(() => {
        createComponent();
      });

      it('renders approvals list', () => {
        const list = findList();

        expect(list.exists()).toBe(true);
        expect(list.props()).toEqual(
          jasmine.objectContaining({
            approvalRules: testApprovalRules(),
          }),
        );
      });

      it('does not render user avatar list', () => {
        expect(findAvatars().exists()).toBe(false);
      });

      describe('toggle button', () => {
        it('renders', () => {
          const button = findToggle();

          expect(button.exists()).toBe(true);
          expect(button.attributes('aria-label')).toEqual('Collapse approvers');
        });

        it('renders icon', () => {
          const icon = findToggleIcon();

          expect(icon.exists()).toBe(true);
          expect(icon.props()).toEqual(
            jasmine.objectContaining({
              name: 'chevron-down',
            }),
          );
        });
      });

      describe('collapse button', () => {
        it('renders', () => {
          const button = findCollapseButton();

          expect(button.exists()).toBe(true);
          expect(button.text()).toEqual('Collapse');
        });

        it('when clicked, collapses the view', () => {
          findCollapseButton().trigger('click');

          expect(wrapper.vm.isCollapsed).toEqual(false);
        });
      });
    });

    describe('and loading', () => {
      beforeEach(() => {
        createComponent({ isLoadingRules: true });
      });

      it('does not render icon in toggle button', () => {
        expect(findToggleIcon().exists()).toBe(false);
      });

      it('renders loading in toggle button', () => {
        expect(findToggleLoadingIcon().exists()).toBe(true);
      });
    });

    describe('and rules empty', () => {
      beforeEach(() => {
        createComponent({ approvalRules: [] });
      });

      it('does not render approvals list', () => {
        expect(findList().exists()).toBe(false);
      });
    });
  });

  describe('when collapsed', () => {
    beforeEach(() => {
      createComponent({ value: false });
    });

    describe('toggle button', () => {
      it('renders', () => {
        const button = findToggle();

        expect(button.exists()).toBe(true);
        expect(button.attributes('aria-label')).toEqual('Expand approvers');
      });

      it('renders icon', () => {
        const icon = findToggleIcon();

        expect(icon.exists()).toBe(true);
        expect(icon.props('name')).toEqual('chevron-right');
      });

      it('expands when clicked', () => {
        const button = findToggle();

        button.trigger('click');

        return wrapper.vm.$nextTick().then(() => {
          expect(wrapper.emittedByOrder()).toEqual([{ name: 'input', args: [true] }]);
        });
      });
    });

    it('renders avatar list', () => {
      const avatars = findAvatars();

      expect(avatars.exists()).toBe(true);
      expect(avatars.props()).toEqual(
        jasmine.objectContaining({
          items: testSuggestedApprovers().filter((x, idx) => idx < 5),
          breakpoint: 0,
          emptyText: '',
        }),
      );
    });

    it('does not render collapsed text', () => {
      expect(wrapper.text()).not.toContain('Collapse');
    });

    it('does not render approvals list', () => {
      expect(findList().exists()).toBe(false);
    });

    describe('expand button', () => {
      let button;

      beforeEach(() => {
        button = findExpandButton();
      });

      it('renders', () => {
        expect(button.exists()).toBe(true);
        expect(button.text()).toBe('View eligible approvers');
      });

      it('expands when clicked', done => {
        expect(wrapper.props('value')).toBe(false);

        button.vm.$emit('click');

        localVue
          .nextTick()
          .then(() => {
            expect(wrapper.emittedByOrder()).toEqual([{ name: 'input', args: [true] }]);
          })
          .then(done)
          .catch(done.fail);
      });
    });
  });
});
