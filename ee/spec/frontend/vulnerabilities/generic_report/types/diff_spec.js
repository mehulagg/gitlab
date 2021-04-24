import { shallowMount } from '@vue/test-utils';
import { BEFORE, AFTER } from 'ee/vulnerabilities/components/generic_report/types/constants';
import Diff from 'ee/vulnerabilities/components/generic_report/types/diff.vue';

const TEST_DATA = {
  before: `
  Hello World
  Hello Again
  
  Hello With a Space`,
  after: `
  Hello Wo5ld
  Hello Again
  
  Hello With a SpAce
  Additional Hello`,
};

describe('ee/vulnerabilities/components/generic_report/types/diff.vue', () => {
  let wrapper;

  const createWrapper = () => {
    return shallowMount(Diff, {
      propsData: {
        ...TEST_DATA,
      },
    });
  };

  beforeEach(() => {
    wrapper = createWrapper();
  });

  it('renders the diff tab', () => {
    expect(wrapper.find('.code').element).toMatchSnapshot();
  });

  it('renders the before tab', async () => {
    wrapper.setData({
      view: BEFORE,
    });

    await wrapper.vm.$nextTick();

    expect(wrapper.find('.code').element).toMatchSnapshot();
  });

  it('renders the after tab', async () => {
    wrapper.setData({
      view: AFTER,
    });

    await wrapper.vm.$nextTick();

    expect(wrapper.find('.code').element).toMatchSnapshot();
  });
});
