import { GlAlert, GlLink } from '@gitlab/ui';
import { within } from '@testing-library/dom';
import { mount, shallowMount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import { nextTick } from 'vue';
import RelatedJiraIssues, { i18n } from 'ee/vulnerabilities/components/related_jira_issues.vue';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import axios from '~/lib/utils/axios_utils';
import httpStatusCodes from '~/lib/utils/http_status';
import { sprintf } from '~/locale';

const mockAxios = new MockAdapter(axios);

describe('EE RelatedJiraIssues Component', () => {
  let wrapper;

  const defaultProvide = {
    createJiraIssueUrl: 'http://createNewJiraIssue',
    relatedJiraIssuesPath: 'http://fetchRelatedIssues',
    relatedJiraIssuesHelpPath: 'http://helpPage',
    jiraIntegrationSettingsPath: 'http://jiraIntegrationSettings',
  };

  const TEST_ISSUES = [
    {
      web_url: 'http://example.com',
      title: 'Issue #1',
      references: { relative: 'TES-1' },
    },
    {
      web_url: 'http://example.com',
      title: 'Issue #2',
      references: { relative: 'TES-2' },
    },
  ];

  const createWrapper = (mountFn) => () => {
    return extendedWrapper(mountFn(RelatedJiraIssues, { provide: defaultProvide }));
  };
  const createFullWrapper = createWrapper(mount);
  const createShallowWrapper = createWrapper(shallowMount);

  const withResponse = async (
    createWrapperFn,
    { statusCode = httpStatusCodes.OK, data, waitForRequestsToFinish = true },
  ) => {
    mockAxios.onGet(defaultProvide.relatedJiraIssuesPath).replyOnce(statusCode, data);
    const wrapperWithResponse = createWrapperFn();

    if (waitForRequestsToFinish) {
      await axios.waitForAll();
    }

    return wrapperWithResponse;
  };

  const withinComponent = () => within(wrapper.element);
  const findAlert = () => wrapper.findComponent(GlAlert);
  const findRelatedJiraIssuesCount = () => wrapper.findByTestId('related-jira-issues-count');
  const findCreateJiraIssueLink = () => wrapper.findByTestId('create-new-jira-issue');
  const findRelatedJiraIssuesSection = () => wrapper.findByTestId('related-jira-issues-section');
  const withinRelatedJiraIssuesSection = () => within(findRelatedJiraIssuesSection().element);

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
    mockAxios.reset();
  });

  describe('fetch related issues error message', () => {
    it('is not showing by default', () => {
      wrapper = createShallowWrapper();

      expect(findAlert().exists()).toBe(false);
    });

    describe('with error while fetching related Jira issues', () => {
      beforeEach(async () => {
        wrapper = await withResponse(createFullWrapper, { statusCode: httpStatusCodes });
      });

      it('shows when there is an error while fetching the related jira issues', () => {
        expect(findAlert().exists()).toBe(true);
      });

      it('shows a message describing the error', () => {
        const expectedLinkText = sprintf(i18n.fetchErrorMessage, { linkStart: '', linkEnd: '' });

        expect(findAlert().text()).toBe(expectedLinkText);
      });

      it('shows a link to the Jira integration settings', () => {
        expect(findAlert().findComponent(GlLink).attributes('href')).toBe(
          defaultProvide.jiraIntegrationSettingsPath,
        );
      });

      it('can be dismissed', async () => {
        findAlert().vm.$emit('dismiss');
        await nextTick();

        expect(findAlert().exists()).toBe(false);
      });
    });
  });

  describe('header', () => {
    describe('static content', () => {
      beforeEach(() => {
        wrapper = createFullWrapper();
      });

      it('shows a heading', () => {
        expect(withinComponent().getByRole('heading', { name: i18n.cardHeading })).not.toBe(
          undefined,
        );
      });

      it('shows a link to a help page', () => {
        expect(
          withinComponent().getByLabelText(i18n.helpPageLinkLabel, {
            selector: `[href="${defaultProvide.relatedJiraIssuesHelpPath}"]`,
          }),
        ).not.toBe(undefined);
      });

      it('shows a link to create a new Jira issues', () => {
        const createNewJiraIssueLink = findCreateJiraIssueLink();

        expect(createNewJiraIssueLink.exists()).toBe(true);
        expect(createNewJiraIssueLink.attributes('href')).toBe(defaultProvide.createJiraIssueUrl);
        expect(createNewJiraIssueLink.props('icon')).toBe('external-link');
        expect(createNewJiraIssueLink.text()).toMatch(i18n.createNewIssueLinkText);
      });
    });

    describe('related issues count', () => {
      it('shows a placeholder while fetching', async () => {
        wrapper = await withResponse(createFullWrapper, {
          data: [],
          waitForRequestsToFinish: false,
        });

        expect(findRelatedJiraIssuesCount().text()).toBe('...');
      });

      it('shows the number of fetched issues', async () => {
        wrapper = await withResponse(createFullWrapper, {
          data: TEST_ISSUES,
        });

        expect(findRelatedJiraIssuesCount().text()).toBe(`${TEST_ISSUES.length}`);
      });
    });
  });

  describe('body', () => {
    describe.each(TEST_ISSUES)('related Jira issues', (issue) => {
      beforeEach(async () => {
        wrapper = await withResponse(createFullWrapper, {
          data: TEST_ISSUES,
        });
      });

      it('shows the issue title with a link to the issue', () => {
        expect(
          withinRelatedJiraIssuesSection().getByText(issue.title, {
            selector: `[href="${issue.web_url}"]`,
          }),
        ).not.toBe(undefined);
      });

      it('shows the related Jira project-id', () => {
        expect(
          withinRelatedJiraIssuesSection().getByText(`#${issue.references.relative}`),
        ).not.toBe(undefined);
      });
    });

    it('is hidden when there are no related issues', async () => {
      wrapper = await withResponse(createFullWrapper, {
        data: [],
      });

      expect(findRelatedJiraIssuesSection().isVisible()).toBe(false);
    });
  });
});
