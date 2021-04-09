import { screen } from '@testing-library/dom';
import { shallowMount } from '@vue/test-utils';
import ReportItem from 'ee/vulnerabilities/components/generic_report/report_item.vue';
import List from 'ee/vulnerabilities/components/generic_report/types/list.vue';

const TEST_DATA = {
  items: [
    { type: 'url', href: 'http://foo.bar' },
    { type: 'url', href: 'http://bar.baz' },
  ],
};

describe('ee/vulnerabilities/components/generic_report/types/list.vue', () => {
  let wrapper;

  const createWrapper = () => {
    return shallowMount(List, {
      propsData: {
        items: TEST_DATA.items,
      },
      attachTo: document.body,
    });
  };

  const findReportItems = () => wrapper.findAllComponents(ReportItem);

  beforeEach(() => {
    wrapper = createWrapper();
  });

  it('renders a list', () => {
    expect(screen.getByRole('list')).toBeInstanceOf(HTMLElement);
  });

  it('renders a report-item for each item', () => {
    expect(findReportItems()).toHaveLength(TEST_DATA.items.length);
  });
});
