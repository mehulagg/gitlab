import { within, fireEvent } from '@testing-library/dom';
import { mount } from '@vue/test-utils';
import ReportRow from 'ee/vulnerabilities/components/generic_report/report_row.vue';
import ReportSection from 'ee/vulnerabilities/components/generic_report/report_section.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

const TEST_DETAILS = {
  foo: {
    name: 'foo',
    type: 'url',
    href: 'http://foo.com',
  },
  bar: {
    name: 'bar',
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
      await fireEvent.click(findHeading());

      expect(findReportsSection().isVisible()).toBe(true);
    });
  });

  describe('report rows', () => {
    it('shows a row for each report item', () => {
      const detailsCount = Object.keys(TEST_DETAILS).length;

      expect(findReportRows()).toHaveLength(detailsCount);
    });
  });
});
