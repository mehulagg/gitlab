import { shallowMount } from '@vue/test-utils';
import ReportRow from 'ee/vulnerabilities/components/generic_report/report_row.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

describe('ee/vulnerabilities/components/generic_report/report_row.vue', () => {
  let wrapper;

  const createWrapper = ({ ...options } = {}) =>
    extendedWrapper(
      shallowMount(ReportRow, {
        propsData: {
          label: 'Foo',
        },
        ...options,
      }),
    );

  it('renders the default slot', () => {
    const slotContent = 'foo bar';
    wrapper = createWrapper({ slots: { default: slotContent } });

    expect(wrapper.findByTestId('reportContent').text()).toBe(slotContent);
  });
});
