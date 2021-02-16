import { shallowMount } from '@vue/test-utils';
import ReplyPlaceholder from '~/notes/components/discussion_reply_placeholder.vue';

const placeholderText = 'Test Button Text';

describe('ReplyPlaceholder', () => {
  let wrapper;

  const findButton = () => wrapper.find({ ref: 'button' });

  beforeEach(() => {
    wrapper = shallowMount(ReplyPlaceholder, {
      propsData: {
        placeholderText,
      },
    });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('emits focus event on button click', () => {
    findButton().trigger('click');

    return wrapper.vm.$nextTick().then(() => {
      expect(wrapper.emitted()).toEqual({
        focus: [[]],
      });
    });
  });

  it('should render reply button', () => {
    expect(findButton().text()).toEqual(placeholderText);
  });
});
