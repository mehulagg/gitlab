import { shallowMount } from '@vue/test-utils';
import ReportSection from 'ee/vulnerabilities/components/generic_report/report_section.vue';

describe('EE - GenericReport - ReportSection', () => {
  let wrapper;

  const createWrapper = () => {
    return shallowMount(ReportSection, {
      propsData: {
        details: {},
      },
    });
  };

  beforeEach(() => {
    wrapper = createWrapper();
  });

  it('renders', () => {
    expect(wrapper.findComponent(ReportSection).exists()).toBe(true);
  });
});
