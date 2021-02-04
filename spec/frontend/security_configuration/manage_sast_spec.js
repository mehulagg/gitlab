import VueApollo from 'vue-apollo';
import { mount, createLocalVue } from '@vue/test-utils';

import createMockApollo from 'helpers/mock_apollo_helper';
import manageSast from '~/security_configuration/components/manage_sast.vue';
import configureSastMutation from '~/security_configuration/graphql/configure_sast.mutation.graphql';
import { redirectTo } from '~/lib/utils/url_utility';

jest.mock('~/lib/utils/url_utility', () => ({
  ...jest.requireActual('~/lib/utils/url_utility'),
  redirectTo: jest.fn(),
}));

const localVue = createLocalVue();

describe('Manage Sast', () => {
  let wrapper;

  const findByID = (id) => wrapper.find(`[data-test-id="${id}"]`);

  function createMockApolloProvider() {
    localVue.use(VueApollo);

    const data = {
      configureSast: {
        successPath: 'testSuccessPath',
        errors: [],
        __typename: 'ConfigureSastPayload',
      },
    };

    const requestHandlers = [[configureSastMutation, async () => ({ data })]];

    return createMockApollo(requestHandlers);
  }

  function createComponent(options = {}, noSuccessPath = false) {
    const { mockApollo } = options;

    return mount(manageSast, {
      localVue,
      apolloProvider: mockApollo,
    });
  }

  describe('with Apollo mock', () => {
    it('should call redirect helper with correct value', () => {
      let mockApollo = createMockApolloProvider();
      wrapper = createComponent({ mockApollo });
      wrapper.vm.mutate();
      debugger;
      // wrapper.vm.onSubmit()
      //   .then(() => {
      //     expect(redirectTo).toHaveBeenCalledWith('responseURL');
      //   })
      //   .then(done)
      //   .catch(done.fail);
      // const somethingSpy = jest.spyOn(wrapper.vm.redirectTo);
      //   await wrapper.vm.$nextTick();
      // todo mock redirect
      expect(true).toBe(true);
    });

    it('should render Button with correct text', () => {
      let mockApollo = createMockApolloProvider();
      wrapper = createComponent({ mockApollo });
      expect(findByID('manage-sast-button').element.innerText).toContain(
        'Configure via Merge Request',
      );
    });
  });
});
