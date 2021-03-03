import { GlPopover } from '@gitlab/ui';
import { GlBreakpointInstance } from '@gitlab/ui/dist/utils';
import { shallowMount } from '@vue/test-utils';

import TrialStatusPopover from 'ee/contextual_sidebar/components/trial_status_popover.vue';

describe('TrialStatusPopover component', () => {
  let wrapper;

  const createComponent = () => {
    return shallowMount(TrialStatusPopover, {
      propsData: {
        groupName: 'Some Test Group',
        planName: 'Ultimate',
        plansHref: 'billing/path-for/group',
        purchaseHref: 'transactions/new',
        targetId: 'target-element-identifier',
        trialEndDate: new Date('2021-02-28'),
      },
    });
  };

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('matches the snapshot', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  describe('methods', () => {
    describe('onResize', () => {
      const getGlPopover = () => wrapper.findComponent(GlPopover);

      it.each`
        bp      | isDisabled
        ${'xs'} | ${'true'}
        ${'sm'} | ${'true'}
        ${'md'} | ${undefined}
        ${'lg'} | ${undefined}
        ${'xl'} | ${undefined}
      `(
        'sets disabled to `$isDisabled` when the breakpoint is "$bp"',
        async ({ bp, isDisabled }) => {
          jest.spyOn(GlBreakpointInstance, 'getBreakpointSize').mockReturnValue(bp);

          wrapper.vm.onResize();
          await wrapper.vm.$nextTick();

          expect(getGlPopover().attributes('disabled')).toBe(isDisabled);
        },
      );
    });
  });
});
