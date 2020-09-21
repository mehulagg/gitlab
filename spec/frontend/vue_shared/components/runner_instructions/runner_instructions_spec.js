import MockAdapter from 'axios-mock-adapter';
import { shallowMount } from '@vue/test-utils';
import statusCodes from '~/lib/utils/http_status';
import axios from '~/lib/utils/axios_utils';
import RunnerInstructions from '~/vue_shared/components/runner_instructions/runner_instructions.vue';
import { createStore } from '~/vue_shared/components/runner_instructions/store/';
import { mockPlatformsArray } from './mock_data';

const instructionsPath = '/instructions';

describe('RunnerInstructions component', () => {
  let wrapper;
  let store;
  let axiosMock;

  const findModalButton = () => wrapper.find('[data-testid="show-modal-button"]');

  beforeEach(() => {
    axiosMock = new MockAdapter(axios);
    axiosMock.onGet(instructionsPath).reply(statusCodes.OK, {
      available_platforms: mockPlatformsArray,
    });
    store = createStore({
      instructionsPath,
    });
    wrapper = shallowMount(RunnerInstructions, { store });
  });

  afterEach(() => {
    axiosMock.restore();
    wrapper.destroy();
    wrapper = null;
  });

  it('should show the "Show Runner installation instructions" button', () => {
    const button = findModalButton();

    expect(button.exists()).toBe(true);
    expect(button.text()).toBe('Show Runner installation instructions');
  });
});
