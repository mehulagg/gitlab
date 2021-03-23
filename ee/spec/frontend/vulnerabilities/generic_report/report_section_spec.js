import { within, fireEvent } from '@testing-library/dom';
import { mount } from '@vue/test-utils';
import { nextTick } from 'vue';
import ReportRow from 'ee/vulnerabilities/components/generic_report/report_row.vue';
import ReportSection from 'ee/vulnerabilities/components/generic_report/report_section.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

const TEST_DETAILS = {
  first: {
    name: 'one',
    type: 'url',
    href: 'http://foo.com',
  },
  last: {
    name: 'two',
    type: 'url',
    href: 'http://bar.com',
  },
};

describe('EE - GenericReport - ReportSection', () => {
  let wrapper;

  const createWrapper = () =>
    extendedWrapper(
      mount(ReportSection, {
        propsData: {
          details: TEST_DETAILS,
        },
      }),
    );

  const withinWrapper = () => within(wrapper.element);
  const findHeading = () =>
    withinWrapper().getByRole('heading', {
      name: /evidence/i,
    });
  const findReportsSection = () => wrapper.findByTestId('reports');
  const findReportRows = () => wrapper.findAllComponents(ReportRow);
  const findReportRow = (label) => wrapper.findByTestId(`report-row-${label}`);

  const detailsCount = () => Object.keys(TEST_DETAILS).length;
  const isLastRow = (rowLabel) =>
    Object.keys(TEST_DETAILS).indexOf(rowLabel) === detailsCount() - 1;

  beforeEach(() => {
    wrapper = createWrapper();
  });

  it('contains a heading', () => {
    expect(findHeading()).toBeInstanceOf(HTMLElement);
  });

  describe('reports section', () => {
    it('is collapsed by default', () => {
      expect(findReportsSection().isVisible()).toBe(false);
    });

    it('expands when the heading is clicked', async () => {
      fireEvent.click(findHeading());

      await nextTick();

      expect(findReportsSection().isVisible()).toBe(true);
    });
  });

  describe('report rows', () => {
    it('shows a row for each report item', () => {
      expect(findReportRows()).toHaveLength(detailsCount());
    });

    it.each(Object.keys(TEST_DETAILS))('passes the correct props to report row: %s', (rowLabel) => {
      expect(findReportRow(rowLabel).props()).toMatchObject({
        label: TEST_DETAILS[rowLabel].name,
        isLastRow: isLastRow(rowLabel),
      });
    });
  });
});
