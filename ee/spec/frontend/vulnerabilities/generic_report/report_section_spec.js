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
  const findAllReportRows = () => wrapper.findAllComponents(ReportRow);
  const findReportRowByLabel = (label) => wrapper.findByTestId(`report-row-${label}`);

  const detailsLabels = Object.keys(TEST_DETAILS);
  const isLastRow = (label) => detailsLabels.indexOf(label) === detailsLabels.length - 1;

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
      expect(findAllReportRows()).toHaveLength(detailsLabels.length);
    });

    it.each(detailsLabels)('passes the correct props to report row: %s', (label) => {
      expect(findReportRowByLabel(label).props()).toMatchObject({
        label: TEST_DETAILS[label].name,
        isLastRow: isLastRow(label),
      });
    });
  });
});
