import { shallowMount } from '@vue/test-utils';
import { GlTokenSelector } from '@gitlab/ui';
import MockAdapter from 'axios-mock-adapter';
import waitForPromises from 'helpers/wait_for_promises';
import axios from '~/lib/utils/axios_utils';
import MembersTokenSelect from '~/invite_members/components/members_token_select.vue';

const groupId = 1;
const label = 'testgroup';
const placeholder = 'Search for a member';
const user1 = { id: 1, name: 'Name One', username: 'one_1', avatar_url: '' };
const user2 = { id: 2, name: 'Name Two', username: 'two_2', avatar_url: '' };
const allUsers = [user1, user2];

const createComponent = () => {
  return shallowMount(MembersTokenSelect, {
    propsData: {
      groupId,
      label,
      placeholder,
    },
  });
};

describe('InviteMembersModal', () => {
  let wrapper;
  let mock;

  beforeEach(() => {
    mock = new MockAdapter(axios);
    mock.onGet('/api/undefined/users.json').reply(200, allUsers);

    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
    mock.restore();
  });

  const findDropdown = () => wrapper.find(GlTokenSelector);

  describe('rendering the token-selector component', () => {
    it('renders with the correct attributes', () => {
      const expectedAttributes = {
        autocomplete: 'off',
        loading: 'true',
        arialabelledby: label,
        placeholder,
      };

      expect(findDropdown().attributes()).toMatchObject(expectedAttributes);
    });
  });

  describe('.filterUsers', () => {
    const expectedFilteredUsers = [user1];

    it('returns all of the Api users when query is empty', async () => {
      await waitForPromises();

      expect(wrapper.vm.filterUsers()).toMatchObject(allUsers);
    });

    it('returns the users that match the filter query', async () => {
      wrapper.vm.handleTextInput('One');

      await waitForPromises();

      expect(wrapper.vm.filterUsers()).toMatchObject(expectedFilteredUsers);
    });
  });
});
