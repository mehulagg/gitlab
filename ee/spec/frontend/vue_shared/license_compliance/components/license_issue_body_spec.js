import Vue from 'vue';

import LicenseIssueBody from 'ee/vue_shared/license_compliance/components/license_issue_body.vue';
import createStore from 'ee/vue_shared/license_compliance/store';
import { trimText } from 'helpers/text_helper';
import { mountComponentWithStore } from 'helpers/vue_mount_component_helper';
import { licenseReport } from '../mock_data';

describe('LicenseIssueBody', () => {
  const Component = Vue.extend(LicenseIssueBody);
  let vm;
  let store;

  afterEach(() => {
    vm.$destroy();
  });

  describe('template', () => {
    const issue = licenseReport[0];
    beforeEach(() => {
      store = createStore();
      vm = mountComponentWithStore(Component, { props: { issue }, store });
    });

    it('renders component container element with class `license-item`', () => {
      expect(vm.$el.classList.contains('license-item')).toBe(true);
    });

    it('renders packages list', () => {
      const packagesEl = vm.$el.querySelector('.license-packages');

      expect(packagesEl).not.toBeNull();
      expect(trimText(packagesEl.innerText)).toBe('Used by pg, puma, foo, and 2 more');
    });
  });

  describe('when issue url is defined', () => {
    const issue = licenseReport[0];
    beforeEach(() => {
      store = createStore();
      vm = mountComponentWithStore(Component, { props: { issue }, store });
    });

    it('renders link to view license', () => {
      const linkEl = vm.$el.querySelector('.license-item > a');
      const textEl = vm.$el.querySelector('.license-item > span');

      expect(linkEl).not.toBeNull();
      expect(linkEl.innerText.trim()).toBe(issue.name);
      expect(linkEl.href).toBe(issue.url);
      expect(textEl).toBe(null);
    });
  });

  describe('when issue url is undefined', () => {
    const issue = licenseReport[1];
    beforeEach(() => {
      store = createStore();
      vm = mountComponentWithStore(Component, { props: { issue }, store });
    });

    it('renders text to view license', () => {
      const linkEl = vm.$el.querySelector('.license-item > a');
      const textEl = vm.$el.querySelector('.license-item > span');

      expect(textEl).not.toBeNull();
      expect(textEl.innerText.trim()).toBe(issue.name);
      expect(linkEl).toBe(null);
    });
  });
});
