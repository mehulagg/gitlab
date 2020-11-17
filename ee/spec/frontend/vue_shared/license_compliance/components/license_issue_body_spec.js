import Vue from 'vue';

import LicenseIssueBody from 'ee/vue_shared/license_compliance/components/license_issue_body.vue';
import { trimText } from 'helpers/text_helper';
import { mountComponentWithStore } from 'helpers/vue_mount_component_helper';
import createStore from 'ee/vue_shared/license_compliance/store';
import { licenseReport } from '../mock_data';

describe('LicenseIssueBody', () => {
  const issue = licenseReport[0];
  const Component = Vue.extend(LicenseIssueBody);
  let vm;
  let store;

  beforeEach(() => {
    store = createStore();
    vm = mountComponentWithStore(Component, { props: { issue }, store });
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('template', () => {
    it('renders component container element with class `license-item`', () => {
      expect(vm.$el.classList.contains('license-item')).toBe(true);
    });

    it('renders link to view license', () => {
      const linkEl = vm.$el.querySelector('.license-item > a');

      expect(linkEl).not.toBeNull();
      expect(linkEl.innerText.trim()).toBe(issue.name);
    });

    it('renders packages list', () => {
      const packagesEl = vm.$el.querySelector('.license-packages');

      expect(packagesEl).not.toBeNull();
      expect(trimText(packagesEl.innerText)).toBe('Used by pg, puma, foo, and 2 more');
    });
  });
});
