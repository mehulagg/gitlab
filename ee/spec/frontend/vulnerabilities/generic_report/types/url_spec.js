import { shallowMount } from '@vue/test-utils';
import Url from 'ee/vulnerabilities/components/generic_report/types/url.vue';

describe('EE - GenericReport - Types - Url', () => {
  let wrapper;

  const createWrapper = () => {
    return shallowMount(Url, {
      propsData: {
        href: 'http://gitlab.com',
      },
    });
  };

  beforeEach(() => {
    wrapper = createWrapper();
  });

  it('renders', () => {
    expect(wrapper.findComponent(Url).exists()).toBe(true);
  });
});
