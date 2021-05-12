import { GlButton } from '@gitlab/ui';
import Actions from 'ee/status_checks/components/actions.vue';
import ModalUpdate from 'ee/status_checks/components/modal_update.vue';
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

  const findUpdateModal = () => wrapper.findComponent(ModalUpdate);
  const findRemoveBtn = () => wrapper.findByTestId('remove-btn');

  it('passes the statusCheck to the update modal', () => {
    expect(findUpdateModal().props('statusCheck')).toStrictEqual(statusCheck);
  });

  it('renders the remove button', () => {
    expect(findRemoveBtn().text()).toBe('Remove...');
  });
});
