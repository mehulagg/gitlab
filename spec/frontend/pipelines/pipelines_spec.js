import { nextTick } from 'vue';
import { chunk } from 'lodash';
import { mount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import { GlPagination, GlFilteredSearch, GlButton, GlLoadingIcon } from '@gitlab/ui';
import waitForPromises from 'helpers/wait_for_promises';
import Api from '~/api';
import axios from '~/lib/utils/axios_utils';
import NavigationTabs from '~/vue_shared/components/navigation_tabs.vue';
import TablePagination from '~/vue_shared/components/pagination/table_pagination.vue';

import NavigationControls from '~/pipelines/components/pipelines_list/nav_controls.vue';
import EmptyState from '~/pipelines/components/pipelines_list/empty_state.vue';
import BlankState from '~/pipelines/components/pipelines_list/blank_state.vue';
import PipelinesTableComponent from '~/pipelines/components/pipelines_list/pipelines_table.vue';

import PipelinesComponent from '~/pipelines/components/pipelines_list/pipelines.vue';
import Store from '~/pipelines/stores/pipelines_store';
import { RAW_TEXT_WARNING } from '~/pipelines/constants';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import { pipelineWithStages, stageReply, users, mockSearch, branches } from './mock_data';

jest.mock('~/flash');

describe('Pipelines', () => {
  const jsonFixtureName = 'pipelines/pipelines.json';

  preloadFixtures(jsonFixtureName);

  let pipelinesResponse;
  let wrapper;
  let mock;

  const paths = {
    endpoint: 'twitter/flight/pipelines.json',
    autoDevopsHelpPath: '/help/topics/autodevops/index.md',
    helpPagePath: '/help/ci/quick_start/README',
    emptyStateSvgPath: '/assets/illustrations/pipelines_empty.svg',
    errorStateSvgPath: '/assets/illustrations/pipelines_failed.svg',
    noPipelinesSvgPath: '/assets/illustrations/pipelines_pending.svg',
    ciLintPath: '/ci/lint',
    resetCachePath: '/twitter/flight/settings/ci_cd/reset_cache',
    newPipelinePath: '/twitter/flight/pipelines/new',
  };

  const noPermissions = {
    endpoint: 'twitter/flight/pipelines.json',
    autoDevopsHelpPath: '/help/topics/autodevops/index.md',
    helpPagePath: '/help/ci/quick_start/README',
    emptyStateSvgPath: '/assets/illustrations/pipelines_empty.svg',
    errorStateSvgPath: '/assets/illustrations/pipelines_failed.svg',
    noPipelinesSvgPath: '/assets/illustrations/pipelines_pending.svg',
  };

  const defaultProps = {
    hasGitlabCi: true,
    canCreatePipeline: true,
    ...paths,
  };

  const findFilteredSearch = () => wrapper.find(GlFilteredSearch);
  const findByTestId = (id) => wrapper.find(`[data-testid="${id}"]`);
  const findNavigationTabs = () => wrapper.find(NavigationTabs);
  const findNavigationControls = () => wrapper.find(NavigationControls);
  const findTab = (tab) => findByTestId(`pipelines-tab-${tab}`);

  const findRunPipelineButton = () => findByTestId('run-pipeline-button');
  const findCiLintButton = () => findByTestId('ci-lint-button');
  const findCleanCacheButton = () => findByTestId('clear-cache-button');
  const findStagesDropdown = () => findByTestId('mini-pipeline-graph-dropdown-toggle');

  const findPipelinesTable = () => wrapper.find(PipelinesTableComponent);
  const findPipelineUrlLinks = () => wrapper.findAll('[data-testid="pipeline-url-link"]');
  const findEmptyState = () => wrapper.find(EmptyState);
  const findBlankState = () => wrapper.find(BlankState);

  const findTablePagination = () => wrapper.find(TablePagination);

  const createComponent = (props = defaultProps) => {
    wrapper = mount(PipelinesComponent, {
      propsData: {
        store: new Store(),
        projectId: '21',
        params: {},
        ...props,
      },
    });
  };

  beforeEach(() => {
    delete window.location;
  });

  beforeEach(() => {
    window.location = { search: '' };

    mock = new MockAdapter(axios);
    pipelinesResponse = getJSONFixture(jsonFixtureName);

    jest.spyOn(window.history, 'pushState').mockImplementation(() => {});
    jest.spyOn(Api, 'projectUsers').mockResolvedValue(users);
    jest.spyOn(Api, 'branches').mockResolvedValue({ data: branches });
  });

  afterEach(() => {
    window.history.pushState.mockReset();
    wrapper.destroy();
    mock.reset();
  });

  describe('With permission', () => {
    describe('With pipelines in main tab', () => {
      beforeEach(() => {
        mock.onGet('twitter/flight/pipelines.json').reply(200, pipelinesResponse);
        createComponent();
        return waitForPromises();
      });

      it('renders tabs', () => {
        expect(findTab('all').text()).toContain('All');
      });

      it('renders Run Pipeline link', () => {
        expect(findRunPipelineButton().attributes('href')).toBe(paths.newPipelinePath);
      });

      it('renders CI Lint link', () => {
        expect(findCiLintButton().attributes('href')).toBe(paths.ciLintPath);
      });

      it('renders Clear Runner Cache button', () => {
        expect(findCleanCacheButton().text()).toBe('Clear Runner Caches');
      });

      it('renders pipelines table', () => {
        expect(wrapper.findAll('.gl-responsive-table-row')).toHaveLength(
          pipelinesResponse.pipelines.length + 1,
        );
      });
    });

    describe('Without pipelines on main tab with CI', () => {
      beforeEach(() => {
        mock.onGet('twitter/flight/pipelines.json').reply(200, {
          pipelines: [],
          count: {
            all: 0,
            pending: 0,
            running: 0,
            finished: 0,
          },
        });

        createComponent();

        return waitForPromises();
      });

      it('renders tabs', () => {
        expect(findTab('all').text()).toContain('All');
      });

      it('renders Run Pipeline link', () => {
        expect(findRunPipelineButton().attributes('href')).toBe(paths.newPipelinePath);
      });

      it('renders CI Lint link', () => {
        expect(findCiLintButton().attributes('href')).toBe(paths.ciLintPath);
      });

      it('renders Clear Runner Cache button', () => {
        expect(findCleanCacheButton().text()).toBe('Clear Runner Caches');
      });

      it('renders tab empty state', () => {
        expect(findBlankState().text()).toBe('There are currently no pipelines.');
      });

      it('renders tab empty state finished scope', async () => {
        findNavigationTabs().vm.$emit('onChangeTab', 'finished');

        await waitForPromises();

        expect(findBlankState().text()).toBe('There are currently no finished pipelines.');
      });
    });

    describe('Without pipelines nor CI', () => {
      beforeEach(() => {
        mock.onGet('twitter/flight/pipelines.json').reply(200, {
          pipelines: [],
          count: {
            all: 0,
            pending: 0,
            running: 0,
            finished: 0,
          },
        });

        createComponent({ hasGitlabCi: false, canCreatePipeline: true, ...paths });

        return waitForPromises();
      });

      it('renders empty state', () => {
        expect(findEmptyState().find('h4').text()).toBe('Build with confidence');
        expect(findEmptyState().find(GlButton).attributes('href')).toBe(paths.helpPagePath);
      });

      it('does not render tabs nor buttons', () => {
        expect(findTab('all').exists()).toBe(false);
        expect(findRunPipelineButton().exists()).toBeFalsy();
        expect(findCiLintButton().exists()).toBeFalsy();
        expect(findCleanCacheButton().exists()).toBeFalsy();
      });
    });

    describe('When API returns error', () => {
      beforeEach(() => {
        mock.onGet('twitter/flight/pipelines.json').reply(500, {});
        createComponent({ hasGitlabCi: false, canCreatePipeline: true, ...paths });

        return waitForPromises();
      });

      it('renders tabs', () => {
        expect(findTab('all').text()).toContain('All');
      });

      it('renders buttons', () => {
        expect(findRunPipelineButton().attributes('href')).toBe(paths.newPipelinePath);

        expect(findCiLintButton().attributes('href')).toBe(paths.ciLintPath);
        expect(findCleanCacheButton().text()).toBe('Clear Runner Caches');
      });

      it('renders error state', () => {
        expect(findBlankState().text()).toContain('There was an error fetching the pipelines.');
      });
    });
  });

  describe('Without permission', () => {
    describe('With pipelines in main tab', () => {
      beforeEach(() => {
        mock.onGet('twitter/flight/pipelines.json').reply(200, pipelinesResponse);

        createComponent({ hasGitlabCi: false, canCreatePipeline: false, ...noPermissions });

        return waitForPromises();
      });

      it('renders tabs', () => {
        expect(findTab('all').text()).toContain('All');
      });

      it('does not render buttons', () => {
        expect(findRunPipelineButton().exists()).toBeFalsy();
        expect(findCiLintButton().exists()).toBeFalsy();
        expect(findCleanCacheButton().exists()).toBeFalsy();
      });

      it('renders pipelines table', () => {
        expect(wrapper.findAll('.gl-responsive-table-row')).toHaveLength(
          pipelinesResponse.pipelines.length + 1,
        );
      });
    });

    describe('Without pipelines on main tab with CI', () => {
      beforeEach(() => {
        mock.onGet('twitter/flight/pipelines.json').reply(200, {
          pipelines: [],
          count: {
            all: 0,
            pending: 0,
            running: 0,
            finished: 0,
          },
        });

        createComponent({ hasGitlabCi: true, canCreatePipeline: false, ...noPermissions });

        return waitForPromises();
      });

      it('renders tabs', () => {
        expect(findTab('all').text()).toContain('All');
      });

      it('does not render buttons', () => {
        expect(findRunPipelineButton().exists()).toBeFalsy();
        expect(findCiLintButton().exists()).toBeFalsy();
        expect(findCleanCacheButton().exists()).toBeFalsy();
      });

      it('renders tab empty state', () => {
        expect(wrapper.find('.empty-state h4').text()).toBe('There are currently no pipelines.');
      });
    });

    describe('Without pipelines nor CI', () => {
      beforeEach(() => {
        mock.onGet('twitter/flight/pipelines.json').reply(200, {
          pipelines: [],
          count: {
            all: 0,
            pending: 0,
            running: 0,
            finished: 0,
          },
        });

        createComponent({ hasGitlabCi: false, canCreatePipeline: false, ...noPermissions });

        return waitForPromises();
      });

      it('renders empty state without button to set CI', () => {
        expect(findEmptyState().text()).toBe(
          'This project is not currently set up to run pipelines.',
        );

        expect(findEmptyState().find(GlButton).exists()).toBeFalsy();
      });

      it('does not render tabs or buttons', () => {
        expect(findTab('all').exists()).toBe(false);
        expect(findRunPipelineButton().exists()).toBeFalsy();
        expect(findCiLintButton().exists()).toBeFalsy();
        expect(findCleanCacheButton().exists()).toBeFalsy();
      });
    });

    describe('When API returns error', () => {
      beforeEach(() => {
        mock.onGet('twitter/flight/pipelines.json').reply(500, {});

        createComponent({ hasGitlabCi: false, canCreatePipeline: true, ...noPermissions });

        return waitForPromises();
      });

      it('renders tabs', () => {
        expect(findTab('all').text()).toContain('All');
      });

      it('does not renders buttons', () => {
        expect(findRunPipelineButton().exists()).toBeFalsy();
        expect(findCiLintButton().exists()).toBeFalsy();
        expect(findCleanCacheButton().exists()).toBeFalsy();
      });

      it('renders error state', () => {
        expect(wrapper.find('.empty-state').text()).toContain(
          'There was an error fetching the pipelines.',
        );
      });
    });
  });

  describe('successful request', () => {
    describe('with pipelines', () => {
      beforeEach(() => {
        mock.onGet('twitter/flight/pipelines.json').reply(200, pipelinesResponse);

        createComponent();
        return waitForPromises();
      });

      it('should render table', () => {
        expect(wrapper.findAll('.gl-responsive-table-row')).toHaveLength(
          pipelinesResponse.pipelines.length + 1,
        );
      });

      it('should set up navigation tabs', () => {
        expect(findNavigationTabs().props('tabs')).toEqual([
          { name: 'All', scope: 'all', count: '3', isActive: true },
          { name: 'Finished', scope: 'finished', count: undefined, isActive: false },
          { name: 'Branches', scope: 'branches', isActive: false },
          { name: 'Tags', scope: 'tags', isActive: false },
        ]);
      });

      it('should render navigation tabs', () => {
        expect(findTab('all').html()).toContain('All');
        expect(findTab('finished').text()).toContain('Finished');
        expect(findTab('branches').text()).toContain('Branches');
        expect(findTab('tags').text()).toContain('Tags');
      });

      it('should make an API request when using tabs', () => {
        createComponent({ hasGitlabCi: true, canCreatePipeline: true, ...paths });
        jest.spyOn(wrapper.vm.service, 'getPipelines');

        return waitForPromises().then(() => {
          findTab('finished').trigger('click');

          expect(wrapper.vm.service.getPipelines).toHaveBeenCalledWith({
            scope: 'finished',
            page: '1',
          });
        });
      });
    });
  });

  describe('When there are multiple pages of pipelines available', () => {
    const mockPageSize = 2;
    const mockPageHeader = ({ page = 1 } = {}) => {
      return {
        'X-PER-PAGE': `${mockPageSize}`,
        'X-PREV-PAGE': `${page - 1}`,
        'X-PAGE': `${page}`,
        'X-NEXT-PAGE': `${page + 1}`,
      };
    };
    const goToTab = (tab) => {
      findNavigationTabs().vm.$emit('onChangeTab', tab);
    };
    const goToPage = (page) => {
      findTablePagination().find(GlPagination).vm.$emit('input', page);
    };

    beforeEach(async () => {
      const pages = chunk(pipelinesResponse.pipelines, mockPageSize);

      mock.onGet(paths.endpoint, { params: { scope: 'all', page: '1' } }).reply(
        200,
        {
          pipelines: pages[0],
          count: pipelinesResponse.count,
        },
        mockPageHeader({ page: 1 }),
      );
      mock.onGet(paths.endpoint, { params: { scope: 'all', page: '2' } }).reply(
        200,
        {
          pipelines: pages[1],
          count: pipelinesResponse.count,
        },
        mockPageHeader({ page: 2 }),
      );

      createComponent();

      await waitForPromises();
    });

    it('shows the first page of pipelines', () => {
      expect(findPipelineUrlLinks().length).toBe(2);
      expect(findPipelineUrlLinks().at(0).text()).toBe('#3');
      expect(findPipelineUrlLinks().at(1).text()).toBe('#2');

      expect(window.history.pushState).not.toHaveBeenCalled();
    });

    describe('when user goes to next page', () => {
      beforeEach(async () => {
        goToPage(2);
        await waitForPromises();
      });

      it('should update page and keep scope the same scope', async () => {
        expect(findPipelineUrlLinks().length).toBe(1);
        expect(findPipelineUrlLinks().at(0).text()).toBe('#1');
      });

      it('should update browser bar', () => {
        expect(window.history.pushState).toHaveBeenCalledWith(
          expect.anything(),
          expect.anything(),
          `${window.location.pathname}?page=2&scope=all`,
        );
      });
    });

    describe('when user changes tabs', () => {
      beforeEach(async () => {
        mock.onGet(paths.endpoint, { params: { scope: 'running', page: '1' } }).reply(
          200,
          {
            pipelines: [pipelinesResponse.pipelines[0]],
            count: pipelinesResponse.count,
          },
          mockPageHeader({ page: 1 }),
        );

        goToTab('running');

        await waitForPromises();
      });

      it('should filter pipelines', async () => {
        expect(findPipelineUrlLinks().length).toBe(1);
        expect(findPipelineUrlLinks().at(0).text()).toBe('#3');
      });

      it('should update browser bar', () => {
        expect(window.history.pushState).toHaveBeenCalledWith(
          expect.anything(),
          expect.anything(),
          `${window.location.pathname}?scope=running&page=1`,
        );
      });
    });
  });

  describe('User Interaction', () => {
    describe('updates results when a staged is clicked', () => {
      beforeEach(() => {
        const copyPipeline = { ...pipelineWithStages };
        copyPipeline.id += 1;

        mock.onGet(paths.endpoint, { scope: 'all', page: '1' }).reply(
          200,
          {
            pipelines: [pipelineWithStages],
            count: {
              all: 1,
              finished: 1,
              pending: 0,
              running: 0,
            },
          },
          {
            'POLL-INTERVAL': 100,
          },
        );
        mock.onGet(pipelineWithStages.details.stages[0].dropdown_path).reply(200, stageReply);

        createComponent();
      });

      describe('when a request is being made', () => {
        it('stops polling, cancels the request, & restarts polling', async () => {
          const stopMock = jest.spyOn(wrapper.vm.poll, 'stop');
          const restartMock = jest.spyOn(wrapper.vm.poll, 'restart');
          const cancelMock = jest.spyOn(wrapper.vm.service.cancelationSource, 'cancel');
          mock.onGet('twitter/flight/pipelines.json').reply(200, pipelinesResponse);

          await waitForPromises();

          wrapper.vm.isMakingRequest = true;

          findStagesDropdown().trigger('click');

          await waitForPromises();

          expect(cancelMock).toHaveBeenCalled();
          expect(stopMock).toHaveBeenCalled();
          expect(restartMock).toHaveBeenCalled();
        });
      });

      describe('when no request is being made', () => {
        it('stops polling & restarts polling', () => {
          const stopMock = jest.spyOn(wrapper.vm.poll, 'stop');
          const restartMock = jest.spyOn(wrapper.vm.poll, 'restart');
          mock.onGet('twitter/flight/pipelines.json').reply(200, pipelinesResponse);

          return waitForPromises()
            .then(() => {
              findStagesDropdown().trigger('click');
              expect(stopMock).toHaveBeenCalled();
            })
            .then(() => {
              expect(restartMock).toHaveBeenCalled();
            });
        });
      });
    });
  });

  describe('Rendered content', () => {
    beforeEach(() => {
      createComponent();
    });

    describe('displays different content', () => {
      it('shows loading state when the app is loading', () => {
        expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
      });

      it('shows error state when app has error', () => {
        wrapper.vm.hasError = true;
        wrapper.vm.isLoading = false;

        return nextTick().then(() => {
          expect(findBlankState().props('message')).toBe(
            'There was an error fetching the pipelines. Try again in a few moments or contact your support team.',
          );
        });
      });

      it('shows table list when app has pipelines', () => {
        wrapper.vm.isLoading = false;
        wrapper.vm.hasError = false;
        wrapper.vm.state.pipelines = pipelinesResponse.pipelines;

        return nextTick().then(() => {
          expect(wrapper.find(PipelinesTableComponent).exists()).toBe(true);
        });
      });

      it('shows empty tab when app does not have pipelines but project has pipelines', () => {
        wrapper.vm.state.count.all = 10;
        wrapper.vm.isLoading = false;

        return nextTick().then(() => {
          expect(findBlankState().exists()).toBe(true);
          expect(findBlankState().props('message')).toBe('There are currently no pipelines.');
        });
      });

      it('shows empty tab when project has CI', () => {
        wrapper.vm.isLoading = false;

        return nextTick().then(() => {
          expect(findBlankState().exists()).toBe(true);
          expect(findBlankState().props('message')).toBe('There are currently no pipelines.');
        });
      });

      it('shows empty state when project does not have pipelines nor CI', () => {
        createComponent({ hasGitlabCi: false, canCreatePipeline: true, ...paths });

        wrapper.vm.isLoading = false;

        return nextTick().then(() => {
          expect(wrapper.find(EmptyState).exists()).toBe(true);
        });
      });
    });

    describe('displays tabs', () => {
      it('returns true when state is loading & has already made the first request', () => {
        wrapper.vm.isLoading = true;
        wrapper.vm.hasMadeRequest = true;

        return nextTick().then(() => {
          expect(findNavigationTabs().exists()).toBe(true);
        });
      });

      it('returns true when state is tableList & has already made the first request', () => {
        wrapper.vm.isLoading = false;
        wrapper.vm.state.pipelines = pipelinesResponse.pipelines;
        wrapper.vm.hasMadeRequest = true;

        return nextTick().then(() => {
          expect(findNavigationTabs().exists()).toBe(true);
        });
      });

      it('returns true when state is error & has already made the first request', () => {
        wrapper.vm.isLoading = false;
        wrapper.vm.hasError = true;
        wrapper.vm.hasMadeRequest = true;

        return nextTick().then(() => {
          expect(findNavigationTabs().exists()).toBe(true);
        });
      });

      it('returns true when state is empty tab & has already made the first request', () => {
        wrapper.vm.isLoading = false;
        wrapper.vm.state.count.all = 10;
        wrapper.vm.hasMadeRequest = true;

        return nextTick().then(() => {
          expect(findNavigationTabs().exists()).toBe(true);
        });
      });

      it('returns false when has not made first request', () => {
        wrapper.vm.hasMadeRequest = false;

        return nextTick().then(() => {
          expect(findNavigationTabs().exists()).toBe(false);
        });
      });

      it('returns false when state is empty state', () => {
        createComponent({ hasGitlabCi: false, canCreatePipeline: true, ...paths });

        wrapper.vm.isLoading = false;
        wrapper.vm.hasMadeRequest = true;

        return nextTick().then(() => {
          expect(findNavigationTabs().exists()).toBe(false);
        });
      });
    });

    describe('displays buttons', () => {
      it('returns true when it has paths & has made the first request', () => {
        wrapper.vm.hasMadeRequest = true;

        return nextTick().then(() => {
          expect(findNavigationControls().exists()).toBe(true);
        });
      });

      it('returns false when it has not made the first request', () => {
        wrapper.vm.hasMadeRequest = false;

        return nextTick().then(() => {
          expect(findNavigationControls().exists()).toBe(false);
        });
      });
    });
  });

  describe('Pipeline filters', () => {
    let updateContentMock;

    beforeEach(() => {
      mock.onGet(paths.endpoint).reply(200, pipelinesResponse);
      createComponent();

      updateContentMock = jest.spyOn(wrapper.vm, 'updateContent');

      return waitForPromises();
    });

    it('updates request data and query params on filter submit', async () => {
      const expectedQueryParams = {
        page: '1',
        scope: 'all',
        username: 'root',
        ref: 'master',
        status: 'pending',
      };

      findFilteredSearch().vm.$emit('submit', mockSearch);
      await nextTick();

      expect(wrapper.vm.requestData).toEqual(expectedQueryParams);
      expect(updateContentMock).toHaveBeenCalledWith(expectedQueryParams);
    });

    it('does not add query params if raw text search is used', async () => {
      const expectedQueryParams = { page: '1', scope: 'all' };

      findFilteredSearch().vm.$emit('submit', ['rawText']);
      await nextTick();

      expect(wrapper.vm.requestData).toEqual(expectedQueryParams);
      expect(updateContentMock).toHaveBeenCalledWith(expectedQueryParams);
    });

    it('displays a warning message if raw text search is used', () => {
      findFilteredSearch().vm.$emit('submit', ['rawText']);

      expect(createFlash).toHaveBeenCalledTimes(1);
      expect(createFlash).toHaveBeenCalledWith(RAW_TEXT_WARNING, 'warning');
    });
  });
});
