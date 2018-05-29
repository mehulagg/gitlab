import Vue from 'vue';
import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import component from 'ee/vue_shared/security_reports/grouped_security_reports_app.vue';
import state from 'ee/vue_shared/security_reports/store/state';
import mountComponent from '../../helpers/vue_mount_component_helper';
import {
  sastIssues,
  sastIssuesBase,
  dockerReport,
  dockerBaseReport,
  dast,
  dastBase,
  sastHeadAllIssues,
  sastBaseAllIssues,
} from './mock_data';

describe('Grouped security reports app', () => {
  let vm;
  let mock;
  const Component = Vue.extend(component);

  function removeBreakLine(data) {
    return data
      .replace(/\r?\n|\r/g, '')
      .replace(/\s\s+/g, ' ')
      .trim();
  }

  beforeEach(() => {
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    vm.$store.replaceState(state());
    vm.$destroy();
    mock.restore();
  });

  describe('with error', () => {
    beforeEach(() => {
      mock.onGet('sast_head.json').reply(500);
      mock.onGet('sast_base.json').reply(500);
      mock.onGet('dast_head.json').reply(500);
      mock.onGet('dast_base.json').reply(500);
      mock.onGet('sast_container_head.json').reply(500);
      mock.onGet('sast_container_base.json').reply(500);
      mock.onGet('dss_head.json').reply(500);
      mock.onGet('dss_base.json').reply(500);
      mock.onGet('vulnerability_feedback_path.json').reply(500, []);

      vm = mountComponent(Component, {
        headBlobPath: 'path',
        baseBlobPath: 'path',
        sastHeadPath: 'sast_head.json',
        sastBasePath: 'sast_base.json',
        dastHeadPath: 'dast_head.json',
        dastBasePath: 'dast_base.json',
        sastContainerHeadPath: 'sast_container_head.json',
        sastContainerBasePath: 'sast_container_base.json',
        dependencyScanningHeadPath: 'dss_head.json',
        dependencyScanningBasePath: 'dss_base.json',
        sastHelpPath: 'path',
        sastContainerHelpPath: 'path',
        dastHelpPath: 'path',
        dependencyScanningHelpPath: 'path',
        vulnerabilityFeedbackPath: 'vulnerability_feedback_path.json',
        vulnerabilityFeedbackHelpPath: 'path',
        pipelineId: 123,
      });
    });

    it('renders loading state', done => {
      setTimeout(() => {
        expect(vm.$el.querySelector('.fa-spinner')).toBeNull();
        expect(vm.$el.querySelector('.js-code-text').textContent.trim()).toEqual(
          'Security scanning failed loading any results',
        );
        expect(vm.$el.querySelector('.js-collapse-btn').textContent.trim()).toEqual('Expand');

        expect(removeBreakLine(vm.$el.textContent)).toContain(
          'SAST resulted in error while loading results',
        );
        expect(removeBreakLine(vm.$el.textContent)).toContain(
          'Dependency scanning resulted in error while loading results',
        );
        expect(vm.$el.textContent).toContain(
          'Container scanning resulted in error while loading results',
        );
        expect(vm.$el.textContent).toContain('DAST resulted in error while loading results');
        done();
      }, 0);
    });
  });

  describe('while loading', () => {
    beforeEach(() => {
      mock.onGet('sast_head.json').reply(200, sastIssues);
      mock.onGet('sast_base.json').reply(200, sastIssuesBase);
      mock.onGet('dast_head.json').reply(200, dast);
      mock.onGet('dast_base.json').reply(200, dastBase);
      mock.onGet('sast_container_head.json').reply(200, dockerReport);
      mock.onGet('sast_container_base.json').reply(200, dockerBaseReport);
      mock.onGet('dss_head.json').reply(200, sastIssues);
      mock.onGet('dss_base.json').reply(200, sastIssuesBase);
      mock.onGet('vulnerability_feedback_path.json').reply(200, []);

      vm = mountComponent(Component, {
        headBlobPath: 'path',
        baseBlobPath: 'path',
        sastHeadPath: 'sast_head.json',
        sastBasePath: 'sast_base.json',
        dastHeadPath: 'dast_head.json',
        dastBasePath: 'dast_base.json',
        sastContainerHeadPath: 'sast_container_head.json',
        sastContainerBasePath: 'sast_container_base.json',
        dependencyScanningHeadPath: 'dss_head.json',
        dependencyScanningBasePath: 'dss_base.json',
        sastHelpPath: 'path',
        sastContainerHelpPath: 'path',
        dastHelpPath: 'path',
        dependencyScanningHelpPath: 'path',
        vulnerabilityFeedbackPath: 'vulnerability_feedback_path.json',
        vulnerabilityFeedbackHelpPath: 'path',
        pipelineId: 123,
      });
    });

    it('renders loading summary text + spinner', (done) => {
      expect(vm.$el.querySelector('.fa-spinner')).not.toBeNull();
      expect(vm.$el.querySelector('.js-code-text').textContent.trim()).toEqual(
        'Security scanning is loading',
      );
      expect(vm.$el.querySelector('.js-collapse-btn').textContent.trim()).toEqual('Expand');

      expect(vm.$el.textContent).toContain('SAST is loading');
      expect(vm.$el.textContent).toContain('Dependency scanning is loading');
      expect(vm.$el.textContent).toContain('Container scanning is loading');
      expect(vm.$el.textContent).toContain('DAST is loading');

      setTimeout(() => {
        done();
      }, 0);
    });
  });

  describe('with all reports', () => {
    beforeEach(() => {
      mock.onGet('sast_head.json').reply(200, sastIssues);
      mock.onGet('sast_base.json').reply(200, sastIssuesBase);
      mock.onGet('dast_head.json').reply(200, dast);
      mock.onGet('dast_base.json').reply(200, dastBase);
      mock.onGet('sast_container_head.json').reply(200, dockerReport);
      mock.onGet('sast_container_base.json').reply(200, dockerBaseReport);
      mock.onGet('dss_head.json').reply(200, sastIssues);
      mock.onGet('dss_base.json').reply(200, sastIssuesBase);
      mock.onGet('vulnerability_feedback_path.json').reply(200, []);

      vm = mountComponent(Component, {
        headBlobPath: 'path',
        baseBlobPath: 'path',
        sastHeadPath: 'sast_head.json',
        sastBasePath: 'sast_base.json',
        dastHeadPath: 'dast_head.json',
        dastBasePath: 'dast_base.json',
        sastContainerHeadPath: 'sast_container_head.json',
        sastContainerBasePath: 'sast_container_base.json',
        dependencyScanningHeadPath: 'dss_head.json',
        dependencyScanningBasePath: 'dss_base.json',
        sastHelpPath: 'path',
        sastContainerHelpPath: 'path',
        dastHelpPath: 'path',
        dependencyScanningHelpPath: 'path',
        vulnerabilityFeedbackPath: 'vulnerability_feedback_path.json',
        vulnerabilityFeedbackHelpPath: 'path',
        pipelineId: 123,
      });
    });

    it('renders reports', done => {
      setTimeout(() => {
        // It's not loading
        expect(vm.$el.querySelector('.fa-spinner')).toBeNull();

        // Renders the summary text
        expect(vm.$el.querySelector('.js-code-text').textContent.trim()).toEqual(
          'Security scanning detected 6 new vulnerabilities and 2 fixed vulnerabilities',
        );

        // Renders the expand button
        expect(vm.$el.querySelector('.js-collapse-btn').textContent.trim()).toEqual('Expand');

        // Renders Sast result
        expect(removeBreakLine(vm.$el.textContent)).toContain(
          'SAST detected 2 new vulnerabilities and 1 fixed vulnerability',
        );

        // Renders DSS result
        expect(removeBreakLine(vm.$el.textContent)).toContain(
          'Dependency scanning detected 2 new vulnerabilities and 1 fixed vulnerability',
        );
        // Renders container scanning result
        expect(vm.$el.textContent).toContain('Container scanning detected 1 new vulnerability');

        // Renders DAST result
        expect(vm.$el.textContent).toContain('DAST detected 1 new vulnerability');
        done();
      }, 0);
    });

    it('opens modal with more information', (done) => {
      setTimeout(() => {
        vm.$el.querySelector('.break-link').click();

        Vue.nextTick(() => {
          expect(vm.$el.querySelector('.modal-title').textContent.trim()).toEqual(sastIssues[0].message);
          expect(vm.$el.querySelector('.modal-body').textContent).toContain(sastIssues[0].solution);

          done();
        });
      }, 0);
    });
  });

  describe('with all issues for sast and dependency scanning', () => {
    beforeEach(() => {
      mock.onGet('sast_head.json').reply(200, sastHeadAllIssues);
      mock.onGet('sast_base.json').reply(200, sastBaseAllIssues);
      mock.onGet('dast_head.json').reply(200, dast);
      mock.onGet('dast_base.json').reply(200, dastBase);
      mock.onGet('sast_container_head.json').reply(200, dockerReport);
      mock.onGet('sast_container_base.json').reply(200, dockerBaseReport);
      mock.onGet('dss_head.json').reply(200, sastHeadAllIssues);
      mock.onGet('dss_base.json').reply(200, sastBaseAllIssues);
      mock.onGet('vulnerability_feedback_path.json').reply(200, []);

      vm = mountComponent(Component, {
        headBlobPath: 'path',
        baseBlobPath: 'path',
        sastHeadPath: 'sast_head.json',
        sastBasePath: 'sast_base.json',
        dastHeadPath: 'dast_head.json',
        dastBasePath: 'dast_base.json',
        sastContainerHeadPath: 'sast_container_head.json',
        sastContainerBasePath: 'sast_container_base.json',
        dependencyScanningHeadPath: 'dss_head.json',
        dependencyScanningBasePath: 'dss_base.json',
        sastHelpPath: 'path',
        sastContainerHelpPath: 'path',
        dastHelpPath: 'path',
        dependencyScanningHelpPath: 'path',
        vulnerabilityFeedbackPath: 'vulnerability_feedback_path.json',
        vulnerabilityFeedbackHelpPath: 'path',
        pipelineId: 123,
      });
    });

    it('render show all issues button for sast', done => {
      setTimeout(() => {
        expect(vm.$el.querySelector('.js-sast-issue-list .js-expand-full-list')).not.toBeNull();
        vm.$el.querySelector('.js-sast-issue-list .js-expand-full-list').click();

        vm
          .$nextTick()
          .then(() => {
            expect(vm.$el.querySelector('.js-sast-issue-list').textContent).toContain(
              sastHeadAllIssues[0].message,
            );
          })
          .then(done)
          .catch(done.fail);
      }, 0);
    });

    it('render show all issues button for dependency scanning', done => {
      setTimeout(() => {
        expect(vm.$el.querySelector('.js-dss-issue-list .js-expand-full-list')).not.toBeNull();
        vm.$el.querySelector('.js-dss-issue-list .js-expand-full-list').click();

        vm
          .$nextTick()
          .then(() => {
            expect(vm.$el.querySelector('.js-dss-issue-list').textContent).toContain(
              sastHeadAllIssues[0].message,
            );
          })
          .then(done)
          .catch(done.fail);
      }, 0);
    });
  });
});
