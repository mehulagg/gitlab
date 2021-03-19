import { GlPopover } from '@gitlab/ui';
import { GlBreakpointInstance } from '@gitlab/ui/dist/utils';
import { shallowMount } from '@vue/test-utils';

import TrialStatusPopover from 'ee/contextual_sidebar/components/trial_status_popover.vue';

describe('TrialStatusPopover component', () => {
  let wrapper;

  const getGlButton = (testId) => wrapper.find(`[data-testid="${testId}"]`);

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

  it('renders the upgrade button with correct tracking data attrs', () => {
    const attrs = getGlButton('upgradeBtn').attributes();
    expect(attrs['data-track-event']).toBe('click_button');
    expect(attrs['data-track-label']).toBe('upgrade_to_ultimate');
    expect(attrs['data-track-property']).toBe('experiment:show_trial_status_in_sidebar');
  });

  it('renders the compare plans button with correct tracking data attrs', () => {
    const attrs = getGlButton('compareBtn').attributes();
    expect(attrs['data-track-event']).toBe('click_button');
    expect(attrs['data-track-label']).toBe('compare_all_plans');
    expect(attrs['data-track-property']).toBe('experiment:show_trial_status_in_sidebar');
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
