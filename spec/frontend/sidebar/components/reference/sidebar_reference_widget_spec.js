import { shallowMount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import SidebarReferenceWidget from '~/sidebar/components/reference/sidebar_reference_widget.vue';
import issueReferenceQuery from '~/sidebar/queries/issue_reference.query.graphql';
import { issueReferenceResponse } from '../../mock_data';

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('Sidebar Reference Widget', () => {
  let wrapper;
  let fakeApollo;
  const referenceText = 'reference';

  const createComponent = ({
    referenceQueryHandler = jest.fn().mockResolvedValue(issueReferenceResponse(referenceText)),
  } = {}) => {
    fakeApollo = createMockApollo([[issueReferenceQuery, referenceQueryHandler]]);

    wrapper = shallowMount(SidebarReferenceWidget, {
      localVue,
      apolloProvider: fakeApollo,
      provide: {
        fullPath: 'group/project',
        iid: '1',
      },
      propsData: {
        issuableType: 'issue',
      },
    });
  };

  it('displays the reference text', async () => {
    createComponent();

    await waitForPromises();
    expect(wrapper.text()).toContain(referenceText);
  });
});
