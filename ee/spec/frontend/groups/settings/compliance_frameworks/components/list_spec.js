import { GlAlert, GlLoadingIcon, GlTab, GlTabs } from '@gitlab/ui';
import VueApollo from 'vue-apollo';
import { createLocalVue, shallowMount } from '@vue/test-utils';

import waitForPromises from 'helpers/wait_for_promises';
import createMockApollo from 'helpers/mock_apollo_helper';

import getComplianceFrameworkQuery from 'ee/groups/settings/compliance_frameworks/graphql/queries/get_compliance_framework.query.graphql';
import List from 'ee/groups/settings/compliance_frameworks/components/list.vue';
import ListItem from 'ee/groups/settings/compliance_frameworks/components/list_item.vue';
import EmptyState from 'ee/groups/settings/compliance_frameworks/components/list_empty_state.vue';

import * as Sentry from '~/sentry/wrapper';
import { validFetchResponse, emptyFetchResponse } from '../mock_data';

const localVue = createLocalVue();
localVue.use(VueApollo);

describe('List', () => {
  let wrapper;
  const sentryError = new Error('Network error');

  const fetch = jest.fn().mockResolvedValue(validFetchResponse);
  const fetchEmpty = jest.fn().mockResolvedValue(emptyFetchResponse);
  const fetchLoading = jest.fn().mockResolvedValue(new Promise(() => {}));
  const fetchWithErrors = jest.fn().mockRejectedValue(sentryError);

  const findAlert = () => wrapper.find(GlAlert);
  const findLoadingIcon = () => wrapper.find(GlLoadingIcon);
  const findEmptyState = () => wrapper.find(EmptyState);
  const findTabs = () => wrapper.findAll(GlTab);
  const findTabsContainer = () => wrapper.find(GlTabs);
  const findListItems = () => wrapper.findAll(ListItem);

  function createMockApolloProvider(resolverMock) {
    localVue.use(VueApollo);

    const requestHandlers = [[getComplianceFrameworkQuery, resolverMock]];

    return createMockApollo(requestHandlers);
  }

  function createComponentWithApollo(resolverMock) {
    return shallowMount(List, {
      localVue,
      apolloProvider: createMockApolloProvider(resolverMock),
      propsData: {
        emptyStateSvgPath: 'dir/image.svg',
        groupPath: 'group-1',
      },
      stubs: {
        GlLoadingIcon,
        GlTab,
        GlTabs,
      },
    });
  }

  afterEach(() => {
    wrapper.destroy();
  });

  describe('loading', () => {
    beforeEach(() => {
      wrapper = createComponentWithApollo(fetchLoading);
    });

    it('shows the loader', () => {
      expect(findLoadingIcon().exists()).toBe(true);
    });

    it('does not show the other parts of the app', () => {
      expect(findAlert().exists()).toBe(false);
      expect(findTabsContainer().exists()).toBe(false);
      expect(findEmptyState().exists()).toBe(false);
    });
  });

  describe('fetching error', () => {
    beforeEach(() => {
      wrapper = createComponentWithApollo(fetchWithErrors);
    });

    it('shows the alert', () => {
      expect(findAlert().text()).toBe(
        'Error fetching compliance frameworks data. Please refresh the page',
      );
    });

    it('does not show the other parts of the app', () => {
      expect(findLoadingIcon().exists()).toBe(false);
      expect(findTabsContainer().exists()).toBe(false);
      expect(findEmptyState().exists()).toBe(false);
    });

    it('should fetch data once', () => {
      expect(fetchWithErrors).toHaveBeenCalledTimes(1);
    });

    it('sends the error to Sentry', async () => {
      jest.spyOn(Sentry, 'captureException');

      await waitForPromises();

      expect(Sentry.captureException.mock.calls[0][0].networkError).toBe(sentryError);
    });
  });

  describe('empty state', () => {
    beforeEach(() => {
      wrapper = createComponentWithApollo(fetchEmpty);
    });

    it('shows the empty state', () => {
      expect(findEmptyState().exists()).toBe(true);
      expect(findEmptyState().props('imagePath')).toBe('dir/image.svg');
    });

    it('does not show the other parts of the app', () => {
      expect(findAlert().exists()).toBe(false);
      expect(findLoadingIcon().exists()).toBe(false);
      expect(findTabsContainer().exists()).toBe(false);
    });
  });

  describe('content', () => {
    beforeEach(() => {
      wrapper = createComponentWithApollo(fetch);
    });

    it('does not show the other parts of the app', () => {
      expect(findAlert().exists()).toBe(false);
      expect(findLoadingIcon().exists()).toBe(false);
      expect(findEmptyState().exists()).toBe(false);
    });

    it('shows the tabs', () => {
      expect(findTabsContainer().exists()).toBe(true);
      expect(findTabs()).toHaveLength(2);
    });

    it('shows the all tab', () => {
      expect(findTabs().at(0).attributes('title')).toBe('All');
    });

    it('shows the disabled regulated tab', () => {
      const tab = findTabs().at(1);

      expect(tab.attributes('title')).toBe('Regulated');
      expect(tab.attributes('disabled')).toBe('true');
    });

    it('shows the list items with expect props', () => {
      expect(findListItems()).toHaveLength(2);

      findListItems().wrappers.forEach((item) =>
        expect(item.props()).toEqual(
          expect.objectContaining({
            framework: {
              id: expect.stringContaining('gid://gitlab/ComplianceManagement::Framework/'),
              parsedId: expect.any(Number),
              name: expect.any(String),
              description: expect.any(String),
              color: expect.stringMatching(/^#([0-9A-F]{3}){1,2}$/i),
            },
          }),
        ),
      );
    });
  });
});
