import { GlBreadcrumb } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import LegacyContainer from '~/projects/experiment_new_project_creation/components/legacy_container.vue';
import WelcomePage from '~/projects/experiment_new_project_creation/components/welcome.vue';
import GitlabExperiment from '~/gitlab_experiment';

describe('Experimental new project creation app', () => {
  let wrapper;

  const createComponent = (propsData) => {
    let App;
    jest.isolateModules(() => {
      App = require('~/projects/experiment_new_project_creation/components/app.vue').default;
    });

    wrapper = shallowMount(App, { propsData });
  };

  afterEach(() => {
    wrapper.destroy();
    window.location.hash = '';
    wrapper = null;
  });

  const findWelcomePage = () => wrapper.find(WelcomePage);
  const findPanel = (panelName) => findWelcomePage().props().panels.find((p) => p.name == panelName)

  describe('new_repo experiment', () => {
    beforeEach(() => {
      jest.restoreAllMocks()
    });

    it('when in the candidate variant it has "repository" in the panel title', () => {
      jest.spyOn(GitlabExperiment, 'currentVariantName').mockImplementation(() => 'candidate');

      createComponent();

      expect(findPanel('blank_project').title).toEqual('Create blank project/repository');
    });

    it('when in the control variant it has "project" in the panel title', () => {
      jest.spyOn(GitlabExperiment, 'currentVariantName').mockImplementation(() => 'control');

      createComponent();

      expect(findPanel('blank_project').title).toEqual('Create blank project');
    });
  });

  describe('with empty hash', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders welcome page', () => {
      expect(wrapper.find(WelcomePage).exists()).toBe(true);
    });

    it('does not render breadcrumbs', () => {
      expect(wrapper.find(GlBreadcrumb).exists()).toBe(false);
    });
  });

  it('renders blank project container if there are errors', () => {
    createComponent({ hasErrors: true });
    expect(wrapper.find(WelcomePage).exists()).toBe(false);
    expect(wrapper.find(LegacyContainer).exists()).toBe(true);
  });

  describe('when hash is not empty on load', () => {
    beforeEach(() => {
      window.location.hash = '#blank_project';
      createComponent();
    });

    it('renders relevant container', () => {
      expect(wrapper.find(WelcomePage).exists()).toBe(false);
      expect(wrapper.find(LegacyContainer).exists()).toBe(true);
    });

    it('renders breadcrumbs', () => {
      expect(wrapper.find(GlBreadcrumb).exists()).toBe(true);
    });
  });

  describe('display custom new project guideline text', () => {
    beforeEach(() => {
      window.location.hash = '#blank_project';
    });

    it('does not render new project guideline if undefined', () => {
      createComponent();
      expect(wrapper.find('div#new-project-guideline').exists()).toBe(false);
    });

    it('render new project guideline if defined', () => {
      const guidelineSelector = 'div#new-project-guideline';

      createComponent({
        newProjectGuidelines: '<h4>Internal Guidelines</h4><p>lorem ipsum</p>',
      });
      expect(wrapper.find(guidelineSelector).exists()).toBe(true);
      expect(wrapper.find(guidelineSelector).html()).toContain('<h4>Internal Guidelines</h4>');
      expect(wrapper.find(guidelineSelector).html()).toContain('<p>lorem ipsum</p>');
    });
  });

  it('renders relevant container when hash changes', () => {
    createComponent();
    expect(wrapper.find(WelcomePage).exists()).toBe(true);

    window.location.hash = '#blank_project';
    const ev = document.createEvent('HTMLEvents');
    ev.initEvent('hashchange', false, false);
    window.dispatchEvent(ev);

    return wrapper.vm.$nextTick().then(() => {
      expect(wrapper.find(WelcomePage).exists()).toBe(false);
      expect(wrapper.find(LegacyContainer).exists()).toBe(true);
    });
  });
});
