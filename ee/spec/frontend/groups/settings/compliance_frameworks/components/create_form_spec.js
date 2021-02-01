import VueApollo from 'vue-apollo';
import { createLocalVue, shallowMount } from '@vue/test-utils';

import waitForPromises from 'helpers/wait_for_promises';
import createMockApollo from 'helpers/mock_apollo_helper';

import createComplianceFrameworkMutation from 'ee/groups/settings/compliance_frameworks/graphql/queries/create_compliance_framework.mutation.graphql';
import CreateForm from 'ee/groups/settings/compliance_frameworks/components/create_form.vue';
import SharedForm from 'ee/groups/settings/compliance_frameworks/components/shared_form.vue';
import { visitUrl } from '~/lib/utils/url_utility';

import * as Sentry from '~/sentry/wrapper';
import { validCreateResponse, errorCreateResponse } from '../mock_data';

const localVue = createLocalVue();
localVue.use(VueApollo);

jest.mock('~/lib/utils/url_utility');

describe('Form', () => {
  let wrapper;
  const sentryError = new Error('Network error');
  const sentrySaveError = new Error('Invalid values given');
  const propsData = {
    groupPath: 'group-1',
    groupEditPath: 'group-1/edit',
    scopedLabelsHelpPath: 'help/scoped-labels',
  };

  const create = jest.fn().mockResolvedValue(validCreateResponse);
  const createWithNetworkErrors = jest.fn().mockRejectedValue(sentryError);
  const createWithErrors = jest.fn().mockResolvedValue(errorCreateResponse);

  const findForm = () => wrapper.findComponent(SharedForm);

  function createMockApolloProvider(requestHandlers) {
    localVue.use(VueApollo);

    return createMockApollo(requestHandlers);
  }

  function createComponent(requestHandlers = []) {
    return shallowMount(CreateForm, {
      localVue,
      apolloProvider: createMockApolloProvider(requestHandlers),
      propsData,
    });
  }

  afterEach(() => {
    wrapper.destroy();
  });

  describe('loading', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('passes the loading state to the form', () => {
      expect(findForm().props('loading')).toBe(false);
      expect(findForm().props('renderForm')).toBe(true);
    });
  });

  describe('onSubmit', () => {
    const name = 'Test';
    const description = 'Test description';
    const color = '#000000';
    const creationProps = {
      input: {
        namespacePath: 'group-1',
        params: {
          name,
          description,
          color,
        },
      },
    };

    it('passes the error to the form when saving causes an exception and does not redirect', async () => {
      jest.spyOn(Sentry, 'captureException');
      wrapper = createComponent([[createComplianceFrameworkMutation, createWithNetworkErrors]]);

      await waitForPromises();
      findForm().vm.$emit('submit', { name, description, color });
      await waitForPromises();

      expect(createWithNetworkErrors).toHaveBeenCalledWith(creationProps);
      expect(findForm().props('loading')).toBe(false);
      expect(findForm().props('renderForm')).toBe(true);
      expect(visitUrl).not.toHaveBeenCalled();
      expect(findForm().props('error')).toBe(
        'Unable to save this compliance framework. Please try again',
      );
      expect(Sentry.captureException.mock.calls[0][0].networkError).toStrictEqual(sentryError);
    });

    it('passes the errors to the form when saving fails and does not redirect', async () => {
      jest.spyOn(Sentry, 'captureException');
      wrapper = createComponent([[createComplianceFrameworkMutation, createWithErrors]]);

      await waitForPromises();
      findForm().vm.$emit('submit', { name, description, color });
      await waitForPromises();

      expect(createWithErrors).toHaveBeenCalledWith(creationProps);
      expect(findForm().props('loading')).toBe(false);
      expect(findForm().props('renderForm')).toBe(true);
      expect(visitUrl).not.toHaveBeenCalled();
      expect(findForm().props('error')).toBe('Invalid values given');
      expect(Sentry.captureException.mock.calls[0][0]).toStrictEqual(sentrySaveError);
    });

    it('saves inputted values and redirects', async () => {
      wrapper = createComponent([[createComplianceFrameworkMutation, create]]);

      await waitForPromises();
      findForm().vm.$emit('submit', { name, description, color });
      await waitForPromises();

      expect(create).toHaveBeenCalledWith(creationProps);
      expect(findForm().props('loading')).toBe(false);
      expect(findForm().props('renderForm')).toBe(true);
      expect(visitUrl).toHaveBeenCalledWith(propsData.groupEditPath);
    });
  });
});
