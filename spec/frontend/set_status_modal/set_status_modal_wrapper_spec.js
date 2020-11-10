import { shallowMount } from '@vue/test-utils';
import SetStatusModalWrapper from '~/set_status_modal/set_status_modal_wrapper.vue';

describe('SetStatusModalWrapper', () => {
  let wrapper;

  const defaultEmoji = 'speech_balloon';
  const defaultMessage = "They're comin' in too fast!";

  const defaultProps = {
    currentEmoji: defaultEmoji,
    currentMessage: defaultMessage,
    defaultEmoji,
  };

  const createComponent = ({ props } = {}) => {
    return shallowMount(SetStatusModalWrapper, {
      propsData: {
        ...defaultProps,
        ...props,
      },
    });
  };

  beforeEach(() => {
    wrapper = createComponent();
    // return wrapper.vm.$nextTick();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('should mount', () => {
    expect(wrapper.html()).toMatchSnapshot();
  });
});
