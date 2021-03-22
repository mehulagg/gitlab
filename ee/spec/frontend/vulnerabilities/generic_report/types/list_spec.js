import { shallowMount } from '@vue/test-utils';
import List from 'ee/vulnerabilities/components/generic_report/types/list.vue';

describe('EE - GenericReport - Types - List', () => {
  let wrapper;

  const createWrapper = () => {
    return shallowMount(List, {
      propsData: {
        items: [],
      },
    });
  };

  beforeEach(() => {
    wrapper = createWrapper();
  });

  it('renders', () => {
    expect(wrapper.findComponent(List).exists()).toBe(true);
  });
});
