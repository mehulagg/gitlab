import { shallowMount } from '@vue/test-utils';
import { pick } from 'lodash';
import FeatureStatus from 'ee/security_configuration/components/feature_status.vue';
import StatusDastProfiles from 'ee/security_configuration/components/status_dast_profiles.vue';
import StatusGeneric from 'ee/security_configuration/components/status_generic.vue';
import StatusViewHistory from 'ee/security_configuration/components/status_view_history.vue';
import {
  REPORT_TYPE_SAST,
  REPORT_TYPE_DAST_PROFILES,
  REPORT_TYPE_SECRET_DETECTION,
} from '~/vue_shared/security_reports/constants';
import { generateFeatures } from './helpers';

const props = {
  gitlabCiPresent: true,
  gitlabCiHistoryPath: '/ci-history',
  autoDevopsEnabled: false,
};

const attrs = {
  'data-qa-selector': 'foo',
};

describe('FeatureStatus component', () => {
  let wrapper;

  const createComponent = (options) => {
    wrapper = shallowMount(FeatureStatus, options);
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('always', () => {
    beforeEach(() => {
      const [feature] = generateFeatures(1);
      createComponent({ attrs, propsData: { feature, ...props } });
    });

    it('passes through attributes to the expected component', () => {
      expect(wrapper.attributes()).toMatchObject(attrs);
    });
  });

  describe.each`
    type                            | expectedComponent
    ${REPORT_TYPE_SECRET_DETECTION} | ${StatusViewHistory}
    ${REPORT_TYPE_SAST}             | ${StatusViewHistory}
    ${REPORT_TYPE_DAST_PROFILES}    | ${StatusDastProfiles}
    ${'foo'}                        | ${StatusGeneric}
  `('given a $type feature', ({ type, expectedComponent }) => {
    let feature;
    let component;

    beforeEach(() => {
      [feature] = generateFeatures(1, { type });

      createComponent({ propsData: { feature, ...props } });

      component = wrapper.findComponent(expectedComponent);
    });

    it('renders expected component', () => {
      expect(component.exists()).toBe(true);
    });

    it('passes through props to expected component', () => {
      // Exclude props not defined on the expected component, since
      // @vue/test-utils won't include them in `Wrapper#props`.
      const expectedProps = pick({ feature, ...props }, Object.keys(expectedComponent.props ?? {}));
      expect(component.props()).toEqual(expectedProps);
    });
  });
});
