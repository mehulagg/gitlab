import Vue from 'vue';
import reportSection from 'ee/vue_shared/security_reports/components/report_section.vue';
import mountComponent from 'spec/helpers/vue_mount_component_helper';
import { codequalityParsedIssues } from 'spec/vue_mr_widget/mock_data';

describe('Report section', () => {
  let vm;
  const ReportSection = Vue.extend(reportSection);

  afterEach(() => {
    vm.$destroy();
  });

  describe('computed', () => {
    beforeEach(() => {
      vm = mountComponent(ReportSection, {
        type: 'codequality',
        status: 'SUCCESS',
        loadingText: 'Loading codeclimate report',
        errorText: 'foo',
        successText: 'Code quality improved on 1 point and degraded on 1 point',
        resolvedIssues: codequalityParsedIssues,
        hasIssues: false,
        alwaysOpen: false,
      });
    });

    describe('isCollapsible', () => {
      const testMatrix = [
        { hasIssues: false, alwaysOpen: false, isCollapsible: false },
        { hasIssues: false, alwaysOpen: true, isCollapsible: false },
        { hasIssues: true, alwaysOpen: false, isCollapsible: true },
        { hasIssues: true, alwaysOpen: true, isCollapsible: false },
      ];

      testMatrix.forEach(({ hasIssues, alwaysOpen, isCollapsible }) => {
        const issues = hasIssues ? 'has issues' : 'has no issues';
        const open = alwaysOpen ? 'is always open' : 'is not always open';

        it(`is ${isCollapsible}, if the report ${issues} and ${open}`, done => {
          vm.hasIssues = hasIssues;
          vm.alwaysOpen = alwaysOpen;

          Vue.nextTick()
            .then(() => {
              expect(vm.isCollapsible).toBe(isCollapsible);
            })
            .then(done)
            .catch(done.fail);
        });
      });
    });

    describe('isExpanded', () => {
      const testMatrix = [
        { isCollapsed: false, alwaysOpen: false, isExpanded: true },
        { isCollapsed: false, alwaysOpen: true, isExpanded: true },
        { isCollapsed: true, alwaysOpen: false, isExpanded: false },
        { isCollapsed: true, alwaysOpen: true, isExpanded: true },
      ];

      testMatrix.forEach(({ isCollapsed, alwaysOpen, isExpanded }) => {
        const issues = isCollapsed ? 'is collapsed' : 'is not collapsed';
        const open = alwaysOpen ? 'is always open' : 'is not always open';

        it(`is ${isExpanded}, if the report ${issues} and ${open}`, done => {
          vm.isCollapsed = isCollapsed;
          vm.alwaysOpen = alwaysOpen;

          Vue.nextTick()
            .then(() => {
              expect(vm.isExpanded).toBe(isExpanded);
            })
            .then(done)
            .catch(done.fail);
        });
      });
    });
  });
  describe('when it is loading', () => {
    it('should render loading indicator', () => {
      vm = mountComponent(ReportSection, {
        type: 'codequality',
        status: 'LOADING',
        loadingText: 'Loading codeclimate report',
        errorText: 'foo',
        successText: 'Code quality improved on 1 point and degraded on 1 point',
        hasIssues: false,
      });
      expect(vm.$el.textContent.trim()).toEqual('Loading codeclimate report');
    });
  });

  describe('with success status', () => {
    beforeEach(() => {
      vm = mountComponent(ReportSection, {
        type: 'codequality',
        status: 'SUCCESS',
        loadingText: 'Loading codeclimate report',
        errorText: 'foo',
        successText: 'Code quality improved on 1 point and degraded on 1 point',
        resolvedIssues: codequalityParsedIssues,
        hasIssues: true,
      });
    });

    it('should render provided data', () => {
      expect(vm.$el.querySelector('.js-code-text').textContent.trim()).toEqual(
        'Code quality improved on 1 point and degraded on 1 point',
      );

      expect(vm.$el.querySelectorAll('.js-mr-code-resolved-issues li').length).toEqual(
        codequalityParsedIssues.length,
      );
    });

    describe('toggleCollapsed', () => {
      const hiddenCss = { display: 'none' };

      it('toggles issues', done => {
        vm.$el.querySelector('button').click();

        Vue.nextTick()
          .then(() => {
            expect(vm.$el.querySelector('.js-report-section-container')).not.toHaveCss(hiddenCss);
            expect(vm.$el.querySelector('button').textContent.trim()).toEqual('Collapse');

            vm.$el.querySelector('button').click();
          })
          .then(Vue.nextTick)
          .then(() => {
            expect(vm.$el.querySelector('.js-report-section-container')).toHaveCss(hiddenCss);
            expect(vm.$el.querySelector('button').textContent.trim()).toEqual('Expand');
          })
          .then(done)
          .catch(done.fail);
      });

      it('is always expanded, if always-open is set to true', done => {
        vm.alwaysOpen = true;
        Vue.nextTick()
          .then(() => {
            expect(vm.$el.querySelector('.js-report-section-container')).not.toHaveCss(hiddenCss);
            expect(vm.$el.querySelector('button')).toBeNull();
          })
          .then(done)
          .catch(done.fail);
      });
    });
  });

  describe('with failed request', () => {
    it('should render error indicator', () => {
      vm = mountComponent(ReportSection, {
        type: 'codequality',
        status: 'ERROR',
        loadingText: 'Loading codeclimate report',
        errorText: 'Failed to load codeclimate report',
        successText: 'Code quality improved on 1 point and degraded on 1 point',
        hasIssues: false,
      });
      expect(vm.$el.textContent.trim()).toEqual('Failed to load codeclimate report');
    });
  });

  describe('With full report', () => {
    beforeEach(() => {
      vm = mountComponent(ReportSection, {
        status: 'SUCCESS',
        successText:
          'SAST improved on 1 security vulnerability and degraded on 1 security vulnerability',
        type: 'SAST',
        errorText: 'Failed to load security report',
        hasIssues: true,
        loadingText: 'Loading security report',
        resolvedIssues: [
          {
            cve: 'CVE-2016-9999',
            file: 'Gemfile.lock',
            message: 'Test Information Leak Vulnerability in Action View',
            title: 'Test Information Leak Vulnerability in Action View',
            path: 'Gemfile.lock',
            solution:
              'upgrade to >= 5.0.0.beta1.1, >= 4.2.5.1, ~> 4.2.5, >= 4.1.14.1, ~> 4.1.14, ~> 3.2.22.1',
            tool: 'bundler_audit',
            url: 'https://groups.google.com/forum/#!topic/rubyonrails-security/335P1DcLG00',
            urlPath: '/Gemfile.lock',
          },
        ],
        unresolvedIssues: [
          {
            cve: 'CVE-2014-7829',
            file: 'Gemfile.lock',
            message: 'Arbitrary file existence disclosure in Action Pack',
            title: 'Arbitrary file existence disclosure in Action Pack',
            path: 'Gemfile.lock',
            solution: 'upgrade to ~> 3.2.21, ~> 4.0.11.1, ~> 4.0.12, ~> 4.1.7.1, >= 4.1.8',
            tool: 'bundler_audit',
            url: 'https://groups.google.com/forum/#!topic/rubyonrails-security/rMTQy4oRCGk',
            urlPath: '/Gemfile.lock',
          },
        ],
        allIssues: [
          {
            cve: 'CVE-2016-0752',
            file: 'Gemfile.lock',
            message: 'Possible Information Leak Vulnerability in Action View',
            title: 'Possible Information Leak Vulnerability in Action View',
            path: 'Gemfile.lock',
            solution:
              'upgrade to >= 5.0.0.beta1.1, >= 4.2.5.1, ~> 4.2.5, >= 4.1.14.1, ~> 4.1.14, ~> 3.2.22.1',
            tool: 'bundler_audit',
            url: 'https://groups.google.com/forum/#!topic/rubyonrails-security/335P1DcLG00',
            urlPath: '/Gemfile.lock',
          },
        ],
      });
    });

    it('should render full report section', done => {
      vm.$el.querySelector('button').click();

      Vue.nextTick(() => {
        expect(vm.$el.querySelector('.js-expand-full-list').textContent.trim()).toEqual(
          'Show complete code vulnerabilities report',
        );

        done();
      });
    });

    it('should expand full list when clicked and hide the show all button', done => {
      vm.$el.querySelector('button').click();

      Vue.nextTick(() => {
        vm.$el.querySelector('.js-expand-full-list').click();

        Vue.nextTick(() => {
          expect(vm.$el.querySelector('.js-mr-code-all-issues').textContent.trim()).toContain(
            'Possible Information Leak Vulnerability in Action View',
          );

          done();
        });
      });
    });
  });
});
