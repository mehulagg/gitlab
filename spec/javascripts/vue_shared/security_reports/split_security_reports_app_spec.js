import Vue from 'vue';
import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import component from 'ee/vue_shared/security_reports/split_security_reports_app.vue';
import createStore from 'ee/vue_shared/security_reports/store';
import state from 'ee/vue_shared/security_reports/store/state';
import { mountComponentWithStore } from '../../helpers/vue_mount_component_helper';
import { sastIssues } from './mock_data';

describe('Slipt security reports app', () => {
  const Component = Vue.extend(component);

  let vm;
  let mock;

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

  describe('while loading', () => {
    beforeEach(() => {
      mock.onGet('sast_head.json').reply(200, sastIssues);
      mock.onGet('dss_head.json').reply(200, sastIssues);
      mock.onGet('vulnerability_feedback_path.json').reply(200, []);

      vm = mountComponentWithStore(Component, {
        store: createStore(),
        props: {
          headBlobPath: 'path',
          baseBlobPath: 'path',
          sastHeadPath: 'sast_head.json',
          dependencyScanningHeadPath: 'dss_head.json',
          sastHelpPath: 'path',
          dependencyScanningHelpPath: 'path',
          vulnerabilityFeedbackPath: 'vulnerability_feedback_path.json',
          vulnerabilityFeedbackHelpPath: 'path',
          pipelineId: 123,
        },
      });
    });

    it('renders loading summary text + spinner', done => {
      expect(vm.$el.querySelector('.fa-spinner')).not.toBeNull();

      expect(vm.$el.textContent).toContain('SAST is loading');
      expect(vm.$el.textContent).toContain('Dependency scanning is loading');

      setTimeout(() => {
        done();
      }, 0);
    });
  });

  describe('with all reports', () => {
    beforeEach(() => {
      mock.onGet('sast_head.json').reply(200, sastIssues);
      mock.onGet('dss_head.json').reply(200, sastIssues);
      mock.onGet('vulnerability_feedback_path.json').reply(200, []);

      vm = mountComponentWithStore(Component, {
        store: createStore(),
        props: {
          headBlobPath: 'path',
          baseBlobPath: 'path',
          sastHeadPath: 'sast_head.json',
          dependencyScanningHeadPath: 'dss_head.json',
          sastHelpPath: 'path',
          dependencyScanningHelpPath: 'path',
          vulnerabilityFeedbackPath: 'vulnerability_feedback_path.json',
          vulnerabilityFeedbackHelpPath: 'path',
          pipelineId: 123,
        },
      });
    });

    it('renders reports', done => {
      setTimeout(() => {
        expect(vm.$el.querySelector('.fa-spinner')).toBeNull();
        expect(vm.$el.querySelector('.js-collapse-btn').textContent.trim()).toEqual('Expand');

        expect(removeBreakLine(vm.$el.textContent)).toContain('SAST detected 3 vulnerabilities');
        expect(removeBreakLine(vm.$el.textContent)).toContain(
          'Dependency scanning detected 3 vulnerabilities',
        );
        done();
      }, 0);
    });
  });

  describe('with error', () => {
    beforeEach(() => {
      mock.onGet('sast_head.json').reply(500);
      mock.onGet('dss_head.json').reply(500);
      mock.onGet('vulnerability_feedback_path.json').reply(500, []);

      vm = mountComponentWithStore(Component, {
        store: createStore(),
        props: {
          headBlobPath: 'path',
          baseBlobPath: 'path',
          sastHeadPath: 'sast_head.json',
          dependencyScanningHeadPath: 'dss_head.json',
          sastHelpPath: 'path',
          dependencyScanningHelpPath: 'path',
          vulnerabilityFeedbackPath: 'vulnerability_feedback_path.json',
          vulnerabilityFeedbackHelpPath: 'path',
          pipelineId: 123,
        },
      });
    });

    it('renders error state', done => {
      setTimeout(() => {
        expect(vm.$el.querySelector('.fa-spinner')).toBeNull();

        expect(removeBreakLine(vm.$el.textContent)).toContain('SAST resulted in error while loading results');
        expect(removeBreakLine(vm.$el.textContent)).toContain(
          'Dependency scanning resulted in error while loading results',
        );
        done();
      }, 0);
    });
  });
});
