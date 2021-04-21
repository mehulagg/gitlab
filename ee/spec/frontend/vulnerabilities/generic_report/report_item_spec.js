import { shallowMount } from '@vue/test-utils';
import ReportItem from 'ee/vulnerabilities/components/generic_report/report_item.vue';
import {
  REPORT_TYPES,
  REPORT_TYPE_URL,
  REPORT_TYPE_LIST,
} from 'ee/vulnerabilities/components/generic_report/types/constants';

const TEST_DATA = {
  [REPORT_TYPE_URL]: {
    href: 'http://foo.com',
  },
  [REPORT_TYPE_LIST]: {
    items: [{ type: 'url', href: 'http://foo.com' }],
  },
};

describe('ee/vulnerabilities/components/generic_report/report_item.vue', () => {
  let wrapper;

  const createWrapper = ({ props } = {}) =>
    shallowMount(ReportItem, {
      propsData: {
        item: {},
        ...props,
      },
    });

  describe.each(REPORT_TYPES)('with report type "%s"', (reportType) => {
    const reportItem = { type: reportType, ...TEST_DATA[reportType] };

    beforeEach(() => {
      wrapper = createWrapper({ props: { item: reportItem } });
    });

    it('renders the corresponding component', () => {
      expect(wrapper.exists()).toBe(true);
    });

    it('passes the report data as props', () => {
      expect(wrapper.props()).toMatchObject({
        item: reportItem,
      });
    });
  });
});
