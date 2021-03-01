import { GlLoadingIcon } from '@gitlab/ui';
import { mount, createLocalVue } from '@vue/test-utils';
import AxiosMockAdapter from 'axios-mock-adapter';
import VueApollo from 'vue-apollo';
import createHttpIntegrationMutation from 'ee_else_ce/alerts_settings/graphql/mutations/create_http_integration.mutation.graphql';
import updateHttpIntegrationMutation from 'ee_else_ce/alerts_settings/graphql/mutations/update_http_integration.mutation.graphql';
import createMockApollo from 'helpers/mock_apollo_helper';
import { useMockIntersectionObserver } from 'helpers/mock_dom_observer';
import waitForPromises from 'helpers/wait_for_promises';
import IntegrationsList from '~/alerts_settings/components/alerts_integrations_list.vue';
import AlertsSettingsForm from '~/alerts_settings/components/alerts_settings_form.vue';
import AlertsSettingsWrapper from '~/alerts_settings/components/alerts_settings_wrapper.vue';
import { typeSet } from '~/alerts_settings/constants';
import createPrometheusIntegrationMutation from '~/alerts_settings/graphql/mutations/create_prometheus_integration.mutation.graphql';
import destroyHttpIntegrationMutation from '~/alerts_settings/graphql/mutations/destroy_http_integration.mutation.graphql';
import resetHttpTokenMutation from '~/alerts_settings/graphql/mutations/reset_http_token.mutation.graphql';
import resetPrometheusTokenMutation from '~/alerts_settings/graphql/mutations/reset_prometheus_token.mutation.graphql';
import updateCurrentHttpIntegrationMutation from '~/alerts_settings/graphql/mutations/update_current_http_integration.mutation.graphql';
import updateCurrentPrometheusIntegrationMutation from '~/alerts_settings/graphql/mutations/update_current_prometheus_integration.mutation.graphql';
import updatePrometheusIntegrationMutation from '~/alerts_settings/graphql/mutations/update_prometheus_integration.mutation.graphql';
import getIntegrationsQuery from '~/alerts_settings/graphql/queries/get_integrations.query.graphql';
import {
  ADD_INTEGRATION_ERROR,
  RESET_INTEGRATION_TOKEN_ERROR,
  UPDATE_INTEGRATION_ERROR,
  INTEGRATION_PAYLOAD_TEST_ERROR,
  DELETE_INTEGRATION_ERROR,
} from '~/alerts_settings/utils/error_messages';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import {
  createHttpVariables,
  updateHttpVariables,
  createPrometheusVariables,
  updatePrometheusVariables,
  HTTP_ID,
  PROMETHEUS_ID,
  errorMsg,
  getIntegrationsQueryResponse,
  destroyIntegrationResponse,
  integrationToDestroy,
  destroyIntegrationResponseWithErrors,
} from './mocks/apollo_mock';
import mockIntegrations from './mocks/integrations.json';
import { defaultAlertSettingsConfig } from './util';

jest.mock('~/flash');

const localVue = createLocalVue();

describe('AlertsSettingsWrapper', () => {
  let wrapper;
  let fakeApollo;
  let destroyIntegrationHandler;
  useMockIntersectionObserver();
  const httpMappingData = {
    payloadExample: '{"test: : "field"}',
    payloadAttributeMappings: [],
    payloadAlertFields: [],
  };
  const httpIntegrations = {
    list: [
      {
        id: mockIntegrations[0].id,
        ...httpMappingData,
      },
      {
        id: mockIntegrations[1].id,
        ...httpMappingData,
      },
      {
        id: mockIntegrations[2].id,
        httpMappingData,
      },
    ],
  };

  const findLoader = () => wrapper.findComponent(IntegrationsList).findComponent(GlLoadingIcon);
  const findIntegrationsList = () => wrapper.findComponent(IntegrationsList);
  const findIntegrations = () => wrapper.find(IntegrationsList).findAll('table tbody tr');

  async function destroyHttpIntegration(localWrapper) {
    await jest.runOnlyPendingTimers();
    await localWrapper.vm.$nextTick();

    localWrapper
      .find(IntegrationsList)
      .vm.$emit('delete-integration', { id: integrationToDestroy.id });
  }

  async function awaitApolloDomMock() {
    await wrapper.vm.$nextTick(); // kick off the DOM update
    await jest.runOnlyPendingTimers(); // kick off the mocked GQL stuff (promises)
    await wrapper.vm.$nextTick(); // kick off the DOM update for flash
  }

  const createComponent = ({ data = {}, provide = {}, loading = false } = {}) => {
    wrapper = mount(AlertsSettingsWrapper, {
      data() {
        return { ...data };
      },
      provide: {
        ...defaultAlertSettingsConfig,
        ...provide,
      },
      mocks: {
        $apollo: {
          mutate: jest.fn(),
          query: jest.fn(),
          queries: {
            integrations: {
              loading,
            },
          },
        },
      },
    });
  };

  function createComponentWithApollo({
    destroyHandler = jest.fn().mockResolvedValue(destroyIntegrationResponse),
  } = {}) {
    localVue.use(VueApollo);
    destroyIntegrationHandler = destroyHandler;

    const requestHandlers = [
      [getIntegrationsQuery, jest.fn().mockResolvedValue(getIntegrationsQueryResponse)],
      [destroyHttpIntegrationMutation, destroyIntegrationHandler],
    ];

    fakeApollo = createMockApollo(requestHandlers);

    wrapper = mount(AlertsSettingsWrapper, {
      localVue,
      apolloProvider: fakeApollo,
      provide: {
        ...defaultAlertSettingsConfig,
      },
    });
  }

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('rendered via default permissions', () => {
    it('renders the GraphQL alerts integrations list and new form', () => {
      createComponent();
      expect(wrapper.find(IntegrationsList).exists()).toBe(true);
      expect(wrapper.find(AlertsSettingsForm).exists()).toBe(true);
    });

    it('uses a loading state inside the IntegrationsList table', () => {
      createComponent({
        data: { integrations: {} },
        loading: true,
      });
      expect(wrapper.find(IntegrationsList).exists()).toBe(true);
      expect(findLoader().exists()).toBe(true);
    });

    it('renders the IntegrationsList table using the API data', () => {
      createComponent({
        data: { integrations: { list: mockIntegrations }, currentIntegration: mockIntegrations[0] },
        loading: false,
      });
      expect(findLoader().exists()).toBe(false);
      expect(findIntegrations()).toHaveLength(mockIntegrations.length);
    });

    it('calls `$apollo.mutate` with `createHttpIntegrationMutation`', () => {
      createComponent({
        data: { integrations: { list: mockIntegrations }, currentIntegration: mockIntegrations[0] },
        loading: false,
      });

      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockResolvedValue({
        data: { createHttpIntegrationMutation: { integration: { id: '1' } } },
      });
      wrapper.find(AlertsSettingsForm).vm.$emit('create-new-integration', {
        type: typeSet.http,
        variables: createHttpVariables,
      });

      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledTimes(1);
      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
        mutation: createHttpIntegrationMutation,
        update: expect.anything(),
        variables: createHttpVariables,
      });
    });

    it('calls `$apollo.mutate` with `updateHttpIntegrationMutation`', () => {
      createComponent({
        data: { integrations: { list: mockIntegrations }, currentIntegration: mockIntegrations[0] },
        loading: false,
      });

      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockResolvedValue({
        data: { updateHttpIntegrationMutation: { integration: { id: '1' } } },
      });
      wrapper.find(AlertsSettingsForm).vm.$emit('update-integration', {
        type: typeSet.http,
        variables: updateHttpVariables,
      });

      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
        mutation: updateHttpIntegrationMutation,
        variables: updateHttpVariables,
      });
    });

    it('calls `$apollo.mutate` with `resetHttpTokenMutation`', () => {
      createComponent({
        data: { integrations: { list: mockIntegrations }, currentIntegration: mockIntegrations[0] },
        loading: false,
      });

      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockResolvedValue({
        data: { resetHttpTokenMutation: { integration: { id: '1' } } },
      });
      wrapper.find(AlertsSettingsForm).vm.$emit('reset-token', {
        type: typeSet.http,
        variables: { id: HTTP_ID },
      });

      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
        mutation: resetHttpTokenMutation,
        variables: {
          id: HTTP_ID,
        },
      });
    });

    it('calls `$apollo.mutate` with `createPrometheusIntegrationMutation`', () => {
      createComponent({
        data: { integrations: { list: mockIntegrations }, currentIntegration: mockIntegrations[0] },
        loading: false,
      });

      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockResolvedValue({
        data: { createPrometheusIntegrationMutation: { integration: { id: '2' } } },
      });
      wrapper.find(AlertsSettingsForm).vm.$emit('create-new-integration', {
        type: typeSet.prometheus,
        variables: createPrometheusVariables,
      });

      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledTimes(1);
      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
        mutation: createPrometheusIntegrationMutation,
        update: expect.anything(),
        variables: createPrometheusVariables,
      });
    });

    it('calls `$apollo.mutate` with `updatePrometheusIntegrationMutation`', () => {
      createComponent({
        data: { integrations: { list: mockIntegrations }, currentIntegration: mockIntegrations[3] },
        loading: false,
      });

      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockResolvedValue({
        data: { updatePrometheusIntegrationMutation: { integration: { id: '2' } } },
      });
      wrapper.find(AlertsSettingsForm).vm.$emit('update-integration', {
        type: typeSet.prometheus,
        variables: updatePrometheusVariables,
      });

      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
        mutation: updatePrometheusIntegrationMutation,
        variables: updatePrometheusVariables,
      });
    });

    it('calls `$apollo.mutate` with `resetPrometheusTokenMutation`', () => {
      createComponent({
        data: { integrations: { list: mockIntegrations }, currentIntegration: mockIntegrations[0] },
        loading: false,
      });

      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockResolvedValue({
        data: { resetPrometheusTokenMutation: { integration: { id: '1' } } },
      });
      wrapper.find(AlertsSettingsForm).vm.$emit('reset-token', {
        type: typeSet.prometheus,
        variables: { id: PROMETHEUS_ID },
      });

      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
        mutation: resetPrometheusTokenMutation,
        variables: {
          id: PROMETHEUS_ID,
        },
      });
    });

    it('shows an error alert when integration creation fails ', async () => {
      createComponent({
        data: { integrations: { list: mockIntegrations }, currentIntegration: mockIntegrations[0] },
        loading: false,
      });

      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockRejectedValue(ADD_INTEGRATION_ERROR);
      wrapper.find(AlertsSettingsForm).vm.$emit('create-new-integration', {});

      await waitForPromises();

      expect(createFlash).toHaveBeenCalledWith({ message: ADD_INTEGRATION_ERROR });
    });

    it('shows an error alert when integration token reset fails ', async () => {
      createComponent({
        data: { integrations: { list: mockIntegrations }, currentIntegration: mockIntegrations[0] },
        loading: false,
      });

      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockRejectedValue(RESET_INTEGRATION_TOKEN_ERROR);

      wrapper.find(AlertsSettingsForm).vm.$emit('reset-token', {});

      await waitForPromises();
      expect(createFlash).toHaveBeenCalledWith({ message: RESET_INTEGRATION_TOKEN_ERROR });
    });

    it('shows an error alert when integration update fails ', async () => {
      createComponent({
        data: { integrations: { list: mockIntegrations }, currentIntegration: mockIntegrations[0] },
        loading: false,
      });

      jest.spyOn(wrapper.vm.$apollo, 'mutate').mockRejectedValue(errorMsg);

      wrapper.find(AlertsSettingsForm).vm.$emit('update-integration', {});

      await waitForPromises();
      expect(createFlash).toHaveBeenCalledWith({ message: UPDATE_INTEGRATION_ERROR });
    });

    it('shows an error alert when integration test payload fails ', async () => {
      const mock = new AxiosMockAdapter(axios);
      mock.onPost(/(.*)/).replyOnce(403);
      createComponent({
        data: { integrations: { list: mockIntegrations }, currentIntegration: mockIntegrations[0] },
        loading: false,
      });

      return wrapper.vm.validateAlertPayload({ endpoint: '', data: '', token: '' }).then(() => {
        expect(createFlash).toHaveBeenCalledWith({ message: INTEGRATION_PAYLOAD_TEST_ERROR });
        expect(createFlash).toHaveBeenCalledTimes(1);
        mock.restore();
      });
    });

    it('calls `$apollo.mutate` with `updateCurrentHttpIntegrationMutation` on HTTP integration edit', () => {
      createComponent({
        data: {
          integrations: { list: mockIntegrations },
          currentIntegration: mockIntegrations[0],
          httpIntegrations,
        },
        loading: false,
      });

      jest.spyOn(wrapper.vm.$apollo, 'mutate');
      findIntegrationsList().vm.$emit('edit-integration', updateHttpVariables);
      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
        mutation: updateCurrentHttpIntegrationMutation,
        variables: { ...mockIntegrations[0], ...httpMappingData },
      });
    });

    it('calls `$apollo.mutate` with `updateCurrentPrometheusIntegrationMutation` on PROMETHEUS integration edit', () => {
      createComponent({
        data: {
          integrations: { list: mockIntegrations },
          currentIntegration: mockIntegrations[3],
          httpIntegrations,
        },
        loading: false,
      });

      jest.spyOn(wrapper.vm.$apollo, 'mutate');
      findIntegrationsList().vm.$emit('edit-integration', updatePrometheusVariables);
      expect(wrapper.vm.$apollo.mutate).toHaveBeenCalledWith({
        mutation: updateCurrentPrometheusIntegrationMutation,
        variables: mockIntegrations[3],
      });
    });
  });

  describe('with mocked Apollo client', () => {
    it('has a selection of integrations loaded via the getIntegrationsQuery', async () => {
      createComponentWithApollo();

      await jest.runOnlyPendingTimers();
      await wrapper.vm.$nextTick();

      expect(findIntegrations()).toHaveLength(4);
    });

    it('calls a mutation with correct parameters and destroys a integration', async () => {
      createComponentWithApollo();

      await destroyHttpIntegration(wrapper);

      expect(destroyIntegrationHandler).toHaveBeenCalled();

      await wrapper.vm.$nextTick();

      expect(findIntegrations()).toHaveLength(3);
    });

    it('displays flash if mutation had a recoverable error', async () => {
      createComponentWithApollo({
        destroyHandler: jest.fn().mockResolvedValue(destroyIntegrationResponseWithErrors),
      });

      await destroyHttpIntegration(wrapper);
      await awaitApolloDomMock();

      expect(createFlash).toHaveBeenCalledWith({ message: 'Houston, we have a problem' });
    });

    it('displays flash if mutation had a non-recoverable error', async () => {
      createComponentWithApollo({
        destroyHandler: jest.fn().mockRejectedValue('Error'),
      });

      await destroyHttpIntegration(wrapper);
      await awaitApolloDomMock();

      expect(createFlash).toHaveBeenCalledWith({
        message: DELETE_INTEGRATION_ERROR,
      });
    });
  });
});
