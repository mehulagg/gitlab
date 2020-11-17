import { shallowMount } from '@vue/test-utils';
import { merge } from 'lodash';
import CreateMergeRequestButton from 'ee/security_configuration/components/create_merge_request_button.vue';
import ManageFeature from 'ee/security_configuration/components/manage_feature.vue';
import { generateFeatures } from './helpers';

const createSastMergeRequestPath = '/create_sast_merge_request_path';

describe('ManageFeature component', () => {
  let wrapper;
  let feature;

  const createComponent = options => {
    wrapper = shallowMount(
      ManageFeature,
      merge(
        {
          propsData: {
            createSastMergeRequestPath,
            autoDevopsEnabled: false,
          },
        },
        options,
      ),
    );
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findCreateMergeRequestButton = () => wrapper.find(CreateMergeRequestButton);
  const findTestId = id => wrapper.find(`[data-testid="${id}"]`);

  describe('given sastConfigurationUi feature flag is enabled', () => {
    const featureFlagEnabled = {
      provide: {
        glFeatures: {
          sastConfigurationUi: true,
        },
      },
    };

    describe.each`
      configured | expectedTestId
      ${true}    | ${'configureButton'}
      ${false}   | ${'enableButton'}
    `('given feature.configured is $configured', ({ configured, expectedTestId }) => {
      describe('given a configuration path', () => {
        beforeEach(() => {
          [feature] = generateFeatures(1, { configured, configuration_path: 'foo' });

          createComponent({
            ...featureFlagEnabled,
            propsData: { feature },
          });
        });

        it('shows a button to configure the feature', () => {
          const button = findTestId(expectedTestId);
          expect(button.exists()).toBe(true);
          expect(button.attributes('href')).toBe(feature.configuration_path);
        });
      });
    });
  });

  describe('given a feature with type "sast"', () => {
    const autoDevopsEnabled = true;

    beforeEach(() => {
      [feature] = generateFeatures(1, { type: 'sast' });

      createComponent({
        propsData: { feature, autoDevopsEnabled },
      });
    });

    it('shows the CreateMergeRequestButton component', () => {
      const button = findCreateMergeRequestButton();
      expect(button.exists()).toBe(true);
      expect(button.props()).toMatchObject({
        endpoint: createSastMergeRequestPath,
        autoDevopsEnabled,
      });
    });
  });

  describe('given a feature with type "dast-profiles"', () => {
    beforeEach(() => {
      [feature] = generateFeatures(1, { type: 'dast_profiles', configuration_path: 'foo' });

      createComponent({
        propsData: { feature, autoDevopsEnabled: true },
      });
    });

    it('shows the DAST Profiles manage button', () => {
      const button = findTestId('manageButton');
      expect(button.exists()).toBe(true);
      expect(button.attributes('href')).toBe(feature.configuration_path);
    });
  });
});
