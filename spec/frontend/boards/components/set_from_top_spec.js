import { shallowMount } from '@vue/test-utils';
import { useMockMutationObserver } from 'helpers/mock_dom_observer';
import waitForPromises from 'helpers/wait_for_promises';
import SetFromTop from '~/boards/components/set_from_top.vue';
import { contentTop } from '~/lib/utils/common_utils';

jest.mock('~/lib/utils/common_utils');
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

describe('SetFromTop', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(SetFromTop, {
      data() {
        return {
          heightFromTop: '40px',
        };
      },
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

  it('calls contentTop on render', () => {
    expect(contentTop).toHaveBeenCalledTimes(1);
  });

  it('renders value of heightFromTop in the scoped slot', () => {
    expect(wrapper.text()).toContain('40px');
  });

  it('contentTop should be called a second time after mutation is called for recalculation', async () => {
    createPerfBar();

    await waitForPromises();

    expect(contentTop).toHaveBeenCalledTimes(2);
  });
});
