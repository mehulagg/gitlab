import { screen } from '@testing-library/dom';
import { shallowMount } from '@vue/test-utils';
import List from 'ee/vulnerabilities/components/generic_report/types/list.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

const TEST_DATA = {
  items: [
    { type: 'url', href: 'http://foo.bar' },
    { type: 'url', href: 'http://bar.baz' },
  ],
};

describe('ee/vulnerabilities/components/generic_report/types/list.vue', () => {
  let wrapper;

  const createWrapper = () =>
    extendedWrapper(
      shallowMount(List, {
        propsData: {
          items: TEST_DATA.items,
        },
        attachTo: document.body,
        // manual stubbing is needed because the component is dynamically imported
        stubs: {
          ReportItem: true,
        },
      }),
    );

  const findReportItems = () => wrapper.findAllByTestId('reportItem');

  beforeEach(() => {
    wrapper = createWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders a list', () => {
    expect(screen.getByRole('list')).toBeInstanceOf(HTMLElement);
  });

  it('renders a report-item for each item', () => {
    expect(findReportItems()).toHaveLength(TEST_DATA.items.length);
  });
});
