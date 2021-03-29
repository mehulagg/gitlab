import { shallowMount } from '@vue/test-utils';
import ManageDastProfiles from 'ee/security_configuration/components/manage_dast_profiles.vue';
import ManageFeature from 'ee/security_configuration/components/manage_feature.vue';
import ManageGeneric from 'ee/security_configuration/components/manage_generic.vue';
import { REPORT_TYPE_DAST_PROFILES } from '~/vue_shared/security_reports/constants';
import { generateFeatures } from './helpers';

const attrs = {
  'data-qa-selector': 'foo',
};

describe('ManageFeature component', () => {
  let wrapper;

  const createComponent = (options) => {
    wrapper = shallowMount(ManageFeature, options);
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('always', () => {
    beforeEach(() => {
      const [feature] = generateFeatures(1);
      createComponent({ attrs, propsData: { feature } });
    });

    it('passes through attributes to the expected component', () => {
      expect(wrapper.attributes()).toMatchObject(attrs);
    });
  });

  describe.each`
    type                         | expectedComponent
    ${REPORT_TYPE_DAST_PROFILES} | ${ManageDastProfiles}
    ${'foo'}                     | ${ManageGeneric}
  `('given a $type feature', ({ type, expectedComponent }) => {
    let feature;
    let component;

    beforeEach(() => {
      [feature] = generateFeatures(1, { type });

      createComponent({ propsData: { feature } });

      component = wrapper.findComponent(expectedComponent);
    });

    it('renders expected component', () => {
      expect(component.exists()).toBe(true);
    });

    it('passes through props to expected component', () => {
      expect(component.props()).toEqual({ feature });
    });
  });
});
