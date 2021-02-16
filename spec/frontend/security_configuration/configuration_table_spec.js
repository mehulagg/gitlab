import { mount } from '@vue/test-utils';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import ConfigurationTable from '~/security_configuration/components/configuration_table.vue';
import {
  features,
  UPGRADE_CTA,
  SAST_HELP_PATH,
  DAST_HELP_PATH,
  SECRET_DETECTION_HELP_PATH,
  DEPENDENCY_SCANNING_HELP_PATH,
  CONTAINER_SCANNING_HELP_PATH,
  COVERAGE_FUZZING_HELP_PATH,
  LICENSE_COMPLIANCE_HELP_PATH,
} from '~/security_configuration/components/features_constants';

import {
  REPORT_TYPE_SAST,
  REPORT_TYPE_DAST,
  REPORT_TYPE_SECRET_DETECTION,
  REPORT_TYPE_DEPENDENCY_SCANNING,
  REPORT_TYPE_CONTAINER_SCANNING,
  REPORT_TYPE_COVERAGE_FUZZING,
  REPORT_TYPE_LICENSE_COMPLIANCE,
} from '~/vue_shared/security_reports/constants';

describe('Configuration Table Component', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = extendedWrapper(mount(ConfigurationTable, {}));
  };

  afterEach(() => {
    wrapper.destroy();
  });

  beforeEach(() => {
    createComponent();
  });

  it.each(features)('should match strings', (feature) => {
    expect(wrapper.text()).toContain(feature.name);
    expect(wrapper.text()).toContain(feature.description);
    if (feature.type === REPORT_TYPE_SAST) {
      expect(wrapper.findByTestId(feature.type).text()).toBe('Configure via Merge Request');
    } else if (
      [
        REPORT_TYPE_DAST,
        REPORT_TYPE_DEPENDENCY_SCANNING,
        REPORT_TYPE_CONTAINER_SCANNING,
        REPORT_TYPE_COVERAGE_FUZZING,
        REPORT_TYPE_LICENSE_COMPLIANCE,
      ].includes(feature.type)
    ) {
      expect(wrapper.findByTestId(feature.type).text()).toMatchInterpolatedText(UPGRADE_CTA);
    }
  });

  it.each(features)('should have correct href', (feature) => {
    if (feature.type === REPORT_TYPE_SAST) {
      expect(wrapper.findByTestId(`${REPORT_TYPE_SAST}-link`).element.href).toContain(
        SAST_HELP_PATH,
      );
    } else if (feature.type === REPORT_TYPE_DAST) {
      expect(wrapper.findByTestId(`${REPORT_TYPE_DAST}-link`).element.href).toContain(
        DAST_HELP_PATH,
      );
    } else if (feature.type === REPORT_TYPE_SECRET_DETECTION) {
      expect(wrapper.findByTestId(`${REPORT_TYPE_SECRET_DETECTION}-link`).element.href).toContain(
        SECRET_DETECTION_HELP_PATH,
      );
    } else if (feature.type === REPORT_TYPE_DEPENDENCY_SCANNING) {
      expect(
        wrapper.findByTestId(`${REPORT_TYPE_DEPENDENCY_SCANNING}-link`).element.href,
      ).toContain(DEPENDENCY_SCANNING_HELP_PATH);
    } else if (feature.type === REPORT_TYPE_CONTAINER_SCANNING) {
      expect(wrapper.findByTestId(`${REPORT_TYPE_CONTAINER_SCANNING}-link`).element.href).toContain(
        CONTAINER_SCANNING_HELP_PATH,
      );
    } else if (feature.type === REPORT_TYPE_COVERAGE_FUZZING) {
      expect(wrapper.findByTestId(`${REPORT_TYPE_COVERAGE_FUZZING}-link`).element.href).toContain(
        COVERAGE_FUZZING_HELP_PATH,
      );
    } else if (feature.type === REPORT_TYPE_LICENSE_COMPLIANCE) {
      expect(wrapper.findByTestId(`${REPORT_TYPE_LICENSE_COMPLIANCE}-link`).element.href).toContain(
        LICENSE_COMPLIANCE_HELP_PATH,
      );
    }
  });
});
