import MockAdapter from 'axios-mock-adapter';
import Vue from 'vue';

import EpicApp from 'ee/epic/components/epic_app.vue';
import createStore from 'ee/epic/store';

import { useMockIntersectionObserver } from 'helpers/mock_dom_observer';
import { mountComponentWithStore } from 'helpers/vue_mount_component_helper';
import { initialRequest } from 'jest/issue_show/mock_data';
import { TEST_HOST } from 'spec/test_constants';
import axios from '~/lib/utils/axios_utils';
import { mockEpicMeta, mockEpicData } from '../mock_data';

describe('EpicAppComponent', () => {
  useMockIntersectionObserver();

  let vm;
  let mock;

  beforeEach(() => {
    mock = new MockAdapter(axios);
    mock.onGet(`${TEST_HOST}/realtime_changes`).reply(200, initialRequest);

    const Component = Vue.extend(EpicApp);
    const store = createStore();
    store.dispatch('setEpicMeta', mockEpicMeta);
    store.dispatch('setEpicData', mockEpicData);

    vm = mountComponentWithStore(Component, {
      store,
    });

    jest.advanceTimersByTime(2);
  });

  afterEach(() => {
    mock.restore();
    vm.$destroy();
  });

  describe('template', () => {
    it('renders component container element with class `epic-page-container`', () => {
      expect(vm.$el.classList.contains('epic-page-container')).toBe(true);
    });
  });
});
