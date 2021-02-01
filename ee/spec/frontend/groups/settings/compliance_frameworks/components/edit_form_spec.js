import VueApollo from 'vue-apollo';
import { createLocalVue, shallowMount } from '@vue/test-utils';

import waitForPromises from 'helpers/wait_for_promises';
import createMockApollo from 'helpers/mock_apollo_helper';

import getComplianceFrameworkQuery from 'ee/groups/settings/compliance_frameworks/graphql/queries/get_compliance_framework.query.graphql';
import updateComplianceFrameworkMutation from 'ee/groups/settings/compliance_frameworks/graphql/queries/update_compliance_framework.mutation.graphql';
import EditForm from 'ee/groups/settings/compliance_frameworks/components/edit_form.vue';
import SharedForm from 'ee/groups/settings/compliance_frameworks/components/shared_form.vue';
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

describe('Form', () => {
  let wrapper;
  const sentryError = new Error('Network error');
  const sentrySaveError = new Error('Invalid values given');
  const propsData = {
    graphqlFieldName: 'field',
    groupPath: 'group-1',
    groupEditPath: 'group-1/edit',
    id: '1',
    scopedLabelsHelpPath: 'help/scoped-labels',
  };

  const fetchOne = jest.fn().mockResolvedValue(validFetchOneResponse);
  const fetchEmpty = jest.fn().mockResolvedValue(emptyFetchResponse);
  const fetchLoading = jest.fn().mockResolvedValue(new Promise(() => {}));
  const fetchWithErrors = jest.fn().mockRejectedValue(sentryError);

  const update = jest.fn().mockResolvedValue(validUpdateResponse);
  const updateWithNetworkErrors = jest.fn().mockRejectedValue(sentryError);
  const updateWithErrors = jest.fn().mockResolvedValue(errorUpdateResponse);

  const findForm = () => wrapper.findComponent(SharedForm);

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

  afterEach(() => {
    wrapper.destroy();
  });

  describe('loading', () => {
    beforeEach(() => {
      wrapper = createComponent([[getComplianceFrameworkQuery, fetchLoading]]);
    });

    it('passes the loading state to the form', () => {
      expect(findForm().props('loading')).toBe(true);
      expect(findForm().props('renderForm')).toBe(false);
    });
  });

  describe('on load', () => {
    it('queries for existing framework data and passes to the form', async () => {
      wrapper = createComponent([[getComplianceFrameworkQuery, fetchOne]]);

      await waitForPromises();

      expect(fetchOne).toHaveBeenCalledTimes(1);
      expect(findForm().props('complianceFramework')).toMatchObject(frameworkFoundResponse);
      expect(findForm().props('renderForm')).toBe(true);
    });

    it('passes the error to the form if the existing framework query returns no data', async () => {
      jest.spyOn(Sentry, 'captureException');
      wrapper = createComponent([[getComplianceFrameworkQuery, fetchEmpty]]);

      await waitForPromises();

      expect(fetchEmpty).toHaveBeenCalledTimes(1);
      expect(findForm().props('loading')).toBe(false);
      expect(findForm().props('renderForm')).toBe(false);
      expect(findForm().props('error')).toBe(
        'Error fetching compliance frameworks data. Please refresh the page',
      );
      expect(Sentry.captureException.mock.calls[0][0]).toStrictEqual(
        new Error('Error fetching compliance frameworks data. Please refresh the page'),
      );
    });

    it('passes the error to the form if the existing framework query fails', async () => {
      jest.spyOn(Sentry, 'captureException');
      wrapper = createComponent([[getComplianceFrameworkQuery, fetchWithErrors]]);

      await waitForPromises();

      expect(fetchWithErrors).toHaveBeenCalledTimes(1);
      expect(findForm().props('loading')).toBe(false);
      expect(findForm().props('renderForm')).toBe(false);
      expect(findForm().props('error')).toBe(
        'Error fetching compliance frameworks data. Please refresh the page',
      );
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

    it('passes the error to the form when saving causes an exception and does not redirect', async () => {
      jest.spyOn(Sentry, 'captureException');
      wrapper = createComponent([
        [getComplianceFrameworkQuery, fetchOne],
        [updateComplianceFrameworkMutation, updateWithNetworkErrors],
      ]);

      await waitForPromises();
      findForm().vm.$emit('submit', { name, description, color });
      await waitForPromises();

      expect(updateWithNetworkErrors).toHaveBeenCalledWith(updateProps);
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
      wrapper = createComponent([
        [getComplianceFrameworkQuery, fetchOne],
        [updateComplianceFrameworkMutation, updateWithErrors],
      ]);

      await waitForPromises();
      findForm().vm.$emit('submit', { name, description, color });
      await waitForPromises();

      expect(updateWithErrors).toHaveBeenCalledWith(updateProps);
      expect(findForm().props('loading')).toBe(false);
      expect(findForm().props('renderForm')).toBe(true);
      expect(visitUrl).not.toHaveBeenCalled();
      expect(findForm().props('error')).toBe('Invalid values given');
      expect(Sentry.captureException.mock.calls[0][0]).toStrictEqual(sentrySaveError);
    });

    it('saves inputted values and redirects', async () => {
      wrapper = createComponent([
        [getComplianceFrameworkQuery, fetchOne],
        [updateComplianceFrameworkMutation, update],
      ]);

      await waitForPromises();
      findForm().vm.$emit('submit', { name, description, color });
      await waitForPromises();

      expect(update).toHaveBeenCalledWith(updateProps);
      expect(findForm().props('loading')).toBe(false);
      expect(findForm().props('renderForm')).toBe(true);
      expect(visitUrl).toHaveBeenCalledWith(propsData.groupEditPath);
    });
  });
});
