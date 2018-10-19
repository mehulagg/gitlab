import Vue from 'vue';
import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import jobApp from '~/jobs/components/job_app.vue';
import createStore from '~/jobs/store';
import { mountComponentWithStore } from 'spec/helpers/vue_mount_component_helper';
import { resetStore } from '../store/helpers';
import job from '../mock_data';

describe('Job App ', () => {
  const Component = Vue.extend(jobApp);
  let store;
  let vm;
  let mock;

  const props = {
    endpoint: `${gl.TEST_HOST}jobs/123.json`,
    runnerHelpUrl: 'help/runner',
    runnerSettingsUrl: 'settings/ci-cd/runners',
    terminalPath: 'jobs/123/terminal',
    pagePath: `${gl.TEST_HOST}jobs/123`,
    logState:
      'eyJvZmZzZXQiOjE3NDUxLCJuX29wZW5fdGFncyI6MCwiZmdfY29sb3IiOm51bGwsImJnX2NvbG9yIjpudWxsLCJzdHlsZV9tYXNrIjowfQ%3D%3D',
  };

  beforeEach(() => {
    mock = new MockAdapter(axios);
    store = createStore();
  });

  afterEach(() => {
    resetStore(store);
    vm.$destroy();
    mock.restore();
  });

  describe('while loading', () => {
    beforeEach(() => {
      mock.onGet(props.endpoint).reply(200, job, {});
      mock.onGet(`${props.pagePath}/trace.json`).reply(200, {});
      vm = mountComponentWithStore(Component, { props, store });
    });

    it('renders loading icon', done => {
      expect(vm.$el.querySelector('.js-job-loading')).not.toBeNull();
      expect(vm.$el.querySelector('.js-job-sidebar')).toBeNull();
      expect(vm.$el.querySelector('.js-job-content')).toBeNull();

      setTimeout(() => {
        done();
      }, 0);
    });
  });

  describe('with successfull request', () => {
    beforeEach(() => {
      mock.onGet(`${props.pagePath}/trace.json`).replyOnce(200, {});
    });

    describe('Header section', () => {
      describe('job callout message', () => {
        it('should not render the reason when reason is absent', done => {
          mock.onGet(props.endpoint).replyOnce(200, job);
          vm = mountComponentWithStore(Component, { props, store });

          setTimeout(() => {
            expect(vm.shouldRenderCalloutMessage).toBe(false);

            done();
          }, 0);
        });

        it('should render the reason when reason is present', done => {
          mock.onGet(props.endpoint).replyOnce(
            200,
            Object.assign({}, job, {
              callout_message: 'There is an unknown failure, please try again',
            }),
          );

          vm = mountComponentWithStore(Component, { props, store });
          setTimeout(() => {
            expect(vm.shouldRenderCalloutMessage).toBe(true);
            done();
          }, 0);
        });
      });

      describe('triggered job', () => {
        beforeEach(() => {
          mock.onGet(props.endpoint).replyOnce(200, Object.assign({}, job, { started: '2017-05-24T10:59:52.000+01:00' }));
          vm = mountComponentWithStore(Component, { props, store });
        });

        it('should render provided job information', done => {
          setTimeout(() => {
            expect(
              vm.$el
                .querySelector('.header-main-content')
                .textContent.replace(/\s+/g, ' ')
                .trim(),
            ).toEqual('passed Job #4757 triggered 1 year ago by Root');
            done();
          }, 0);
        });

        it('should render new issue link', done => {
          setTimeout(() => {
            expect(vm.$el.querySelector('.js-new-issue').getAttribute('href')).toEqual(
              job.new_issue_path,
            );
            done();
          }, 0);
        });
      });

      describe('created job', () => {
        it('should render created key', done => {
          mock.onGet(props.endpoint).replyOnce(200, job);
          vm = mountComponentWithStore(Component, { props, store });

          setTimeout(() => {
            expect(
              vm.$el
                .querySelector('.header-main-content')
                .textContent.replace(/\s+/g, ' ')
                .trim(),
            ).toEqual('passed Job #4757 created 3 weeks ago by Root');
            done();
          }, 0);
        });
      });
    });

    describe('stuck block', () => {
      it('renders stuck block when there are no runners', done => {
        mock.onGet(props.endpoint).replyOnce(
          200,
          Object.assign({}, job, {
            status: {
              group: 'pending',
              icon: 'status_pending',
              label: 'pending',
              text: 'pending',
              details_path: 'path',
            },
            runners: {
              available: false,
            },
          }),
        );
        vm = mountComponentWithStore(Component, { props, store });

        setTimeout(() => {
          expect(vm.$el.querySelector('.js-job-stuck')).not.toBeNull();

          done();
        }, 0);
      });

      it('renders tags in stuck block when there are no runners', done => {
        mock.onGet(props.endpoint).replyOnce(
          200,
          Object.assign({}, job, {
            status: {
              group: 'pending',
              icon: 'status_pending',
              label: 'pending',
              text: 'pending',
              details_path: 'path',
            },
            runners: {
              available: false,
            },
          }),
        );

        vm = mountComponentWithStore(Component, {
          props,
          store,
        });

        setTimeout(() => {
          expect(vm.$el.querySelector('.js-job-stuck').textContent).toContain(job.tags[0]);
          done();
        }, 0);
      });

      it('does not renders stuck block when there are no runners', done => {
        mock.onGet(props.endpoint).replyOnce(
          200,
          Object.assign({}, job, {
            runners: { available: true },
          }),
        );

        vm = mountComponentWithStore(Component, {
          props,
          store,
        });

        setTimeout(() => {
          expect(vm.$el.querySelector('.js-job-stuck')).toBeNull();

          done();
        }, 0);
      });
    });

    describe('environments block', () => {
      it('renders environment block when job has environment', done => {
        mock.onGet(props.endpoint).replyOnce(
          200,
          Object.assign({}, job, {
            deployment_status: {
              environment: {
                environment_path: '/path',
                name: 'foo',
              },
            },
          }),
        );

        vm = mountComponentWithStore(Component, {
          props,
          store,
        });

        setTimeout(() => {
          expect(vm.$el.querySelector('.js-job-environment')).not.toBeNull();

          done();
        }, 0);
      });

      it('does not render environment block when job has environment', done => {
        mock.onGet(props.endpoint).replyOnce(200, job);

        vm = mountComponentWithStore(Component, {
          props,
          store,
        });

        setTimeout(() => {
          expect(vm.$el.querySelector('.js-job-environment')).toBeNull();
          done();
        }, 0);
      });
    });

    describe('erased block', () => {
      it('renders erased block when `erased` is true', done => {
        mock.onGet(props.endpoint).replyOnce(
          200,
          Object.assign({}, job, {
            erased_by: {
              username: 'root',
              web_url: 'gitlab.com/root',
            },
            erased_at: '2016-11-07T11:11:16.525Z',
          }),
        );

        vm = mountComponentWithStore(Component, {
          props,
          store,
        });

        setTimeout(() => {
          expect(vm.$el.querySelector('.js-job-erased-block')).not.toBeNull();

          done();
        }, 0);
      });

      it('does not render erased block when `erased` is false', done => {
        mock.onGet(props.endpoint).replyOnce(200, Object.assign({}, job, { erased_at: null }));

        vm = mountComponentWithStore(Component, {
          props,
          store,
        });

        setTimeout(() => {
          expect(vm.$el.querySelector('.js-job-erased-block')).toBeNull();

          done();
        }, 0);
      });
    });

    describe('empty states block', () => {
      it('renders empty state when job does not have trace and is not running', done => {
        mock.onGet(props.endpoint).replyOnce(
          200,
          Object.assign({}, job, {
            has_trace: false,
            status: {
              group: 'pending',
              icon: 'status_pending',
              label: 'pending',
              text: 'pending',
              details_path: 'path',
              illustration: {
                image: 'path',
                size: '340',
                title: 'Empty State',
                content: 'This is an empty state',
              },
              action: {
                button_title: 'Retry job',
                method: 'post',
                path: '/path',
              },
            },
          }),
        );

        vm = mountComponentWithStore(Component, {
          props,
          store,
        });

        setTimeout(() => {
          expect(vm.$el.querySelector('.js-job-empty-state')).not.toBeNull();

          done();
        }, 0);
      });

      it('does not render empty state when job does not have trace but it is running', done => {
        mock.onGet(props.endpoint).replyOnce(
          200,
          Object.assign({}, job, {
            has_trace: false,
            status: {
              group: 'running',
              icon: 'status_running',
              label: 'running',
              text: 'running',
              details_path: 'path',
            },
          }),
        );

        vm = mountComponentWithStore(Component, {
          props,
          store,
        });

        setTimeout(() => {
          expect(vm.$el.querySelector('.js-job-empty-state')).toBeNull();

          done();
        }, 0);
      });

      it('does not render empty state when job has trace but it is not running', done => {
        mock.onGet(props.endpoint).replyOnce(200, Object.assign({}, job, { has_trace: true }));

        vm = mountComponentWithStore(Component, {
          props,
          store,
        });

        setTimeout(() => {
          expect(vm.$el.querySelector('.js-job-empty-state')).toBeNull();

          done();
        }, 0);
      });
    });
  });

  describe('trace output', () => {
    beforeEach(() => {
      mock.onGet(props.endpoint).reply(200, job, {});
    });

    describe('with append flag', () => {
      it('appends the log content to the existing one', done => {
        mock.onGet(`${props.pagePath}/trace.json`).reply(200, {
          html: '<span>More<span>',
          status: 'running',
          state: 'newstate',
          append: true,
          complete: true,
        });

        vm = mountComponentWithStore(Component, {
          props,
          store,
        });

        vm.$store.state.trace = 'Update';

        setTimeout(() => {
          expect(vm.$el.querySelector('.js-build-trace').textContent.trim()).toContain('Update');

          done();
        }, 0);
      });
    });

    describe('without append flag', () => {
      it('replaces the trace', done => {
        mock.onGet(`${props.pagePath}/trace.json`).reply(200, {
          html: '<span>Different<span>',
          status: 'running',
          append: false,
          complete: true,
        });

        vm = mountComponentWithStore(Component, {
          props,
          store,
        });
        vm.$store.state.trace = 'Update';

        setTimeout(() => {
          expect(vm.$el.querySelector('.js-build-trace').textContent.trim()).not.toContain('Update');
          expect(vm.$el.querySelector('.js-build-trace').textContent.trim()).toContain(
            'Different',
          );
          done();
        }, 0);
      });
    });

    describe('truncated information', () => {
      describe('when size is less than total', () => {
        it('shows information about truncated log', done => {
          mock.onGet(`${props.pagePath}/trace.json`).reply(200, {
            html: '<span>Update</span>',
            status: 'success',
            append: false,
            size: 50,
            total: 100,
            complete: true,
          });

          vm = mountComponentWithStore(Component, {
            props,
            store,
          });

          setTimeout(() => {
            expect(vm.$el.querySelector('.js-truncated-info').textContent.trim()).toContain(
              '50 bytes',
            );
            done();
          }, 0);
        });
      });

      describe('when size is equal than total', () => {
        it('does not show the truncated information', done => {
          mock.onGet(`${props.pagePath}/trace.json`).reply(200, {
            html: '<span>Update</span>',
            status: 'success',
            append: false,
            size: 100,
            total: 100,
            complete: true,
          });

          vm = mountComponentWithStore(Component, {
            props,
            store,
          });

          setTimeout(() => {
            expect(vm.$el.querySelector('.js-truncated-info').textContent.trim()).not.toContain(
              '50 bytes',
            );
            done();
          }, 0);
        });
      });
    });

    describe('trace controls', () => {
      beforeEach(() => {
        mock.onGet(`${props.pagePath}/trace.json`).reply(200, {
          html: '<span>Update</span>',
          status: 'success',
          append: false,
          size: 50,
          total: 100,
          complete: true,
        });

        vm = mountComponentWithStore(Component, {
          props,
          store,
        });
      });

      it('should render scroll buttons', done => {
        setTimeout(() => {
          expect(vm.$el.querySelector('.js-scroll-top')).not.toBeNull();
          expect(vm.$el.querySelector('.js-scroll-bottom')).not.toBeNull();
          done();
        }, 0);
      });

      it('should render link to raw ouput', done => {
        setTimeout(() => {
          expect(vm.$el.querySelector('.js-raw-link-controller')).not.toBeNull();
          done();
        }, 0);
      });

      it('should render link to erase job', done => {
        setTimeout(() => {
          expect(vm.$el.querySelector('.js-erase-link')).not.toBeNull();
          done();
        }, 0);
      });
    });
  });
});
