import Vue from 'vue';

import LicenseIssueBody from 'ee/vue_shared/license_compliance/components/license_issue_body.vue';
import createStore from 'ee/vue_shared/license_compliance/store';
import { trimText } from 'helpers/text_helper';
import { mountComponentWithStore } from 'helpers/vue_mount_component_helper';
import { licenseReport } from '../mock_data';

describe('LicenseIssueBody', () => {
  const issue = licenseReport[0];
  const Component = Vue.extend(LicenseIssueBody);
  let vm;
  let store;

  beforeEach(() => {
    store = createStore();
  });

  afterEach(() => {
    vm.$destroy();
  });

  describe('template', () => {
    beforeEach(() => {
      vm = mountComponentWithStore(Component, { props: { issue }, store });
    });

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

  describe('template without packages', () => {
    beforeEach(() => {
      const issueWithoutPackages = licenseReport[0];
      issueWithoutPackages.packages = [];

      vm = mountComponentWithStore(Component, { props: { issue: issueWithoutPackages }, store });
    });

    it('does not render packages list', () => {
      const packagesEl = vm.$el.querySelector('.license-packages');

      expect(packagesEl).toBeNull();
      vm.$destroy();
    });
  });
});
