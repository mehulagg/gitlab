import { GlButton } from '@gitlab/ui';
import Actions from 'ee/status_checks/components/actions.vue';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';

const statusCheck = {
  externalUrl: 'https://foo.com',
  id: 1,
  name: 'Foo',
  protectedBranches: [],
};

describe('Status checks actions', () => {
  let wrapper;

  const createWrapper = () => {
    wrapper = shallowMountExtended(Actions, {
      propsData: {
        statusCheck,
      },
      stubs: {
        GlButton,
      },
    });
  };

  beforeEach(() => {
    createWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  const findEditBtn = () => wrapper.findByTestId('edit-btn');
  const findRemoveBtn = () => wrapper.findByTestId('remove-btn');

  describe('Edit button', () => {
    it('renders the edit button', () => {
      expect(findEditBtn().text()).toBe('Edit');
    });

    it('sends the status check to the update event', () => {
      findEditBtn().trigger('click');

      expect(wrapper.emitted('update-status-to-check')[0][0]).toStrictEqual(statusCheck);
    });
  });

  it('renders the remove button', () => {
    expect(findRemoveBtn().text()).toBe('Remove...');
  });
});
