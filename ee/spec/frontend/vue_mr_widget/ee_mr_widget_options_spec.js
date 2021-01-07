import MockAdapter from 'axios-mock-adapter';
import Vue from 'vue';
import mrWidgetOptions from 'ee/vue_merge_request_widget/mr_widget_options.vue';
import {
  sastDiffSuccessMock,
  dastDiffSuccessMock,
  containerScanningDiffSuccessMock,
  dependencyScanningDiffSuccessMock,
  secretScanningDiffSuccessMock,
  coverageFuzzingDiffSuccessMock,
  apiFuzzingDiffSuccessMock,
} from 'ee_jest/vue_shared/security_reports/mock_data';
import { TEST_HOST } from 'helpers/test_constants';
import { trimText } from 'helpers/text_helper';
import mountComponent from 'helpers/vue_mount_component_helper';
import waitForPromises from 'helpers/wait_for_promises';

import axios from '~/lib/utils/axios_utils';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import { SUCCESS } from '~/vue_merge_request_widget/components/deployment/constants';
import mockData, {
  baseBrowserPerformance,
  headBrowserPerformance,
  baseLoadPerformance,
  headLoadPerformance,
  pipelineJobs,
} from './mock_data';

// Force Jest to transpile and cache
// eslint-disable-next-line import/order, no-unused-vars
import _GroupedSecurityReportsApp from 'ee/vue_shared/security_reports/grouped_security_reports_app.vue';
// eslint-disable-next-line no-unused-vars
import _Deployment from '~/vue_merge_request_widget/components/deployment/deployment.vue';

const SAST_SELECTOR = '.js-sast-widget';
const DAST_SELECTOR = '.js-dast-widget';
const DEPENDENCY_SCANNING_SELECTOR = '.js-dependency-scanning-widget';
const CONTAINER_SCANNING_SELECTOR = '.js-container-scanning';
const SECRET_SCANNING_SELECTOR = '.js-secret-scanning';
const COVERAGE_FUZZING_SELECTOR = '.js-coverage-fuzzing-widget';
const API_FUZZING_SELECTOR = '.js-api-fuzzing-widget';

describe('ee merge request widget options', () => {
  let vm;
  let mock;
  let Component;

  const DEFAULT_BROWSER_PERFORMANCE = {
    head_path: 'head.json',
    base_path: 'base.json',
  };

  const DEFAULT_LOAD_PERFORMANCE = {
    head_path: 'head.json',
    base_path: 'base.json',
  };

  beforeEach(() => {
    delete mrWidgetOptions.extends.el; // Prevent component mounting

    gon.features = { asyncMrWidget: true };
    gl.mrWidgetData = { ...mockData };

    Component = Vue.extend(mrWidgetOptions);
    mock = new MockAdapter(axios);

    mock.onGet(mockData.merge_request_widget_path).reply(() => [200, gl.mrWidgetData]);
    mock.onGet(mockData.merge_request_cached_widget_path).reply(() => [200, gl.mrWidgetData]);
  });

  afterEach(() => {
    // This is needed because the `fetchInitialData` is triggered while
    // the `mock.restore` is trying to clean up, causing a bunch of
    // unmocked requests...
    // This is not ideal and will be cleaned up in
    // https://gitlab.com/gitlab-org/gitlab/-/issues/214032
    return waitForPromises().then(() => {
      vm.$destroy();
      vm = null;
      mock.restore();
      gon.features = {};
    });
  });

  const findBrowserPerformanceWidget = () => vm.$el.querySelector('.js-browser-performance-widget');
  const findLoadPerformanceWidget = () => vm.$el.querySelector('.js-load-performance-widget');
  const findExtendedSecurityWidget = () => vm.$el.querySelector('.js-security-widget');
  const findBaseSecurityWidget = () => vm.$el.querySelector('[data-testid="security-mr-widget"]');

  const setBrowserPerformance = (data = {}) => {
    const browserPerformance = { ...DEFAULT_BROWSER_PERFORMANCE, ...data };
    gl.mrWidgetData.browserPerformance = browserPerformance;
    vm.mr.browserPerformance = browserPerformance;
  };

  const setLoadPerformance = (data = {}) => {
    const loadPerformance = { ...DEFAULT_LOAD_PERFORMANCE, ...data };
    gl.mrWidgetData.loadPerformance = loadPerformance;
    vm.mr.loadPerformance = loadPerformance;
  };

  const VULNERABILITY_FEEDBACK_ENDPOINT = 'vulnerability_feedback_path';

  describe('SAST', () => {
    const SAST_DIFF_ENDPOINT = 'sast_diff_endpoint';

    beforeEach(() => {
      gl.mrWidgetData = {
        ...mockData,
        enabled_reports: {
          sast: true,
        },
        sast_comparison_path: SAST_DIFF_ENDPOINT,
        vulnerability_feedback_path: VULNERABILITY_FEEDBACK_ENDPOINT,
      };
    });

    describe('when it is loading', () => {
      beforeEach(() => {
        mock = new MockAdapter(axios, { delayResponse: 1 });
        mock.onGet(SAST_DIFF_ENDPOINT).reply(200, sastDiffSuccessMock);
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(200, []);

        vm = mountComponent(Component, { mrData: gl.mrWidgetData });
        vm.loading = false;
      });

      it('should render loading indicator', () => {
        expect(
          findExtendedSecurityWidget().querySelector(SAST_SELECTOR).textContent.trim(),
        ).toContain('SAST is loading');
      });
    });

    describe('with successful request', () => {
      beforeEach(() => {
        mock.onGet(SAST_DIFF_ENDPOINT).reply(200, sastDiffSuccessMock);
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(200, []);
        vm = mountComponent(Component, { mrData: gl.mrWidgetData });
      });

      it('should render provided data', (done) => {
        setImmediate(() => {
          expect(
            trimText(
              findExtendedSecurityWidget().querySelector(
                `${SAST_SELECTOR} .report-block-list-issue-description`,
              ).textContent,
            ),
          ).toEqual('SAST detected 1 potential vulnerability 1 Critical 0 High and 0 Others');
          done();
        });
      });
    });

    describe('with empty successful request', () => {
      beforeEach(() => {
        mock.onGet(SAST_DIFF_ENDPOINT).reply(200, { added: [], existing: [] });
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(200, []);

        vm = mountComponent(Component, { mrData: gl.mrWidgetData });
      });

      it('should render provided data', (done) => {
        setImmediate(() => {
          expect(
            trimText(
              findExtendedSecurityWidget().querySelector(
                `${SAST_SELECTOR} .report-block-list-issue-description`,
              ).textContent,
            ).trim(),
          ).toEqual('SAST detected no vulnerabilities.');
          done();
        });
      });
    });

    describe('with failed request', () => {
      beforeEach(() => {
        mock.onGet(SAST_DIFF_ENDPOINT).reply(500, {});
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(500, []);

        vm = mountComponent(Component, { mrData: gl.mrWidgetData });
      });

      it('should render error indicator', (done) => {
        setImmediate(() => {
          expect(
            trimText(findExtendedSecurityWidget().querySelector(SAST_SELECTOR).textContent),
          ).toContain('SAST: Loading resulted in an error');
          done();
        });
      });
    });
  });

  describe('Dependency Scanning', () => {
    const DEPENDENCY_SCANNING_ENDPOINT = 'dependency_scanning_diff_endpoint';

    beforeEach(() => {
      gl.mrWidgetData = {
        ...mockData,
        enabled_reports: {
          dependency_scanning: true,
        },
        dependency_scanning_comparison_path: DEPENDENCY_SCANNING_ENDPOINT,
        vulnerability_feedback_path: VULNERABILITY_FEEDBACK_ENDPOINT,
      };
    });

    describe('when it is loading', () => {
      beforeEach(() => {
        mock = new MockAdapter(axios, { delayResponse: 1 });
        mock.onGet(DEPENDENCY_SCANNING_ENDPOINT).reply(200, dependencyScanningDiffSuccessMock);
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(200, []);

        vm = mountComponent(Component, { mrData: gl.mrWidgetData });
      });

      it('should render loading indicator', () => {
        expect(
          trimText(
            findExtendedSecurityWidget().querySelector(DEPENDENCY_SCANNING_SELECTOR).textContent,
          ),
        ).toContain('Dependency scanning is loading');
      });
    });

    describe('with successful request', () => {
      beforeEach(() => {
        mock.onGet(DEPENDENCY_SCANNING_ENDPOINT).reply(200, dependencyScanningDiffSuccessMock);
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(200, []);

        vm = mountComponent(Component, { mrData: gl.mrWidgetData });
      });

      it('should render provided data', (done) => {
        setImmediate(() => {
          expect(
            trimText(
              findExtendedSecurityWidget().querySelector(
                `${DEPENDENCY_SCANNING_SELECTOR} .report-block-list-issue-description`,
              ).textContent,
            ),
          ).toEqual(
            'Dependency scanning detected 2 potential vulnerabilities 1 Critical 1 High and 0 Others',
          );
          done();
        });
      });
    });

    describe('with full report and no added or fixed issues', () => {
      beforeEach(() => {
        mock.onGet(DEPENDENCY_SCANNING_ENDPOINT).reply(200, {
          added: [],
          fixed: [],
          existing: [{ title: 'Mock finding' }],
        });
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(200, []);

        vm = mountComponent(Component, { mrData: gl.mrWidgetData });
      });

      it('renders no vulnerabilities message', (done) => {
        setImmediate(() => {
          expect(
            trimText(
              findExtendedSecurityWidget().querySelector(
                `${DEPENDENCY_SCANNING_SELECTOR} .report-block-list-issue-description`,
              ).textContent,
            ),
          ).toEqual('Dependency scanning detected no vulnerabilities.');
          done();
        });
      });
    });

    describe('with empty successful request', () => {
      beforeEach(() => {
        mock.onGet(DEPENDENCY_SCANNING_ENDPOINT).reply(200, { added: [], fixed: [], existing: [] });
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(200, []);

        vm = mountComponent(Component, { mrData: gl.mrWidgetData });
      });

      it('should render provided data', (done) => {
        setImmediate(() => {
          expect(
            trimText(
              findExtendedSecurityWidget().querySelector(
                `${DEPENDENCY_SCANNING_SELECTOR} .report-block-list-issue-description`,
              ).textContent,
            ),
          ).toEqual('Dependency scanning detected no vulnerabilities.');
          done();
        });
      });
    });

    describe('with failed request', () => {
      beforeEach(() => {
        mock.onAny().reply(500);

        vm = mountComponent(Component, { mrData: gl.mrWidgetData });
      });

      it('should render error indicator', (done) => {
        setImmediate(() => {
          expect(
            trimText(
              findExtendedSecurityWidget().querySelector(DEPENDENCY_SCANNING_SELECTOR).textContent,
            ),
          ).toContain('Dependency scanning: Loading resulted in an error');
          done();
        });
      });
    });
  });

  describe('browser_performance', () => {
    beforeEach(() => {
      gl.mrWidgetData = {
        ...mockData,
        browserPerformance: {},
      };
    });

    describe('when it is loading', () => {
      it('should render loading indicator', (done) => {
        mock.onGet('head.json').reply(200, headBrowserPerformance);
        mock.onGet('base.json').reply(200, baseBrowserPerformance);
        vm = mountComponent(Component, { mrData: gl.mrWidgetData });

        vm.mr.browserPerformance = { ...DEFAULT_BROWSER_PERFORMANCE };

        vm.$nextTick(() => {
          expect(trimText(findBrowserPerformanceWidget().textContent)).toContain(
            'Loading browser-performance report',
          );

          done();
        });
      });
    });

    describe('with successful request', () => {
      beforeEach(() => {
        mock.onGet(DEFAULT_BROWSER_PERFORMANCE.head_path).reply(200, headBrowserPerformance);
        mock.onGet(DEFAULT_BROWSER_PERFORMANCE.base_path).reply(200, baseBrowserPerformance);
        vm = mountComponent(Component, { mrData: gl.mrWidgetData });
      });

      describe('default', () => {
        beforeEach(() => {
          setBrowserPerformance();
        });

        it('should render provided data', (done) => {
          setImmediate(() => {
            expect(
              trimText(
                vm.$el.querySelector('.js-browser-performance-widget .js-code-text').textContent,
              ),
            ).toEqual('Browser performance test metrics: 2 degraded, 1 same, 1 improved');
            done();
          });
        });

        describe('text connector', () => {
          it('should only render information about fixed issues', (done) => {
            setImmediate(() => {
              vm.mr.browserPerformanceMetrics.degraded = [];
              vm.mr.browserPerformanceMetrics.same = [];

              Vue.nextTick(() => {
                expect(
                  trimText(
                    vm.$el.querySelector('.js-browser-performance-widget .js-code-text')
                      .textContent,
                  ),
                ).toEqual('Browser performance test metrics: 1 improved');
                done();
              });
            });
          });

          it('should only render information about added issues', (done) => {
            setImmediate(() => {
              vm.mr.browserPerformanceMetrics.improved = [];
              vm.mr.browserPerformanceMetrics.same = [];

              Vue.nextTick(() => {
                expect(
                  trimText(
                    vm.$el.querySelector('.js-browser-performance-widget .js-code-text')
                      .textContent,
                  ),
                ).toEqual('Browser performance test metrics: 2 degraded');
                done();
              });
            });
          });
        });
      });

      describe.each`
        degradation_threshold | shouldExist
        ${1}                  | ${true}
        ${3}                  | ${false}
      `(
        'with degradation_threshold = $degradation_threshold',
        ({ degradation_threshold, shouldExist }) => {
          beforeEach(() => {
            setBrowserPerformance({ degradation_threshold });

            return waitForPromises();
          });

          if (shouldExist) {
            it('should render widget when total score degradation is above threshold', () => {
              expect(findBrowserPerformanceWidget()).toExist();
            });
          } else {
            it('should not render widget when total score degradation is below threshold', () => {
              expect(findBrowserPerformanceWidget()).not.toExist();
            });
          }
        },
      );
    });

    describe('with empty successful request', () => {
      beforeEach((done) => {
        mock.onGet(DEFAULT_BROWSER_PERFORMANCE.head_path).reply(200, []);
        mock.onGet(DEFAULT_BROWSER_PERFORMANCE.base_path).reply(200, []);
        vm = mountComponent(Component, { mrData: gl.mrWidgetData });

        gl.mrWidgetData.browserPerformance = { ...DEFAULT_BROWSER_PERFORMANCE };
        vm.mr.browserPerformance = gl.mrWidgetData.browserPerformance;

        // wait for network request from component watch update method
        setImmediate(done);
      });

      it('should render provided data', () => {
        expect(
          trimText(
            vm.$el.querySelector('.js-browser-performance-widget .js-code-text').textContent,
          ),
        ).toEqual('Browser performance test metrics: No changes');
      });

      it('does not show Expand button', () => {
        const expandButton = vm.$el.querySelector(
          '.js-browser-performance-widget .js-collapse-btn',
        );

        expect(expandButton).toBeNull();
      });

      it('shows success icon', () => {
        expect(
          vm.$el.querySelector('.js-browser-performance-widget .js-ci-status-icon-success'),
        ).not.toBeNull();
      });
    });

    describe('with failed request', () => {
      beforeEach(() => {
        mock.onGet(DEFAULT_BROWSER_PERFORMANCE.head_path).reply(500, []);
        mock.onGet(DEFAULT_BROWSER_PERFORMANCE.base_path).reply(500, []);
        vm = mountComponent(Component, { mrData: gl.mrWidgetData });

        gl.mrWidgetData.browserPerformance = { ...DEFAULT_BROWSER_PERFORMANCE };
        vm.mr.browserPerformance = gl.mrWidgetData.browserPerformance;
      });

      it('should render error indicator', (done) => {
        setImmediate(() => {
          expect(
            trimText(
              vm.$el.querySelector('.js-browser-performance-widget .js-code-text').textContent,
            ),
          ).toContain('Failed to load browser-performance report');
          done();
        });
      });
    });
  });

  describe('load_performance', () => {
    beforeEach(() => {
      gl.mrWidgetData = {
        ...mockData,
        loadPerformance: {},
      };
    });

    describe('when it is loading', () => {
      it('should render loading indicator', (done) => {
        mock.onGet(DEFAULT_LOAD_PERFORMANCE.head_path).reply(200, headLoadPerformance);
        mock.onGet(DEFAULT_LOAD_PERFORMANCE.base_path).reply(200, baseLoadPerformance);
        vm = mountComponent(Component, { mrData: gl.mrWidgetData });

        vm.mr.loadPerformance = { ...DEFAULT_LOAD_PERFORMANCE };

        vm.$nextTick(() => {
          expect(trimText(findLoadPerformanceWidget().textContent)).toContain(
            'Loading load-performance report',
          );

          done();
        });
      });
    });

    describe('with successful request', () => {
      beforeEach(() => {
        mock.onGet(DEFAULT_LOAD_PERFORMANCE.head_path).reply(200, headLoadPerformance);
        mock.onGet(DEFAULT_LOAD_PERFORMANCE.base_path).reply(200, baseLoadPerformance);
        vm = mountComponent(Component, { mrData: gl.mrWidgetData });
      });

      describe('default', () => {
        beforeEach((done) => {
          setLoadPerformance();

          // wait for network request from component watch update method
          setImmediate(done);
        });

        it('should render provided data', () => {
          expect(
            trimText(vm.$el.querySelector('.js-load-performance-widget .js-code-text').textContent),
          ).toBe('Load performance test metrics: 1 degraded, 1 same, 2 improved');
        });

        describe('text connector', () => {
          it('should only render information about fixed issues', (done) => {
            vm.mr.loadPerformanceMetrics.degraded = [];
            vm.mr.loadPerformanceMetrics.same = [];

            Vue.nextTick(() => {
              expect(
                trimText(
                  vm.$el.querySelector('.js-load-performance-widget .js-code-text').textContent,
                ),
              ).toBe('Load performance test metrics: 2 improved');
              done();
            });
          });

          it('should only render information about added issues', (done) => {
            vm.mr.loadPerformanceMetrics.improved = [];
            vm.mr.loadPerformanceMetrics.same = [];

            Vue.nextTick(() => {
              expect(
                trimText(
                  vm.$el.querySelector('.js-load-performance-widget .js-code-text').textContent,
                ),
              ).toBe('Load performance test metrics: 1 degraded');
              done();
            });
          });
        });
      });
    });

    describe('with empty successful request', () => {
      beforeEach((done) => {
        mock.onGet(DEFAULT_LOAD_PERFORMANCE.head_path).reply(200, {});
        mock.onGet(DEFAULT_LOAD_PERFORMANCE.base_path).reply(200, {});
        vm = mountComponent(Component, { mrData: gl.mrWidgetData });

        gl.mrWidgetData.loadPerformance = { ...DEFAULT_LOAD_PERFORMANCE };
        vm.mr.loadPerformance = gl.mrWidgetData.loadPerformance;

        // wait for network request from component watch update method
        setImmediate(done);
      });

      it('should render provided data', () => {
        expect(
          trimText(vm.$el.querySelector('.js-load-performance-widget .js-code-text').textContent),
        ).toBe('Load performance test metrics: No changes');
      });

      it('does not show Expand button', () => {
        const expandButton = vm.$el.querySelector('.js-load-performance-widget .js-collapse-btn');

        expect(expandButton).toBeNull();
      });

      it('shows success icon', () => {
        expect(
          vm.$el.querySelector('.js-load-performance-widget .js-ci-status-icon-success'),
        ).not.toBeNull();
      });
    });

    describe('with failed request', () => {
      beforeEach(() => {
        mock.onGet(DEFAULT_LOAD_PERFORMANCE.head_path).reply(500, []);
        mock.onGet(DEFAULT_LOAD_PERFORMANCE.base_path).reply(500, []);
        vm = mountComponent(Component, { mrData: gl.mrWidgetData });

        gl.mrWidgetData.loadPerformance = { ...DEFAULT_LOAD_PERFORMANCE };
        vm.mr.loadPerformance = gl.mrWidgetData.loadPerformance;
      });

      it('should render error indicator', (done) => {
        setImmediate(() => {
          expect(
            trimText(vm.$el.querySelector('.js-load-performance-widget .js-code-text').textContent),
          ).toContain('Failed to load load-performance report');
          done();
        });
      });
    });
  });

  describe('Container Scanning', () => {
    const CONTAINER_SCANNING_ENDPOINT = 'container_scanning';

    beforeEach(() => {
      gl.mrWidgetData = {
        ...mockData,
        enabled_reports: {
          container_scanning: true,
        },
        container_scanning_comparison_path: CONTAINER_SCANNING_ENDPOINT,
        vulnerability_feedback_path: VULNERABILITY_FEEDBACK_ENDPOINT,
      };
    });

    describe('when it is loading', () => {
      beforeEach(() => {
        mock = new MockAdapter(axios, { delayResponse: 1 });
        mock.onGet(CONTAINER_SCANNING_ENDPOINT).reply(200, containerScanningDiffSuccessMock);
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(200, []);

        vm = mountComponent(Component, { mrData: gl.mrWidgetData });
      });

      it('should render loading indicator', () => {
        expect(
          trimText(
            findExtendedSecurityWidget().querySelector(CONTAINER_SCANNING_SELECTOR).textContent,
          ),
        ).toContain('Container scanning is loading');
      });
    });

    describe('with successful request', () => {
      beforeEach(() => {
        mock.onGet(CONTAINER_SCANNING_ENDPOINT).reply(200, containerScanningDiffSuccessMock);
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(200, []);

        vm = mountComponent(Component, { mrData: gl.mrWidgetData });
      });

      it('should render provided data', (done) => {
        setImmediate(() => {
          expect(
            trimText(
              findExtendedSecurityWidget().querySelector(
                `${CONTAINER_SCANNING_SELECTOR} .report-block-list-issue-description`,
              ).textContent,
            ),
          ).toEqual(
            'Container scanning detected 2 potential vulnerabilities 1 Critical 1 High and 0 Others',
          );
          done();
        });
      });
    });

    describe('with failed request', () => {
      beforeEach(() => {
        mock.onGet(CONTAINER_SCANNING_ENDPOINT).reply(500, {});
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(500, []);

        vm = mountComponent(Component, { mrData: gl.mrWidgetData });
      });

      it('should render error indicator', (done) => {
        setImmediate(() => {
          expect(
            findExtendedSecurityWidget()
              .querySelector(CONTAINER_SCANNING_SELECTOR)
              .textContent.trim(),
          ).toContain('Container scanning: Loading resulted in an error');
          done();
        });
      });
    });
  });

  describe('DAST', () => {
    const DAST_ENDPOINT = 'dast_report';

    beforeEach(() => {
      gl.mrWidgetData = {
        ...mockData,
        enabled_reports: {
          dast: true,
        },
        dast_comparison_path: DAST_ENDPOINT,
        vulnerability_feedback_path: VULNERABILITY_FEEDBACK_ENDPOINT,
      };
    });

    describe('when it is loading', () => {
      beforeEach(() => {
        mock = new MockAdapter(axios, { delayResponse: 1 });
        mock.onGet(DAST_ENDPOINT).reply(200, dastDiffSuccessMock);
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(200, []);

        vm = mountComponent(Component, { mrData: gl.mrWidgetData });
      });

      it('should render loading indicator', () => {
        expect(
          findExtendedSecurityWidget().querySelector(DAST_SELECTOR).textContent.trim(),
        ).toContain('DAST is loading');
      });
    });

    describe('with successful request', () => {
      beforeEach(() => {
        mock.onGet(DAST_ENDPOINT).reply(200, dastDiffSuccessMock);
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(200, []);

        vm = mountComponent(Component, { mrData: gl.mrWidgetData });
      });

      it('should render provided data', (done) => {
        setImmediate(() => {
          expect(
            trimText(
              findExtendedSecurityWidget().querySelector(
                `${DAST_SELECTOR} .report-block-list-issue-description`,
              ).textContent,
            ),
          ).toEqual('DAST detected 1 potential vulnerability 1 Critical 0 High and 0 Others');
          done();
        });
      });
    });

    describe('with failed request', () => {
      beforeEach(() => {
        mock.onGet(DAST_ENDPOINT).reply(500, {});
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(500, {});

        vm = mountComponent(Component, { mrData: gl.mrWidgetData });
      });

      it('should render error indicator', (done) => {
        setImmediate(() => {
          expect(
            findExtendedSecurityWidget().querySelector(DAST_SELECTOR).textContent.trim(),
          ).toContain('DAST: Loading resulted in an error');
          done();
        });
      });
    });
  });

  describe('Coverage Fuzzing', () => {
    const COVERAGE_FUZZING_ENDPOINT = 'coverage_fuzzing_report';

    const mountWithFeatureFlag = () =>
      new Component({
        propsData: { mrData: gl.mrWidgetData },
        provide: {
          glFeatures: { coverageFuzzingMrWidget: true },
        },
      }).$mount();

    beforeEach(() => {
      gl.mrWidgetData = {
        ...mockData,
        enabled_reports: {
          coverage_fuzzing: true,
        },
        coverage_fuzzing_comparison_path: COVERAGE_FUZZING_ENDPOINT,
        vulnerability_feedback_path: VULNERABILITY_FEEDBACK_ENDPOINT,
      };
    });

    describe('when it is loading', () => {
      it('should render loading indicator', () => {
        mock.onGet(COVERAGE_FUZZING_ENDPOINT).reply(200, coverageFuzzingDiffSuccessMock);
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(200, []);
        vm = mountWithFeatureFlag();

        expect(
          findExtendedSecurityWidget().querySelector(COVERAGE_FUZZING_SELECTOR).textContent.trim(),
        ).toContain('Coverage fuzzing is loading');
      });
    });

    describe('with successful request', () => {
      beforeEach(() => {
        mock.onGet(COVERAGE_FUZZING_ENDPOINT).reply(200, coverageFuzzingDiffSuccessMock);
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(200, []);
        vm = mountWithFeatureFlag();
      });

      it('should render provided data', (done) => {
        setImmediate(() => {
          expect(
            trimText(
              findExtendedSecurityWidget().querySelector(
                `${COVERAGE_FUZZING_SELECTOR} .report-block-list-issue-description`,
              ).textContent,
            ),
          ).toEqual(
            'Coverage fuzzing detected 2 potential vulnerabilities 1 Critical 1 High and 0 Others',
          );
          done();
        });
      });
    });

    describe('with failed request', () => {
      beforeEach(() => {
        mock.onGet(COVERAGE_FUZZING_ENDPOINT).reply(500, {});
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(500, {});
        vm = mountWithFeatureFlag();
      });

      it('should render error indicator', (done) => {
        setImmediate(() => {
          expect(
            findExtendedSecurityWidget()
              .querySelector(COVERAGE_FUZZING_SELECTOR)
              .textContent.trim(),
          ).toContain('Coverage fuzzing: Loading resulted in an error');
          done();
        });
      });
    });
  });

  describe('Secret Scanning', () => {
    const SECRET_SCANNING_ENDPOINT = 'secret_detection_report';

    beforeEach(() => {
      gl.mrWidgetData = {
        ...mockData,
        enabled_reports: {
          secret_detection: true,
          // The below property needs to exist until
          // secret scanning is implemented in backend
          // Or for some other reason I'm yet to find
          dast: true,
        },
        secret_scanning_comparison_path: SECRET_SCANNING_ENDPOINT,
        vulnerability_feedback_path: VULNERABILITY_FEEDBACK_ENDPOINT,
      };
    });

    describe('when it is loading', () => {
      it('should render loading indicator', () => {
        mock.onGet(SECRET_SCANNING_ENDPOINT).reply(200, secretScanningDiffSuccessMock);
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(200, []);

        vm = mountComponent(Component, { mrData: gl.mrWidgetData });

        expect(
          trimText(
            findExtendedSecurityWidget().querySelector(SECRET_SCANNING_SELECTOR).textContent,
          ),
        ).toContain('Secret scanning is loading');
      });
    });

    describe('with successful request', () => {
      beforeEach(() => {
        mock.onGet(SECRET_SCANNING_ENDPOINT).reply(200, secretScanningDiffSuccessMock);
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(200, []);

        vm = mountComponent(Component, { mrData: gl.mrWidgetData });
      });

      it('should render provided data', (done) => {
        setImmediate(() => {
          expect(
            trimText(
              findExtendedSecurityWidget().querySelector(
                `${SECRET_SCANNING_SELECTOR} .report-block-list-issue-description`,
              ).textContent,
            ),
          ).toEqual(
            'Secret scanning detected 2 potential vulnerabilities 1 Critical 1 High and 0 Others',
          );
          done();
        });
      });
    });

    describe('with failed request', () => {
      beforeEach(() => {
        mock.onGet(SECRET_SCANNING_ENDPOINT).reply(500, {});
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(500, []);

        vm = mountComponent(Component, { mrData: gl.mrWidgetData });
      });

      it('should render error indicator', (done) => {
        setImmediate(() => {
          expect(
            findExtendedSecurityWidget().querySelector(SECRET_SCANNING_SELECTOR).textContent.trim(),
          ).toContain('Secret scanning: Loading resulted in an error');
          done();
        });
      });
    });
  });

  describe('API Fuzzing', () => {
    const API_FUZZING_ENDPOINT = 'api_fuzzing_report';

    beforeEach(() => {
      gl.mrWidgetData = {
        ...mockData,
        target_project_full_path: '',
        enabled_reports: {
          api_fuzzing: true,
        },
        api_fuzzing_comparison_path: API_FUZZING_ENDPOINT,
        vulnerability_feedback_path: VULNERABILITY_FEEDBACK_ENDPOINT,
      };
    });

    describe('when it is loading', () => {
      it('should render loading indicator', () => {
        mock.onGet(API_FUZZING_ENDPOINT).reply(200, apiFuzzingDiffSuccessMock);
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(200, []);

        vm = mountComponent(Component, { mrData: gl.mrWidgetData });

        expect(
          trimText(findExtendedSecurityWidget().querySelector(API_FUZZING_SELECTOR).textContent),
        ).toContain('API fuzzing is loading');
      });
    });

    describe('with successful request', () => {
      beforeEach(() => {
        mock.onGet(API_FUZZING_ENDPOINT).reply(200, apiFuzzingDiffSuccessMock);
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(200, []);

        vm = mountComponent(Component, { mrData: gl.mrWidgetData });
      });

      it('should render provided data', (done) => {
        setImmediate(() => {
          expect(
            trimText(
              findExtendedSecurityWidget().querySelector(
                `${API_FUZZING_SELECTOR} .report-block-list-issue-description`,
              ).textContent,
            ),
          ).toEqual(
            'API fuzzing detected 2 potential vulnerabilities 1 Critical 1 High and 0 Others',
          );
          done();
        });
      });
    });

    describe('with failed request', () => {
      beforeEach(() => {
        mock.onGet(API_FUZZING_ENDPOINT).reply(500, {});
        mock.onGet(VULNERABILITY_FEEDBACK_ENDPOINT).reply(500, []);

        vm = mountComponent(Component, { mrData: gl.mrWidgetData });
      });

      it('should render error indicator', (done) => {
        setImmediate(() => {
          expect(
            findExtendedSecurityWidget().querySelector(API_FUZZING_SELECTOR).textContent.trim(),
          ).toContain('API fuzzing: Loading resulted in an error');
          done();
        });
      });
    });
  });

  describe('license scanning report', () => {
    const licenseManagementApiUrl = `${TEST_HOST}/manage_license_api`;

    it('should be rendered if license scanning data is set', () => {
      gl.mrWidgetData = {
        ...mockData,
        enabled_reports: {
          license_scanning: true,
        },
        license_scanning: {
          managed_licenses_path: licenseManagementApiUrl,
          can_manage_licenses: false,
        },
      };

      vm = mountComponent(Component, { mrData: gl.mrWidgetData });

      expect(vm.$el.querySelector('.license-report-widget')).not.toBeNull();
    });

    it('should not be rendered if license scanning data is not set', () => {
      gl.mrWidgetData = {
        ...mockData,
        license_scanning: {},
      };

      vm = mountComponent(Component, { mrData: gl.mrWidgetData });

      expect(vm.$el.querySelector('.license-report-widget')).toBeNull();
    });
  });

  describe('CE security report', () => {
    const PIPELINE_JOBS_ENDPOINT = `/api/undefined/projects/${mockData.target_project_id}/pipelines/${mockData.pipeline.id}/jobs`;

    describe.each`
      context                               | canReadVulnerabilities | hasPipeline | featureFlag | shouldRender
      ${'user cannot read vulnerabilities'} | ${false}               | ${true}     | ${true}     | ${true}
      ${'user can read vulnerabilities'}    | ${true}                | ${true}     | ${true}     | ${false}
      ${'no pipeline'}                      | ${false}               | ${false}    | ${true}     | ${false}
      ${'the feature flag is disabled'}     | ${false}               | ${true}     | ${false}    | ${false}
    `('given $context', ({ canReadVulnerabilities, hasPipeline, featureFlag, shouldRender }) => {
      beforeEach(() => {
        gl.mrWidgetData = {
          ...mockData,
          can_read_vulnerabilities: canReadVulnerabilities,
          pipeline: hasPipeline ? mockData.pipeline : undefined,
        };

        gon.features = { coreSecurityMrWidget: featureFlag };

        mock.onGet(PIPELINE_JOBS_ENDPOINT).replyOnce(200, pipelineJobs);
        vm = mountComponent(Component, { mrData: gl.mrWidgetData });

        return waitForPromises();
      });

      it(`${shouldRender ? 'renders' : 'does not render'} the CE security report`, () => {
        expect(findBaseSecurityWidget()).toEqual(shouldRender ? expect.any(HTMLElement) : null);
      });
    });
  });

  describe('computed', () => {
    describe('shouldRenderApprovals', () => {
      it('should return false when in empty state', () => {
        vm = mountComponent(Component, {
          mrData: {
            ...mockData,
            has_approvals_available: true,
          },
        });
        vm.mr.state = 'nothingToMerge';

        expect(vm.shouldRenderApprovals).toBeFalsy();
      });

      it('should return true when requiring approvals and in non-empty state', () => {
        vm = mountComponent(Component, {
          mrData: {
            ...mockData,
            has_approvals_available: true,
          },
        });
        vm.mr.state = 'readyToMerge';

        expect(vm.shouldRenderApprovals).toBeTruthy();
      });
    });
  });

  describe('rendering source branch removal status', () => {
    beforeEach(() => {
      vm = mountComponent(Component, {
        mrData: {
          ...mockData,
        },
      });
    });

    it('renders when user cannot remove branch and branch should be removed', (done) => {
      vm.mr.canRemoveSourceBranch = false;
      vm.mr.shouldRemoveSourceBranch = true;
      vm.mr.state = 'readyToMerge';

      vm.$nextTick(() => {
        const tooltip = vm.$el.querySelector('[data-testid="question-o-icon"]');

        expect(vm.$el.textContent).toContain('Deletes source branch');
        expect(tooltip.getAttribute('title')).toBe(
          'A user with write access to the source branch selected this option',
        );

        done();
      });
    });

    it('does not render in merged state', (done) => {
      vm.mr.canRemoveSourceBranch = false;
      vm.mr.shouldRemoveSourceBranch = true;
      vm.mr.state = 'merged';

      vm.$nextTick(() => {
        expect(vm.$el.textContent).toContain('The source branch has been deleted');
        expect(vm.$el.textContent).not.toContain('Removes source branch');

        done();
      });
    });
  });

  describe('rendering deployments', () => {
    const deploymentMockData = {
      id: 15,
      name: 'review/diplo',
      url: '/root/acets-review-apps/environments/15',
      stop_url: '/root/acets-review-apps/environments/15/stop',
      metrics_url: '/root/acets-review-apps/environments/15/deployments/1/metrics',
      metrics_monitoring_url: '/root/acets-review-apps/environments/15/metrics',
      external_url: 'http://diplo.',
      external_url_formatted: 'diplo.',
      deployed_at: '2017-03-22T22:44:42.258Z',
      deployed_at_formatted: 'Mar 22, 2017 10:44pm',
      status: SUCCESS,
    };

    beforeEach((done) => {
      vm = mountComponent(Component, {
        mrData: {
          ...mockData,
        },
      });

      vm.mr.deployments.push(
        {
          ...deploymentMockData,
        },
        {
          ...deploymentMockData,
          id: deploymentMockData.id + 1,
        },
      );

      vm.$nextTick(done);
    });

    it('renders multiple deployments', () => {
      expect(vm.$el.querySelectorAll('.deploy-heading')).toHaveLength(2);
    });
  });

  describe('CI widget', () => {
    it('renders the branch in the pipeline widget', () => {
      const sourceBranchLink = '<a href="/to/the/past">Link</a>';
      vm = mountComponent(Component, {
        mrData: {
          ...mockData,
          source_branch_with_namespace_link: sourceBranchLink,
        },
      });

      const ciWidget = vm.$el.querySelector('.mr-state-widget .label-branch');

      expect(ciWidget.innerHTML).toBe(sourceBranchLink);
    });
  });

  describe('data', () => {
    it('passes approval api paths to service', () => {
      const paths = {
        api_approvals_path: `${TEST_HOST}/api/approvals/path`,
        api_approval_settings_path: `${TEST_HOST}/api/approval/settings/path`,
        api_approve_path: `${TEST_HOST}/api/approve/path`,
        api_unapprove_path: `${TEST_HOST}/api/unapprove/path`,
      };

      vm = mountComponent(Component, {
        mrData: {
          ...mockData,
          ...paths,
        },
      });

      expect(vm.service).toMatchObject(convertObjectPropsToCamelCase(paths));
    });
  });

  describe('when no security reports are enabled', () => {
    const noSecurityReportsEnabledCases = [
      undefined,
      {},
      { foo: true },
      { license_scanning: true },
      {
        dast: false,
        sast: false,
        container_scanning: false,
        dependency_scanning: false,
        secret_detection: false,
      },
    ];

    noSecurityReportsEnabledCases.forEach((noSecurityReportsEnabled) => {
      it('does not render the security reports widget', () => {
        gl.mrWidgetData = {
          ...mockData,
          enabled_reports: noSecurityReportsEnabled,
        };

        if (noSecurityReportsEnabled?.license_scanning) {
          // Provide license report config if it's going to be rendered
          gl.mrWidgetData.license_scanning = {
            managed_licenses_path: `${TEST_HOST}/manage_license_api`,
            can_manage_licenses: false,
          };
        }

        vm = mountComponent(Component, { mrData: gl.mrWidgetData });

        expect(findExtendedSecurityWidget()).toBe(null);
      });
    });
  });

  describe('given the user cannot read vulnerabilites', () => {
    beforeEach(() => {
      gl.mrWidgetData = {
        ...mockData,
        can_read_vulnerabilities: false,
        enabled_reports: {
          sast: true,
        },
      };

      vm = mountComponent(Component, { mrData: gl.mrWidgetData });
    });

    it('does not render the EE security report', () => {
      expect(findExtendedSecurityWidget()).toBe(null);
    });
  });
});
