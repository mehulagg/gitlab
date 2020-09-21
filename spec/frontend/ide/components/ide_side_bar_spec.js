import { mount, shallowMount, createLocalVue } from '@vue/test-utils';
import Vuex from 'vuex';
import { createStore } from '~/ide/stores';
import IdeSidebar from '~/ide/components/ide_side_bar.vue';
import IdeTree from '~/ide/components/ide_tree.vue';
import { leftSidebarViews } from '~/ide/constants';
import { projectData } from '../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('IdeSidebar', () => {
  let wrapper;
  let store;

  function createComponent(mountFn = mount) {
    store = createStore();

    store.state.currentProjectId = 'abcproject';
    store.state.projects.abcproject = projectData;

    return mountFn(IdeSidebar, {
      store,
      localVue,
    });
  }

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders a sidebar', () => {
    wrapper = createComponent();

    expect(wrapper.vm.$el.querySelector('.multi-file-commit-panel-inner')).not.toBeNull();
  });

  it('renders loading icon component', done => {
    wrapper = createComponent();

    store.state.loading = true;

    wrapper.vm.$nextTick(() => {
      expect(wrapper.vm.$el.querySelector('.multi-file-loading-container')).not.toBeNull();
      expect(wrapper.vm.$el.querySelectorAll('.multi-file-loading-container').length).toBe(3);

      done();
    });
  });

  describe('activityBarComponent', () => {
    it('renders tree component', () => {
      wrapper = createComponent();

      expect(wrapper.vm.$el.querySelector('.ide-file-list')).not.toBeNull();
    });

    it('renders commit component', done => {
      wrapper = createComponent();

      wrapper.vm.$store.state.currentActivityView = leftSidebarViews.commit.name;

      wrapper.vm.$nextTick(() => {
        expect(wrapper.vm.$el.querySelector('.multi-file-commit-panel-section')).not.toBeNull();

        done();
      });
    });
  });

  it('keeps the current activity view components alive', () => {
    wrapper = createComponent(shallowMount);

    expect(
      wrapper
        .find('keep-alive-stub')
        .find(IdeTree)
        .exists(),
    ).toBe(true);
  });
});
