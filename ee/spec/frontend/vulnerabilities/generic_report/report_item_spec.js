import { shallowMount } from '@vue/test-utils';
import ReportItem from 'ee/vulnerabilities/components/generic_report/report_item.vue';
import {
  REPORT_TYPES,
  REPORT_TYPE_URL,
  REPORT_TYPE_LIST,
} from 'ee/vulnerabilities/components/generic_report/types/constants';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

const TEST_DATA = {
  [REPORT_TYPE_URL]: {
    href: 'http://foo.com',
  },
  [REPORT_TYPE_LIST]: {
    items: [{ type: 'foo' }],
  },
};

describe('ee/vulnerabilities/components/generic_report/report_item.vue', () => {
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
    const reportItem = { type: reportType, ...TEST_DATA[reportType] };

    beforeEach(() => {
      wrapper = createWrapper({ props: { item: reportItem } });
    });

    it('renders the corresponding component', () => {
      expect(findReportComponent().exists()).toBe(true);
    });

    it('passes the report data as props', () => {
      expect(findReportComponent().props()).toMatchObject({
        item: reportItem,
      });
    });
  });
});
