import VueApollo from 'vue-apollo';
import { shallowMount } from '@vue/test-utils';
import { createLocalVue } from '@vue/test-utils';
import manageSast from '~/security_configuration/components/manage_sast.vue';
import createMockApollo from 'helpers/mock_apollo_helper';
import configureSastMutation from '~/security_configuration/graphql/configure_sast.mutation.graphql';

const localVue = createLocalVue();

describe('Some component', () => {
  let wrapper;

  function createMockApolloProvider() {
    localVue.use(VueApollo);

    const data = {
      configureSast: {
        successPath:
          'http://gitlab.localdev:3000/testgroup/testproject-in-testgroup/-/merge_requests/new?merge_request%5Bdescription%5D=Set+.gitlab-ci.yml+to+enable+or+configure+SAST+security+scanning+using+the+GitLab+managed+template.+You+can+%5Badd+variable+overrides%5D%28https%3A%2F%2Fdocs.gitlab.com%2Fee%2Fuser%2Fapplication_security%2Fsast%2F%23customizing-the-sast-settings%29+to+customize+SAST+settings.&merge_request%5Bsource_branch%5D=set-sast-config-12',
        errors: [],
        __typename: 'ConfigureSastPayload',
      },
    };

    const requestHandlers = [
      [
        configureSastMutation,
        async ()=> ({data}),
      ],
    ];

    return createMockApollo(requestHandlers);
  }

  function createComponent(options = {}) {
    const { mockApollo } = options;

    return shallowMount(manageSast, {
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

    it('test', () => {
      createComponent();
      wrapper.vm.mutate();
      //   await wrapper.vm.$nextTick();
      // step 1 mutate callen wenn er redirected zu dem link oben ist fein....
      // step 2 redirect to muss wohl auch noch gemocked werden....

      expect(true).toBe(true);
    });
  });
});
// 1 test does render correct button?!
// does do the correct mutation onclick
// does bubble up error on server error
