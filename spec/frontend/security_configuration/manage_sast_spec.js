import VueApollo from 'vue-apollo';
import { mount, createLocalVue } from '@vue/test-utils';
import waitForPromises from 'helpers/wait_for_promises';
import createMockApollo from 'helpers/mock_apollo_helper';
import { GlButton } from '@gitlab/ui';
import manageSast from '~/security_configuration/components/manage_sast.vue';
import configureSastMutation from '~/security_configuration/graphql/configure_sast.mutation.graphql';
import { redirectTo } from '~/lib/utils/url_utility';

jest.mock('~/lib/utils/url_utility', () => ({
  redirectTo: jest.fn(),
}));

const localVue = createLocalVue();

describe('Manage Sast Component', () => {
  let wrapper;

  const findButton = () => wrapper.findComponent(GlButton);

  const successHandler = async () => {
    return {
      data: {
        configureSast: {
          successPath: 'testSuccessPath',
          errors: [],
          __typename: 'ConfigureSastPayload',
        },
      },
    };
  };

  const noSuccessPathHandler = async () => {
    return {
      data: {
        configureSast: {
          successPath: '',
          errors: [],
          __typename: 'ConfigureSastPayload',
        },
      },
    };
  };

  const errorHandler = async () => {
    return {
      data: {
        configureSast: {
          successPath: 'testSuccessPath',
          errors: ['foo'],
          __typename: 'ConfigureSastPayload',
        },
      },
    };
  };

  const pendingHandler = () => new Promise(() => {});

  function createMockApolloProvider(handler) {
    localVue.use(VueApollo);

    const requestHandlers = [[configureSastMutation, handler]];

    return createMockApollo(requestHandlers);
  }

  function createComponent(options = {}) {
    const { mockApollo } = options;

    return mount(manageSast, {
      localVue,
      apolloProvider: mockApollo,
    });
  }

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('should render Button with correct text', () => {
    wrapper = createComponent();
    expect(findButton().text()).toContain('Configure via Merge Request');
  });

  describe('with Apollo mock', () => {
    beforeEach(() => {
      const mockApollo = createMockApolloProvider(successHandler);
      wrapper = createComponent({ mockApollo });
    });

    it('should call redirect helper with correct value', async () => {
      await wrapper.trigger('click');
      await waitForPromises();
      expect(redirectTo).toHaveBeenCalledTimes(1);
      expect(redirectTo).toHaveBeenCalledWith('testSuccessPath');
      // This is done for UX reasons. If the loading prop is set to false
      // on success, then there's a period where the button is clickable
      // again. Instead, we want the button to display a loading indicator
      // for the remainder of the lifetime of the page (i.e., until the
      // browser can start painting the new page it's been redirected to).
      expect(findButton().props().loading).toBe(true);
    });
  });

  describe('loadingstate', () => {
    beforeEach(() => {
      const mockApollo = createMockApolloProvider(pendingHandler);
      wrapper = createComponent({ mockApollo });
    });

    it('renders spinner correctly', async () => {
      expect(findButton().props('loading')).toBe(false);
      await wrapper.trigger('click');
      await waitForPromises();
      expect(findButton().props('loading')).toBe(true);
    });
  });

  describe.each`
    handler                 | message
    ${noSuccessPathHandler} | ${'SAST merge request creation mutation failed'}
    ${errorHandler}         | ${'foo'}
  `('TODO ADD GOOD DESCRIPTION $handler, $message', ({ handler, message }) => {
    beforeEach(() => {
      const mockApollo = createMockApolloProvider(handler);
      wrapper = createComponent({ mockApollo });
    });

    it('should catch and emit error', async () => {
      await wrapper.trigger('click');
      await waitForPromises();
      expect(wrapper.emitted('error')).toEqual([[message]]);
      expect(findButton().props('loading')).toBe(false);
    });
  });
});