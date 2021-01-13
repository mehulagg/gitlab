import { shallowMount } from '@vue/test-utils';
import { GlAlert, GlSprintf } from '@gitlab/ui';
import PolicyAlertPicker from 'ee/threat_monitoring/components/policy_editor/policy_alert_picker.vue';

describe('PolicyAlertPicker component', () => {
  let wrapper;

  const defaultProps = { policyAlert: false };

  const findAddAlertButton = () => wrapper.find("[data-testid='add-alert']");
  const findGlAlert = () => wrapper.find(GlAlert);
  const findGlSprintf = () => wrapper.find(GlSprintf);
  const findRemoveAlertButton = () => wrapper.find("[data-testid='remove-alert']");

  const createWrapper = ({ propsData = defaultProps } = {}) => {
    wrapper = shallowMount(PolicyAlertPicker, {
      propsData: {
        ...propsData,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('default state', () => {
    beforeEach(() => {
      createWrapper();
    });

    it('does render the add alert button', () => {
      expect(findAddAlertButton().exists()).toBe(true);
    });

    it('does not render the high volume warning', () => {
      expect(findGlAlert().exists()).toBe(false);
    });

    it('does not render the alert message', () => {
      expect(findGlSprintf().exists()).toBe(false);
    });

    it('does not render the remove alert button', () => {
      expect(findRemoveAlertButton().exists()).toBe(false);
    });

    it('does emit an event to add the alert', () => {
      findAddAlertButton().vm.$emit('click');
      expect(wrapper.emitted('update-alert')).toEqual([[true]]);
    });
  });

  describe('alert enabled', () => {
    beforeEach(() => {
      createWrapper({ propsData: { policyAlert: true } });
    });

    it('does not render the add alert button', () => {
      expect(findAddAlertButton().exists()).toBe(false);
    });

    it('does render the high volume warning', () => {
      expect(findGlAlert().exists()).toBe(true);
    });

    it('does render the alert message', () => {
      expect(findGlSprintf().exists()).toBe(true);
    });

    it('does render the remove alert button', () => {
      expect(findRemoveAlertButton().exists()).toBe(true);
    });

    it('does emit an event to remove the alert', () => {
      findRemoveAlertButton().vm.$emit('click');
      expect(wrapper.emitted('update-alert')).toEqual([[false]]);
    });
  });
});
