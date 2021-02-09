import VueApollo from 'vue-apollo';
import { createLocalVue, shallowMount } from '@vue/test-utils';

import waitForPromises from 'helpers/wait_for_promises';
import createMockApollo from 'helpers/mock_apollo_helper';

import createComplianceFrameworkMutation from 'ee/groups/settings/compliance_frameworks/graphql/queries/create_compliance_framework.mutation.graphql';
import CreateForm from 'ee/groups/settings/compliance_frameworks/components/create_form.vue';
import SharedForm from 'ee/groups/settings/compliance_frameworks/components/shared_form.vue';
import FormStatus from 'ee/groups/settings/compliance_frameworks/components/form_status.vue';
import { SAVE_ERROR } from 'ee/groups/settings/compliance_frameworks/constants';
import { visitUrl } from '~/lib/utils/url_utility';

import * as Sentry from '~/sentry/wrapper';
import { validCreateResponse, errorCreateResponse } from '../mock_data';

const localVue = createLocalVue();
localVue.use(VueApollo);

jest.mock('~/lib/utils/url_utility');

describe('CreateForm', () => {
  let wrapper;

  const propsData = {
    groupPath: 'group-1',
    groupEditPath: 'group-1/edit',
  };

  const sentryError = new Error('Network error');
  const sentrySaveError = new Error('Invalid values given');

  const create = jest.fn().mockResolvedValue(validCreateResponse);
  const createWithNetworkErrors = jest.fn().mockRejectedValue(sentryError);
  const createWithErrors = jest.fn().mockResolvedValue(errorCreateResponse);

  const findForm = () => wrapper.findComponent(SharedForm);
  const findFormStatus = () => wrapper.findComponent(FormStatus);

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

  async function submitForm(name, description, color) {
    await waitForPromises();

    findForm().vm.$emit('update:name', name);
    findForm().vm.$emit('update:description', description);
    findForm().vm.$emit('update:color', color);
    findForm().vm.$emit('submit');

    await waitForPromises();
  }

  afterEach(() => {
    wrapper.destroy();
  });

  describe('loading', () => {
    beforeEach(() => {
      wrapper = createComponent();
    });

    it('passes the loading state to the form status', () => {
      expect(findFormStatus().props('loading')).toBe(false);
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

    it('passes the error to the form status when saving causes an exception and does not redirect', async () => {
      jest.spyOn(Sentry, 'captureException');
      wrapper = createComponent([[createComplianceFrameworkMutation, createWithNetworkErrors]]);

      await submitForm(name, description, color);

      expect(createWithNetworkErrors).toHaveBeenCalledWith(creationProps);
      expect(findFormStatus().props('loading')).toBe(false);
      expect(visitUrl).not.toHaveBeenCalled();
      expect(findFormStatus().props('error')).toBe(SAVE_ERROR);
      expect(Sentry.captureException.mock.calls[0][0].networkError).toStrictEqual(sentryError);
    });

    it('passes the errors to the form status when saving fails and does not redirect', async () => {
      jest.spyOn(Sentry, 'captureException');
      wrapper = createComponent([[createComplianceFrameworkMutation, createWithErrors]]);

      await submitForm(name, description, color);

      expect(createWithErrors).toHaveBeenCalledWith(creationProps);
      expect(findFormStatus().props('loading')).toBe(false);
      expect(visitUrl).not.toHaveBeenCalled();
      expect(findFormStatus().props('error')).toBe('Invalid values given');
      expect(Sentry.captureException.mock.calls[0][0]).toStrictEqual(sentrySaveError);
    });

    it('saves inputted values and redirects', async () => {
      wrapper = createComponent([[createComplianceFrameworkMutation, create]]);

      await submitForm(name, description, color);

      expect(create).toHaveBeenCalledWith(creationProps);
      expect(findFormStatus().props('loading')).toBe(false);
      expect(visitUrl).toHaveBeenCalledWith(propsData.groupEditPath);
    });
  });
});
