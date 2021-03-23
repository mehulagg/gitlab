import { shallowMount } from '@vue/test-utils';
import ReportItem from 'ee/vulnerabilities/components/generic_report/report_item.vue';
import {
  REPORT_TYPES,
  REPORT_TYPE_LIST,
  REPORT_TYPE_URL,
} from 'ee/vulnerabilities/components/generic_report/types/constants';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

const TEST_DATA = {
  [REPORT_TYPE_LIST]: {
    items: [],
  },
  [REPORT_TYPE_URL]: {
    href: 'http://foo.com',
  },
};

describe('EE - GenericReport - ReportItem', () => {
  let wrapper;

  const createWrapper = ({ props } = {}) =>
    extendedWrapper(
      shallowMount(ReportItem, {
        propsData: {
          item: {},
          ...props,
        },
      }),
    );

  const findReportComponent = () => wrapper.findByTestId('reportComponent');

  it.each(REPORT_TYPES)('renders the support type "%S"', (reportType) => {
    wrapper = createWrapper({ props: { item: { type: reportType, ...TEST_DATA[reportType] } } });

    expect(findReportComponent().exists()).toBe(true);
  });

  it('does not render a type that is not supported', () => {
    wrapper = createWrapper({ props: { item: { type: 'non-existing' } } });

    expect(findReportComponent().exists()).toBe(false);
  });
});
