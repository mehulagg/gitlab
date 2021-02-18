import { GlSprintf, GlModal } from '@gitlab/ui';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import VueApollo from 'vue-apollo';

import DeleteModal from 'ee/groups/settings/compliance_frameworks/components/delete_modal.vue';
import { DELETE_MODAL_ID } from 'ee/groups/settings/compliance_frameworks/constants';
import deleteComplianceFrameworkMutation from 'ee/groups/settings/compliance_frameworks/graphql/mutations/delete_compliance_framework.mutation.graphql';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';
import * as Sentry from '~/sentry/wrapper';
import { validDeleteResponse, errorDeleteResponse } from '../mock_data';

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('DeleteModal', () => {
  let wrapper;

  const networkError = new Error('network error');
  const deleteSuccess = jest.fn().mockResolvedValue(validDeleteResponse);
  const deleteError = jest.fn().mockResolvedValue(errorDeleteResponse);
  const deleteNetworkError = jest.fn().mockRejectedValue(networkError);

  const framework = {
    id: 'gid://gitlab/ComplianceManagement::Framework/1',
    name: 'gdpr',
    description: 'a framework',
    color: '#112233',
  };

  const findModal = () => wrapper.findComponent(GlModal);
  const clickDeleteFramework = () => findModal().vm.$emit('primary');

  function createMockApolloProvider(resolverMock) {
    localVue.use(VueApollo);

    const requestHandlers = [[deleteComplianceFrameworkMutation, resolverMock]];

    return createMockApollo(requestHandlers);
  }

  const createComponent = (resolverMock) => {
    wrapper = shallowMount(DeleteModal, {
      localVue,
      apolloProvider: createMockApolloProvider(resolverMock),
      propsData: {
        framework,
      },
      stubs: {
        GlSprintf,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('component layout', () => {
    beforeEach(() => {
      createComponent();
    });

    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });

    it('sets the modal id', () => {
      expect(findModal().props('modalId')).toBe(DELETE_MODAL_ID);
    });

    it('sets the modal primary button attributes', () => {
      const actionPrimary = findModal().props('actionPrimary');

      expect(actionPrimary.text).toBe('Delete framework');
      // expect(actionPrimary.attributes[0].variant).toBe('danger');
    });

    it('sets the modal cancel button attributes', () => {
      expect(findModal().props('actionCancel').text).toBe('Cancel');
    });
  });

  describe('clickDeleteFramework', () => {
    it('emits "deleting" event when busy deleting', () => {
      createComponent();
      clickDeleteFramework();

      expect(wrapper.emitted('deleting').length).toBe(1);
    });

    it('calls the delete mutation with the framework ID', async () => {
      createComponent(deleteSuccess);
      clickDeleteFramework();

      await waitForPromises();

      expect(deleteSuccess).toHaveBeenCalledWith({ input: { id: framework.id } });
    });

    it('emits "delete" event when the framework is successfully deleted', async () => {
      createComponent(deleteSuccess);
      clickDeleteFramework();

      await waitForPromises();

      expect(wrapper.emitted('delete').length).toBe(1);
    });

    it('emits "error" event and reports to Sentry when there is a network error', async () => {
      jest.spyOn(Sentry, 'captureException');
      createComponent(deleteNetworkError);
      clickDeleteFramework();

      await waitForPromises();

      expect(wrapper.emitted('error').length).toBe(1);
      expect(Sentry.captureException.mock.calls[0][0].networkError).toStrictEqual(networkError);
    });

    it('emits "error" event and reports to Sentry when there is a graphql error', async () => {
      jest.spyOn(Sentry, 'captureException');
      createComponent(deleteError);
      clickDeleteFramework();

      await waitForPromises();

      expect(wrapper.emitted('error').length).toBe(1);
      expect(Sentry.captureException.mock.calls[0][0]).toStrictEqual(new Error('graphql error'));
    });
  });
});
