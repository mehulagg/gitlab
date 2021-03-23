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

  describe.each(REPORT_TYPES)('with report type "%s"', (reportType) => {
    beforeEach(() => {
      wrapper = createWrapper({ props: { item: { type: reportType, ...TEST_DATA[reportType] } } });
    });

    it('renders the corresponding component', () => {
      expect(findReportComponent().exists()).toBe(true);
    });

    it('passes the report data as props', () => {
      expect(findReportComponent().props()).toMatchObject({
        ...TEST_DATA[reportType],
      });
    });
  });

  describe('with report type "list"', () => {
    const nestingLevel = 3;

    beforeEach(() => {
      wrapper = createWrapper({
        props: { nestingLevel, item: { type: REPORT_TYPE_LIST, ...TEST_DATA[REPORT_TYPE_LIST] } },
      });
    });

    it('passes the nesting level as a prop', () => {
      expect(findReportComponent().props('nestingLevel')).toBe(nestingLevel);
    });
  });

  it('does not render a type that is not supported', () => {
    wrapper = createWrapper({ props: { item: { type: 'non-existing' } } });

    expect(findReportComponent().exists()).toBe(false);
  });
});
