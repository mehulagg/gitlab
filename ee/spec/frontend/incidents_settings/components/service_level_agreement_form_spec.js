import { shallowMount } from '@vue/test-utils';
import ServiceLevelAgreementForm from 'ee/incidents_settings/components/service_level_agreement_form.vue';

describe('Alert integration settings form', () => {
  let wrapper;
  const resetWebhookUrl = jest.fn();
  const service = { updateSettings: jest.fn().mockResolvedValue(), resetWebhookUrl };

  beforeEach(() => {
    wrapper = shallowMount(ServiceLevelAgreementForm, {
      provide: {
        service,
        serviceLevelAgreementSettings: { available: true },
      },
    });
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  it('should match the default snapshot', () => {
    expect(wrapper.element).toMatchSnapshot();
  });
});
