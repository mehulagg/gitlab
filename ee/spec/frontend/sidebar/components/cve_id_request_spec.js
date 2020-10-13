import Vue from 'vue';
import CveIdRequest from 'ee/sidebar/components/cve_id_request/cve_id_request_sidebar.vue';
import { shallowMount } from '@vue/test-utils';

describe('CveIdRequest', () => {
  let wrapper;

  const initCveIdRequest = () => {
    setFixtures(`
      <div>
        <div id="mock-container"></div>
      </div>
    `);

    const provide = {
      iid: 'test',
      fullPath: 'some/path',
      issueTitle: 'Issue Title',
      initialConfidential: true,
    };

    const CveIdRequestComponent = Vue.extend({
      ...CveIdRequest,
      components: {
        ...CveIdRequest.components,
        transition: {
          // disable animations
          render(h) {
            return h('div', this.$slots.default);
          },
        },
      },
    });
    wrapper = shallowMount(CveIdRequestComponent, {
      provide,
    });
  };

  beforeEach(() => {
    initCveIdRequest();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('Renders the main "Request CVE ID" button', () => {
    expect(wrapper.find('.js-cve-id-request-button').element).not.toBeNull();
  });

  it('Renders the "help-button" by default', () => {
    expect(wrapper.find('.help-button').element).not.toBeNull();
  });

  describe('Help Pane', () => {
    const helpButton = () => wrapper.find('.help-button').element;
    const closeHelpButton = () => wrapper.find('.close-help-button').element;
    const helpPane = () => wrapper.find('.cve-id-request-help-state').element;

    beforeEach(() => {
      initCveIdRequest();
      return wrapper.vm.$nextTick();
    });

    it('should not show the "Help" pane by default', () => {
      expect(wrapper.vm.showHelpState).toBe(false);
      expect(helpPane()).toBeUndefined();
    });

    it('should show the "Help" pane when help button is clicked', () => {
      helpButton().click();

      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.vm.showHelpState).toBe(true);

        // let animations run
        jest.advanceTimersByTime(500);

        expect(helpPane()).not.toBeUndefined();
      });
    });

    it('should not show the "Help" pane when help button is clicked and then closed', (done) => {
      helpButton().click();

      Vue.nextTick()
        .then(() => closeHelpButton().click())
        .then(() => Vue.nextTick())
        .then(() => {
          expect(wrapper.vm.showHelpState).toBe(false);
          expect(helpPane()).toBeUndefined();
        })
        .then(done)
        .catch(done.fail);
    });
  });
});
