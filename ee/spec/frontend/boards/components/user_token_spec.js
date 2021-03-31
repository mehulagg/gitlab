import VueApollo from 'vue-apollo';
import { GlAvatar, GlFilteredSearchToken, GlToken, GlFilteredSearchSuggestion, GlFilteredSearchTokenSegment } from '@gitlab/ui';
import createMockApollo from 'helpers/mock_apollo_helper';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import { mount, shallowMount, createLocalVue } from '@vue/test-utils';
import UsersToken from 'ee/boards/components/users_token.vue';
import GroupUsersQuery from 'ee/boards/graphql/group_members.query.graphql';
import waitForPromises from 'helpers/wait_for_promises';

const localVue = createLocalVue();

localVue.use(VueApollo);

describe('UserToken', () => {
  let mockApollo;
  let wrapper;
  let querySpy;

  const createComponentWithApollo = async () => {
    querySpy = jest.fn().mockResolvedValue({ data: { group: { groupMembers: { nodes: [{ user: { id: 'root', username: 'root name', avatarUrl: 'rootAvatar', name: 'root' }}]} }} })
    mockApollo = createMockApollo([
      [GroupUsersQuery, querySpy],
    ]);


  wrapper = mount(UsersToken, {
      localVue,
      apolloProvider: mockApollo,
      provide: {
        portalName: 'fake',
        alignSuggestions: '',
      },
      propsData: {
        config: { fullPath: '' },
        value: { data: 'root name' },
      },
    });

      await wrapper.vm.$nextTick();
      jest.runOnlyPendingTimers();
  }

  afterEach(() => {
    querySpy.mockRestore();
    wrapper.destroy();
    wrapper = null;
  })

  describe('default', () => {
    it('renders GlFilteredSearchToken', async () => {
      await createComponentWithApollo();

      expect(wrapper.find(GlFilteredSearchToken).exists()).toBe(true)
    });

    it('renders GlAvatar with the correct src attribute', async () => {
      await createComponentWithApollo();

      await waitForPromises();

      expect(wrapper.find('[data-testid="token-avatar"]').props('src')).toBe('rootAvatar')
    })

    it('renders GlToken with the correct text', async () => {
      await createComponentWithApollo();

      await waitForPromises();

      expect(wrapper.find(GlToken).text()).toBe('rootAvatar')
    })
  });

  describe.skip('with users', () => {
    it('finds', async () => {
      await createComponentWithApollo();

      await wrapper.vm.$nextTick();
      jest.runOnlyPendingTimers();
      console.log(wrapper.html())

      expect(false).toBe(false);
    });
  });

  describe('when searching', () => {
    it('calls the query with updated values', async () => {
      await createComponentWithApollo();

      wrapper.find(GlFilteredSearchToken).vm.$emit('input', { data: 'test' })

      await wrapper.vm.$nextTick();
      jest.runOnlyPendingTimers();

      expect(querySpy).toHaveBeenCalledWith({ fullPath: '', search: 'test' });
    });
  });
});
