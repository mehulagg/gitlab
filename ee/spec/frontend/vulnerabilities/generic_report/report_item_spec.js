import { shallowMount } from '@vue/test-utils';
import ReportItem from 'ee/vulnerabilities/components/generic_report/report_item.vue';

describe('EE - GenericReport - ReportItem', () => {
  let wrapper;

  const createWrapper = () => {
    return shallowMount(ReportItem, {
      propsData: {
        item: {},
      },
    });
  };

  beforeEach(() => {
    wrapper = createWrapper();
  });

  it('renders', () => {
    expect(wrapper.findComponent(ReportItem).exists()).toBe(true);
  });
});
