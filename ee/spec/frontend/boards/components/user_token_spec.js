import { GlFilteredSearchToken, GlFilteredSearchSuggestion, GlFilteredSearchTokenSegment, GlAvatar } from '@gitlab/ui';
import { mount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import UsersToken from 'ee/boards/components/users_token.vue';
import GroupUsersQuery from 'ee/boards/graphql/group_members.query.graphql';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';

const localVue = createLocalVue();

localVue.use(VueApollo);

const authors = [{ user: { id: 'root', username: 'root name', avatarUrl: 'rootNameAvatar', name: 'root' }}, { user: { id: 'one', username: 'one', avatarUrl: 'oneAvatar', name: 'root' }}];

describe('UserToken', () => {
  let mockApollo;
  let wrapper;
  let querySpy;

  const createComponentWithApollo = async (active = false) => {
    querySpy = jest.fn().mockResolvedValue({ data: { group: { groupMembers: { nodes: authors} }} })
    mockApollo = createMockApollo([
      [GroupUsersQuery, querySpy],
    ]);


  wrapper = mount(UsersToken, {
      localVue,
      apolloProvider: mockApollo,
      provide: {
        portalName: 'fake',
        alignSuggestions: () => {},
        suggestionsListClass: () => {}
      },
      propsData: {
        config: { fullPath: '' },
        value: { data: 'root name' },
        active,
      },
      stubs: {
        Portal: true,
      }
    });

      await wrapper.vm.$nextTick();
      jest.runOnlyPendingTimers();
  }

  afterEach(() => {
    querySpy.mockRestore();
    wrapper.destroy();
    wrapper = null;
  })

  // need loading
  describe('default', () => {
    it('renders GlFilteredSearchToken', async () => {
      await createComponentWithApollo();

      expect(wrapper.find(GlFilteredSearchToken).exists()).toBe(true)
    });

    it('renders GlAvatar with the correct src attribute', async () => {
      await createComponentWithApollo();

      await waitForPromises();

      expect(wrapper.find('[data-testid="user-selected-token"]').find('[data-testid="token-avatar"]').props('src')).toBe('rootNameAvatar')
    });

    it('renders GlToken with the correct text', async () => {
      await createComponentWithApollo();

      await waitForPromises();

      expect(wrapper.find('[data-testid="user-selected-token"]').text()).toBe('root name')
    });

    it('renders GlFilteredSuggestion for every user', async () => {
      await createComponentWithApollo(true);

      await waitForPromises();

      wrapper.findAll(GlFilteredSearchTokenSegment).at(2).vm.$emit('activate');

      await waitForPromises();

      wrapper.findAll(GlFilteredSearchSuggestion).wrappers.forEach((w, idx) => {
        expect(w.text()).toContain(`@${authors[idx].user.username}`);
        expect(w.text()).toContain(`${authors[idx].user.name}`);
        expect(w.find(GlAvatar).props('src')).toBe(authors[idx].user.avatarUrl);
      });

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
