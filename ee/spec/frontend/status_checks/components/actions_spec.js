import { GlButton } from '@gitlab/ui';
import Actions from 'ee/status_checks/components/actions.vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';

describe('Status checks actions', () => {
  let wrapper;

  const createWrapper = () => {
    wrapper = shallowMountExtended(Actions, {
      stubs: {
        GlButton,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findEditBtn = () => wrapper.findByTestId('edit-btn');
  const findRemoveBtn = () => wrapper.findByTestId('remove-btn');

  it('renders the edit button', () => {
    createWrapper();

    expect(findEditBtn().text()).toBe('Edit');
  });

  it('renders the remove button', () => {
    createWrapper();

    expect(findRemoveBtn().text()).toBe('Remove...');
  });
});
