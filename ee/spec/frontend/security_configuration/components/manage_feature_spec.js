import { shallowMount } from '@vue/test-utils';
import ManageDastProfiles from 'ee/security_configuration/components/manage_dast_profiles.vue';
import ManageFeature from 'ee/security_configuration/components/manage_feature.vue';
import ManageGeneric from 'ee/security_configuration/components/manage_generic.vue';
import ManageViaMr from '~/vue_shared/security_configuration/components/manage_via_mr.vue';
import {
  REPORT_TYPE_DAST_PROFILES,
  REPORT_TYPE_DEPENDENCY_SCANNING,
  REPORT_TYPE_SECRET_DETECTION,
} from '~/vue_shared/security_reports/constants';
import { generateFeatures } from './helpers';

const attrs = {
  'data-qa-selector': 'foo',
};

describe('ManageFeature component', () => {
  let wrapper;

  const createComponent = (options) => {
    wrapper = shallowMount(ManageFeature, {
      provide: {
        glFeatures: {
          secDependencyScanningUiEnable: true,
        },
      },
      ...options,
    });
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

    it('re-emits caught errors', () => {
      const component = wrapper.findComponent(ManageGeneric);
      component.vm.$emit('error', 'testerror');

      expect(wrapper.emitted('error')).toEqual([['testerror']]);
    });
  });

  describe.each`
    type                               | expectedComponent
    ${REPORT_TYPE_DAST_PROFILES}       | ${ManageDastProfiles}
    ${REPORT_TYPE_DEPENDENCY_SCANNING} | ${ManageViaMr}
    ${REPORT_TYPE_SECRET_DETECTION}    | ${ManageViaMr}
    ${'foo'}                           | ${ManageGeneric}
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
      expect(component.props()).toMatchObject({ feature });
    });
  });

  it.each`
    type                               | featureFlag
    ${REPORT_TYPE_DEPENDENCY_SCANNING} | ${'secDependencyScanningUiEnable'}
  `('renders generic component for $type if $featureFlag is disabled', ({ type, featureFlag }) => {
    const [feature] = generateFeatures(1, { type });
    createComponent({
      propsData: { feature },
      provide: {
        glFeatures: {
          [featureFlag]: false,
        },
      },
    });

    expect(wrapper.findComponent(ManageGeneric).exists()).toBe(true);
  });
});
