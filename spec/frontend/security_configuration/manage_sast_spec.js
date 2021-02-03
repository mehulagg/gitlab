import VueApollo from 'vue-apollo';
import { mount , createLocalVue } from '@vue/test-utils';

import createMockApollo from 'helpers/mock_apollo_helper';
import manageSast from '~/security_configuration/components/manage_sast.vue';
import configureSastMutation from '~/security_configuration/graphql/configure_sast.mutation.graphql';
import { redirectTo } from '~/lib/utils/url_utility';

jest.mock('~/lib/utils/url_utility', () => ({
  ...jest.requireActual('~/lib/utils/url_utility'),
  redirectTo: jest.fn(),
}));

const localVue = createLocalVue();

describe('Some component', () => {
  let wrapper;

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

  function createComponent(options = {}) {
    const { mockApollo } = options;

    return mount(manageSast, {
      localVue,
      apolloProvider: mockApollo,
    });
  }

  describe('with Apollo mock', () => {
    let mockApollo;

    beforeEach(() => {
      mockApollo = createMockApolloProvider();
      wrapper = createComponent({ mockApollo });
    });

    it('should call redirect helper with correct value', () => {
      createComponent();
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
      // step 1 mutate callen wenn er redirected zu dem link oben ist fein....
      // step 2 redirect to muss wohl auch noch gemocked werden....
      expect(somethingSpy).toBeCalled();
      // expect(true).toBe(true);
    });
  });
});
// 1 test does render correct button?!
// does do the correct mutation onclick
// does bubble up error on server error
