import { shallowMount } from '@vue/test-utils';
import { GlForm, GlFormInput } from '@gitlab/ui';
import CloudLicenseApp from '~/admin/cloud_license/components/app.vue';
import { extendedWrapper } from '../../../__helpers__/vue_test_utils_helper';

describe('CloudLicenseApp', () => {
  let wrapper;

  const findActivateButton = () => wrapper.findByTestId('activate-button');
  const findActivationCodeInput = () => wrapper.findComponent(GlFormInput);
  const findCloudLicenseForm = () => wrapper.findComponent(GlForm);

  const mutate = jest.fn().mockResolvedValue();
  const mocks = {
    $apollo: {
      mutate,
    },
  };

  const createComponent = (props = {}) => {
    wrapper = extendedWrapper(
      shallowMount(CloudLicenseApp, {
        propsData: {
          ...props,
        },
        mocks,
      }),
    );
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('Subscription Activation Form', () => {
    beforeEach(() => createComponent());

    it('presents a form', () => {
      expect(findCloudLicenseForm().exists()).toBe(true);
    });

    it('has an input', () => {
      expect(findActivationCodeInput().exists()).toBe(true);
    });

    it('has an `Activate` button', () => {
      expect(findActivateButton().text()).toBe('Activate');
    });
  });
});
