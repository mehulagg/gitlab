import { shallowMount } from '@vue/test-utils';
import ManageGeneric from 'ee/security_configuration/components/manage_generic.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { generateFeatures } from './helpers';

describe('ManageGeneric component', () => {
  let wrapper;
  let feature;

  const createComponent = (propsData) => {
    wrapper = extendedWrapper(shallowMount(ManageGeneric, { propsData }));
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe.each`
    configured | expectedTestId
    ${true}    | ${'configure-button'}
    ${false}   | ${'enable-button'}
  `('given feature.configured is $configured', ({ configured, expectedTestId }) => {
    describe('given a configuration path', () => {
      beforeEach(() => {
        [feature] = generateFeatures(1, { configured, configuration_path: 'foo' });

        createComponent({ feature });
      });

      it('shows a button to configure the feature', () => {
        const button = wrapper.findByTestId(expectedTestId);
        expect(button.exists()).toBe(true);
        expect(button.attributes('href')).toBe(feature.configuration_path);
      });
    });
  });

  describe('given a feature without a configuration path', () => {
    beforeEach(() => {
      [feature] = generateFeatures(1, { configuration_path: null });

      createComponent({ feature });
    });

    it('renders nothing', () => {
      expect(wrapper.html()).toBe('');
    });
  });
});
