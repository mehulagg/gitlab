import { shallowMount } from '@vue/test-utils';
import ReportRow from 'ee/vulnerabilities/components/generic_report/report_row.vue';

describe('EE - GenericReport - ReportSection', () => {
  let wrapper;

  const createWrapper = () => {
    return shallowMount(ReportRow, {
      propsData: {
        label: 'Foo',
      },
    });
  };

  beforeEach(() => {
    wrapper = createWrapper();
  });

  it('renders', () => {
    expect(wrapper.findComponent(ReportRow).exists()).toBe(true);
  });
});
