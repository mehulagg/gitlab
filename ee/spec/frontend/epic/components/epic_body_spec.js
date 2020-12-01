import MockAdapter from 'axios-mock-adapter';
import Vue from 'vue';

import EpicBody from 'ee/epic/components/epic_body.vue';
import createStore from 'ee/epic/store';

import { useMockIntersectionObserver } from 'helpers/mock_dom_observer';
import { mountComponentWithStore } from 'helpers/vue_mount_component_helper';
import { initialRequest } from 'jest/issue_show/mock_data';
import { TEST_HOST } from 'spec/test_constants';
import axios from '~/lib/utils/axios_utils';
import { mockEpicMeta, mockEpicData } from '../mock_data';

describe('EpicBodyComponent', () => {
  useMockIntersectionObserver();

  let vm;
  let mock;

  beforeEach(() => {
    mock = new MockAdapter(axios);
    mock.onGet(`${TEST_HOST}/realtime_changes`).reply(200, initialRequest);

    const Component = Vue.extend(EpicBody);
    const store = createStore();
    store.dispatch('setEpicMeta', mockEpicMeta);
    store.dispatch('setEpicData', mockEpicData);

    vm = mountComponentWithStore(Component, {
      store,
    });

    jest.advanceTimersByTime(5);
  });

  afterEach(() => {
    mock.restore();
    vm.$destroy();
  });

  describe('template', () => {
    it('renders epic body container element with class `detail-page-description` & `issuable-details` & `content-block`', () => {
      const el = vm.$el.querySelector('.detail-page-description');
      expect(el).not.toBeNull();
      expect(el.classList.contains('issuable-details')).toBe(true);
      expect(el.classList.contains('content-block')).toBe(true);
    });

    it('renders epic body elements', () => {
      expect(vm.$el.querySelector('.title-container')).not.toBeNull();
      expect(vm.$el.querySelector('.description')).not.toBeNull();
    });
  });
});
