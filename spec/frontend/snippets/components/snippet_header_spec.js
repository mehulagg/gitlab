import SnippetHeader from '~/snippets/components/snippet_header.vue';
import DeleteSnippetMutation from '~/snippets/mutations/deleteSnippet.mutation.graphql';
import { ApolloMutation } from 'vue-apollo';
import { GlButton, GlModal } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';

describe('Snippet header component', () => {
  let wrapper;
  const snippet = {
    id: 'gid://gitlab/PersonalSnippet/50',
    title: 'The property of Thor',
    visibilityLevel: 'private',
    webUrl: 'http://personal.dev.null/42',
    userPermissions: {
      adminSnippet: true,
      updateSnippet: true,
      reportSnippet: false,
    },
    project: null,
    author: {
      name: 'Thor Odinson',
    },
    blob: {
      binary: false,
    },
  };
  const mutationVariables = {
    mutation: DeleteSnippetMutation,
    variables: {
      id: snippet.id,
    },
  };
  const errorMsg = 'Foo bar';
  const err = { message: errorMsg };

  const resolveMutate = jest.fn(() =>
    Promise.resolve({ data: { destroySnippet: { errors: [] } } }),
  );
  const rejectMutation = jest.fn(() => Promise.reject(err));

  const mutationTypes = {
    RESOLVE: resolveMutate,
    REJECT: rejectMutation,
  };

  function createComponent({
    loading = false,
    permissions = {},
    mutationRes = mutationTypes.RESOLVE,
    snippetProps = {},
  } = {}) {
    // const defaultProps = Object.assign({}, snippet, snippetProps);
    const defaultProps = Object.assign(snippet, snippetProps);
    if (permissions) {
      Object.assign(defaultProps.userPermissions, {
        ...permissions,
      });
    }
    const $apollo = {
      queries: {
        canCreateSnippet: {
          loading,
        },
      },
      mutate: mutationRes,
    };

    wrapper = shallowMount(SnippetHeader, {
      mocks: { $apollo },
      propsData: {
        snippet: {
          ...defaultProps,
        },
      },
      stubs: {
        ApolloMutation,
      },
    });
  }

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders itself', () => {
    createComponent();
    expect(wrapper.find('.detail-page-header').exists()).toBe(true);
  });

  it('renders action buttons based on permissions', () => {
    createComponent({
      permissions: {
        adminSnippet: false,
        updateSnippet: false,
      },
    });
    expect(wrapper.findAll(GlButton).length).toEqual(0);

    createComponent({
      permissions: {
        adminSnippet: true,
        updateSnippet: false,
      },
    });
    expect(wrapper.findAll(GlButton).length).toEqual(1);

    createComponent({
      permissions: {
        adminSnippet: true,
        updateSnippet: true,
      },
    });
    expect(wrapper.findAll(GlButton).length).toEqual(2);

    createComponent({
      permissions: {
        adminSnippet: true,
        updateSnippet: true,
      },
    });
    wrapper.setData({
      canCreateSnippet: true,
    });
    return wrapper.vm.$nextTick().then(() => {
      expect(wrapper.findAll(GlButton).length).toEqual(3);
    });
  });

  it('renders modal for deletion of a snippet', () => {
    createComponent();
    expect(wrapper.find(GlModal).exists()).toBe(true);
  });

  it('renders Edit button as disabled for binary snippets', () => {
    createComponent({
      snippetProps: {
        blob: {
          binary: true,
        },
      },
    });
    expect(wrapper.find('[href*="edit"]').props('disabled')).toBe(true);
  });

  describe('Delete mutation', () => {
    const { location } = window;

    beforeEach(() => {
      delete window.location;
      window.location = {
        pathname: '',
      };
    });

    afterEach(() => {
      window.location = location;
    });

    it('dispatches a mutation to delete the snippet with correct variables', () => {
      createComponent();
      wrapper.vm.deleteSnippet();
      expect(mutationTypes.RESOLVE).toHaveBeenCalledWith(mutationVariables);
    });

    it('sets error message if mutation fails', () => {
      createComponent({ mutationRes: mutationTypes.REJECT });
      expect(Boolean(wrapper.vm.errorMessage)).toBe(false);

      wrapper.vm.deleteSnippet();
      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.vm.errorMessage).toEqual(errorMsg);
      });
    });

    describe('in case of successful mutation, closes modal and redirects to correct listing', () => {
      const createDeleteSnippet = (snippetProps = {}) => {
        createComponent({
          snippetProps,
        });
        wrapper.vm.closeDeleteModal = jest.fn();

        wrapper.vm.deleteSnippet();
        return wrapper.vm.$nextTick();
      };

      it('redirects to dashboard/snippets for personal snippet', () => {
        return createDeleteSnippet().then(() => {
          expect(wrapper.vm.closeDeleteModal).toHaveBeenCalled();
          expect(window.location.pathname).toBe('dashboard/snippets');
        });
      });

      it('redirects to project snippets for project snippet', () => {
        const fullPath = 'foo/bar';
        return createDeleteSnippet({
          project: {
            fullPath,
          },
        }).then(() => {
          expect(wrapper.vm.closeDeleteModal).toHaveBeenCalled();
          expect(window.location.pathname).toBe(`${fullPath}/snippets`);
        });
      });
    });
  });
});
