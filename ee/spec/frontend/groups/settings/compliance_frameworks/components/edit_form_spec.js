import VueApollo from 'vue-apollo';
import { createLocalVue, shallowMount } from '@vue/test-utils';

import waitForPromises from 'helpers/wait_for_promises';
import createMockApollo from 'helpers/mock_apollo_helper';

import getComplianceFrameworkQuery from 'ee/groups/settings/compliance_frameworks/graphql/queries/get_compliance_framework.query.graphql';
import updateComplianceFrameworkMutation from 'ee/groups/settings/compliance_frameworks/graphql/queries/update_compliance_framework.mutation.graphql';
import EditForm from 'ee/groups/settings/compliance_frameworks/components/edit_form.vue';
import SharedForm from 'ee/groups/settings/compliance_frameworks/components/shared_form.vue';
import FormStatus from 'ee/groups/settings/compliance_frameworks/components/form_status.vue';
import { FETCH_ERROR, SAVE_ERROR } from 'ee/groups/settings/compliance_frameworks/constants';
import { visitUrl } from '~/lib/utils/url_utility';

import * as Sentry from '~/sentry/wrapper';
import {
  validFetchOneResponse,
  emptyFetchResponse,
  frameworkFoundResponse,
  validUpdateResponse,
  errorUpdateResponse,
} from '../mock_data';

const localVue = createLocalVue();
localVue.use(VueApollo);

jest.mock('~/lib/utils/url_utility');

describe('EditForm', () => {
  let wrapper;
  const propsData = {
    graphqlFieldName: 'ComplianceManagement::Framework',
    groupEditPath: 'group-1/edit',
    groupPath: 'group-1',
    id: '1',
  };

  const sentryError = new Error('Network error');
  const sentrySaveError = new Error('Invalid values given');

  const fetchOne = jest.fn().mockResolvedValue(validFetchOneResponse);
  const fetchEmpty = jest.fn().mockResolvedValue(emptyFetchResponse);
  const fetchLoading = jest.fn().mockResolvedValue(new Promise(() => {}));
  const fetchWithErrors = jest.fn().mockRejectedValue(sentryError);

  const update = jest.fn().mockResolvedValue(validUpdateResponse);
  const updateWithNetworkErrors = jest.fn().mockRejectedValue(sentryError);
  const updateWithErrors = jest.fn().mockResolvedValue(errorUpdateResponse);

  const findForm = () => wrapper.findComponent(SharedForm);
  const findFormStatus = () => wrapper.findComponent(FormStatus);

  function createMockApolloProvider(requestHandlers) {
    localVue.use(VueApollo);

    return createMockApollo(requestHandlers);
  }

  function createComponent(requestHandlers = []) {
    return shallowMount(EditForm, {
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
      wrapper = createComponent([[getComplianceFrameworkQuery, fetchLoading]]);
    });

    it('passes the loading state to the form status', () => {
      expect(findFormStatus().props('loading')).toBe(true);
    });
  });

  describe('on load', () => {
    it('queries for existing framework data and passes to the form', async () => {
      wrapper = createComponent([[getComplianceFrameworkQuery, fetchOne]]);

      await waitForPromises();

      expect(fetchOne).toHaveBeenCalledTimes(1);
      expect(findForm().props()).toStrictEqual({
        name: frameworkFoundResponse.name,
        description: frameworkFoundResponse.description,
        color: frameworkFoundResponse.color,
        groupEditPath: propsData.groupEditPath,
      });
      expect(findForm().exists()).toBe(true);
    });

    it('passes the error to the form status if the existing framework query returns no data', async () => {
      jest.spyOn(Sentry, 'captureException');
      wrapper = createComponent([[getComplianceFrameworkQuery, fetchEmpty]]);

      await waitForPromises();

      expect(fetchEmpty).toHaveBeenCalledTimes(1);
      expect(findFormStatus().props('loading')).toBe(false);
      expect(findFormStatus().props('error')).toBe(FETCH_ERROR);
      expect(Sentry.captureException.mock.calls[0][0]).toStrictEqual(new Error(FETCH_ERROR));
    });

    it('passes the error to the form status if the existing framework query fails', async () => {
      jest.spyOn(Sentry, 'captureException');
      wrapper = createComponent([[getComplianceFrameworkQuery, fetchWithErrors]]);

      await waitForPromises();

      expect(fetchWithErrors).toHaveBeenCalledTimes(1);
      expect(findFormStatus().props('loading')).toBe(false);
      expect(findForm().exists()).toBe(false);
      expect(findFormStatus().props('error')).toBe(FETCH_ERROR);
      expect(Sentry.captureException.mock.calls[0][0].networkError).toBe(sentryError);
    });
  });

  describe('onSubmit', () => {
    const name = 'Test';
    const description = 'Test description';
    const color = '#000000';
    const updateProps = {
      input: {
        id: 'gid://gitlab/ComplianceManagement::Framework/1',
        params: {
          name,
          description,
          color,
        },
      },
    };

    it('passes the error to the form status when saving causes an exception and does not redirect', async () => {
      jest.spyOn(Sentry, 'captureException');
      wrapper = createComponent([
        [getComplianceFrameworkQuery, fetchOne],
        [updateComplianceFrameworkMutation, updateWithNetworkErrors],
      ]);

      await submitForm(name, description, color);

      expect(updateWithNetworkErrors).toHaveBeenCalledWith(updateProps);
      expect(findFormStatus().props('loading')).toBe(false);
      expect(visitUrl).not.toHaveBeenCalled();
      expect(findFormStatus().props('error')).toBe(SAVE_ERROR);
      expect(Sentry.captureException.mock.calls[0][0].networkError).toStrictEqual(sentryError);
    });

    it('passes the errors to the form status when saving fails and does not redirect', async () => {
      jest.spyOn(Sentry, 'captureException');
      wrapper = createComponent([
        [getComplianceFrameworkQuery, fetchOne],
        [updateComplianceFrameworkMutation, updateWithErrors],
      ]);

      await submitForm(name, description, color);

      expect(updateWithErrors).toHaveBeenCalledWith(updateProps);
      expect(findFormStatus().props('loading')).toBe(false);
      expect(visitUrl).not.toHaveBeenCalled();
      expect(findFormStatus().props('error')).toBe('Invalid values given');
      expect(Sentry.captureException.mock.calls[0][0]).toStrictEqual(sentrySaveError);
    });

    it('saves inputted values and redirects', async () => {
      wrapper = createComponent([
        [getComplianceFrameworkQuery, fetchOne],
        [updateComplianceFrameworkMutation, update],
      ]);

      await submitForm(name, description, color);

      expect(update).toHaveBeenCalledWith(updateProps);
      expect(findFormStatus().props('loading')).toBe(false);
      expect(visitUrl).toHaveBeenCalledWith(propsData.groupEditPath);
    });
  });
});
