import { mount } from '@vue/test-utils';
import { GlPopover, GlLink, GlButton } from '@gitlab/ui';
import FeatureHighlightPopover from '~/feature_highlight/feature_highlight_popover.vue';
import { dismiss } from '~/feature_highlight/feature_highlight_helper';
import { POPOVER_TARGET_ID } from '~/feature_highlight/constants';

jest.mock('~/feature_highlight/feature_highlight_helper');

describe('feature_highlight/feature_highlight_popover', () => {
  let wrapper;
  const props = {
    autoDevopsHelpPath: '/help/autodevops',
    highlightId: '123',
    dismissEndpoint: '/api/dismiss',
  };

  const buildWrapper = (propsData = props) => {
    wrapper = mount(FeatureHighlightPopover, {
      propsData,
    });
  };
  const findPopoverTarget = () => wrapper.find(`#${POPOVER_TARGET_ID}`);
  const findPopover = () => wrapper.findComponent(GlPopover);
  const findAutodevopsHelpLink = () => wrapper.findComponent(GlLink);
  const findDismissButton = () => wrapper.findComponent(GlButton);

  beforeEach(() => {
    buildWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders popover target', () => {
    expect(findPopoverTarget().exists()).toBe(true);
  });

  it('renders popover', () => {
    expect(findPopover().props()).toMatchObject({
      target: POPOVER_TARGET_ID,
      cssClasses: ['feature-highlight-popover'],
      triggers: 'hover',
      container: 'body',
      placement: 'right',
      boundary: 'viewport',
    });
  });

  it('renders link that points to the autodevops help page', () => {
    expect(findAutodevopsHelpLink().attributes().href).toBe(props.autoDevopsHelpPath);
    expect(findAutodevopsHelpLink().text()).toBe('Auto DevOps');
  });

  it('renders dismiss button', () => {
    expect(findDismissButton().props()).toMatchObject({
      size: 'small',
      icon: 'thumb-up',
      variant: 'success',
    });
  });

  it('dismisses popover when dismiss button is clicked', () => {
    findDismissButton().vm.$emit('click');

    expect(findPopover().emitted('close')).toHaveLength(1);
    expect(dismiss).toHaveBeenCalledWith(props.dismissEndpoint, props.highlightId);
  });

  describe('when popover is dismissed and hidden', () => {
    it('hides the popover target', async () => {
      findDismissButton().vm.$emit('click');
      await wrapper.vm.$nextTick();
      findPopover().vm.$emit('hidden');
      await wrapper.vm.$nextTick();

      expect(findPopoverTarget().exists()).toBe(false);
    });
  });
});
