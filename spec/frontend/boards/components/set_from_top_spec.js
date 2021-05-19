import { shallowMount } from '@vue/test-utils';
import { useMockMutationObserver } from 'helpers/mock_dom_observer';
import waitForPromises from 'helpers/wait_for_promises';
import SetFromTop from '~/boards/components/set_from_top.vue';

jest.mock('~/lib/utils/common_utils', () => {
  return {
    contentTop: () => '77',
  };
});
const { trigger: triggerMutation } = useMockMutationObserver();

const triggerChildMutation = () => {
  triggerMutation(document.body, { options: { childList: true, subtree: true } });
};

const createPerfBar = () => {
  const perfBar = document.createElement('div');
  perfBar.setAttribute('id', 'js-peek');

  document.body.appendChild(perfBar);

  triggerChildMutation();
};
describe('BoardContentSidebar', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(SetFromTop, {
      scopedSlots: {
        default: '<span data-testid="from-top">{{props.heightFromTop}}</span>',
      },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders the headerFromTop value', () => {
    expect(wrapper.text()).toContain('40px');
  });

  it('sets scoped slot text to be the value of contentTop', async () => {
    createPerfBar();

    await waitForPromises();

    expect(wrapper.text()).toBe('77px');
  });
});
