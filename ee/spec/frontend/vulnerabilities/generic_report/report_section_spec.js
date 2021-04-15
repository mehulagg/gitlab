import { within, fireEvent } from '@testing-library/dom';
import { mount } from '@vue/test-utils';
import { nextTick } from 'vue';
import ReportSection from 'ee/vulnerabilities/components/generic_report/report_section.vue';
import { REPORT_TYPE_URL } from 'ee/vulnerabilities/components/generic_report/types/constants';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

const TEST_DATA = {
  supportedTypes: {
    one: {
      name: 'one',
      type: REPORT_TYPE_URL,
      href: 'http://foo.com',
    },
    two: {
      name: 'two',
      type: REPORT_TYPE_URL,
      href: 'http://bar.com',
    },
  },
  unsupportedTypes: {
    three: {
      name: 'three',
      type: 'not-supported',
    },
  },
};

describe('ee/vulnerabilities/components/generic_report/report_section.vue', () => {
  let wrapper;

  const createWrapper = (options) =>
    extendedWrapper(
      mount(ReportSection, {
        propsData: {
          details: { ...TEST_DATA.supportedTypes },
        },
        ...options,
      }),
    );

  const withinWrapper = () => within(wrapper.element);
  const findHeading = () =>
    withinWrapper().getByRole('heading', {
      name: /evidence/i,
    });
  const findReportsSection = () => wrapper.findByTestId('reports');
  const findAllReportRows = () => wrapper.findAll('[data-testid*="report-row"]');
  const findReportRowByLabel = (label) => wrapper.findByTestId(`report-row-${label}`);
  const findReportItemByLabel = (label) => wrapper.findByTestId(`report-item-${label}`);
  const supportedReportTypesLabels = Object.keys(TEST_DATA.supportedTypes);

  describe('with supported report types', () => {
    beforeEach(() => {
      wrapper = createWrapper();
    });

    describe('reports section', () => {
      it('contains a heading', () => {
        expect(findHeading()).toBeInstanceOf(HTMLElement);
      });

      it('collapses when the heading is clicked', async () => {
        expect(findReportsSection().isVisible()).toBe(true);

        fireEvent.click(findHeading());
        await nextTick();

        expect(findReportsSection().isVisible()).toBe(false);
      });
    });

    describe('report rows', () => {
      it('shows a row for each report item', () => {
        expect(findAllReportRows()).toHaveLength(supportedReportTypesLabels.length);
      });

      it.each(supportedReportTypesLabels)(
        'renders the correct label for report row: %s',
        (label) => {
          expect(within(findReportRowByLabel(label).element).getByText(label)).toBeInstanceOf(
            HTMLElement,
          );
        },
      );
    });

    describe('report items', () => {
      it.each(supportedReportTypesLabels)(
        'passes the correct props to item for row: %s',
        (label) => {
          expect(findReportItemByLabel(label).props()).toMatchObject({
            item: TEST_DATA.supportedTypes[label],
          });
        },
      );
    });
  });

  describe('with unsupported report types', () => {
    it('only renders valid report types', () => {
      wrapper = createWrapper({
        propsData: {
          details: {
            ...TEST_DATA.supportedTypes,
            ...TEST_DATA.unsupportedTypes,
          },
        },
      });

      expect(findAllReportRows()).toHaveLength(supportedReportTypesLabels.length);
    });

    it('does not render the section if the details only contain non-supported types', () => {
      wrapper = createWrapper({
        propsData: {
          details: {
            ...TEST_DATA.unsupportedTypes,
          },
        },
      });

      expect(findReportsSection().exists()).toBe(false);
    });
  });
});
