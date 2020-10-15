import { shallowMount } from '@vue/test-utils';
import { GlTokenSelector } from '@gitlab/ui';
import MockAdapter from 'axios-mock-adapter';
import waitForPromises from 'helpers/wait_for_promises';
import axios from '~/lib/utils/axios_utils';
import MembersTokenSelect from '~/invite_members/components/members_token_select.vue';

const label = 'testgroup';
const placeholder = 'Search for a member';
const user1 = { id: 1, name: 'Name One', username: 'one_1', avatar_url: '' };
const user2 = { id: 2, name: 'Name Two', username: 'two_2', avatar_url: '' };
const allUsers = [user1, user2];

const createComponent = () => {
  return shallowMount(MembersTokenSelect, {
    propsData: {
      label,
      placeholder,
    },
  });
};

describe('MembersTokenSelect', () => {
  let wrapper;
  let mock;

  beforeEach(() => {
    mock = new MockAdapter(axios);
    gon.api_version = 'v4';
    mock.onGet('/api/v4/users.json').reply(200, allUsers);

    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
    mock.restore();
  });

  const findTokenSelector = () => wrapper.find(GlTokenSelector);

  describe('rendering the token-selector component', () => {
    it('renders with the correct props', () => {
      const expectedProps = {
        loading: true,
        ariaLabelledby: label,
        placeholder,
      };

      expect(findTokenSelector().props()).toEqual(expect.objectContaining(expectedProps));
    });
  });

  describe('.filterUsers', () => {
    const expectedFilteredUsers = [user1];

    it('returns all of the Api users when query is empty', async () => {
      await waitForPromises();

      expect(wrapper.vm.filterUsers()).toMatchObject(allUsers);
    });

    it('returns the users that match the filter query', async () => {
      findTokenSelector().vm.$emit('text-input', 'One');

      await waitForPromises();

      expect(wrapper.vm.filterUsers()).toMatchObject(expectedFilteredUsers);
    });
  });
});
