import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import { shallowMount } from '@vue/test-utils';
import statusCodes from '~/lib/utils/http_status';
import RunnerInstructions from '~/vue_shared/components/runner_instructions/runner_instructions.vue';
import { createStore } from '~/vue_shared/components/runner_instructions/store/';
import * as types from '~/vue_shared/components/runner_instructions/store/mutation_types';

import { mockPlatformsObject, mockInstructions } from './mock_data';

const instructionsPath = '/instructions';
const platformsPath = '/platforms';

describe('RunnerInstructions component', () => {
  let wrapper;
  let store;
  let mock;

  const findModalButton = () => wrapper.find('[data-testid="show-modal-button"]');
  const findPlatformButtons = () => wrapper.findAll('[data-testid="platform-button"]');
  const findArchitectureDropdownItems = () =>
    wrapper.findAll('[data-testid="architecture-dropdown-item"]');
  const findBinaryInstructionsSection = () => wrapper.find('[data-testid="binary-instructions"]');
  const findRunnerInstructionsSection = () => wrapper.find('[data-testid="runner-instructions"]');

  function setupStore() {
    store.commit(`installRunnerPopup/${types.SET_AVAILABLE_PLATFORMS}`, mockPlatformsObject);

    store.commit(`installRunnerPopup/${types.SET_AVAILABLE_PLATFORM}`, 'linux');

    store.commit(`installRunnerPopup/${types.SET_ARCHITECTURE}`, '386');

    store.commit(`installRunnerPopup/${types.SET_INSTRUCTIONS}`, mockInstructions);
  }

  beforeEach(() => {
    mock = new MockAdapter(axios);

    mock.onGet(platformsPath).reply(statusCodes.OK, mockPlatformsObject);

    mock.onGet('/instructions?os=linux&arch=386').reply(statusCodes.OK, mockInstructions);

    store = createStore({
      instructionsPath,
      platformsPath,
    });

    wrapper = shallowMount(RunnerInstructions, { store });

    setupStore();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('should show the "Show Runner installation instructions" button', () => {
    const button = findModalButton();

    expect(button.exists()).toBe(true);
    expect(button.text()).toBe('Show Runner installation instructions');
  });

  it('should contain a number of platforms buttons', () => {
    const buttons = findPlatformButtons();

    expect(buttons).toHaveLength(Object.keys(mockPlatformsObject).length);
  });

  it('should contain a number of dropdown items for the architecture options', () => {
    const dropdownItems = findArchitectureDropdownItems();

    expect(dropdownItems).toHaveLength(
      Object.keys(mockPlatformsObject.linux.download_locations).length,
    );
  });

  it('should display the binary installation instructions for a selected architecture', () => {
    const runner = findBinaryInstructionsSection();

    expect(runner.text()).toEqual(
      expect.stringContaining(
        'sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-386',
      ),
    );
    expect(runner.text()).toEqual(
      expect.stringContaining('sudo chmod +x /usr/local/bin/gitlab-runner'),
    );
    expect(runner.text()).toEqual(
      expect.stringContaining(
        `sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash`,
      ),
    );
    expect(runner.text()).toEqual(
      expect.stringContaining(
        'sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner',
      ),
    );
    expect(runner.text()).toEqual(expect.stringContaining('sudo gitlab-runner start'));
  });

  it('should display the runner instructions for a selected architecture', () => {
    const runner = findRunnerInstructionsSection();

    expect(runner.text()).toEqual(expect.stringContaining(mockInstructions.register));
  });
});
