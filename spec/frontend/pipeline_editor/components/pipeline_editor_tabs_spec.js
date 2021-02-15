import { GlAlert, GlLoadingIcon } from '@gitlab/ui';
import { shallowMount, mount } from '@vue/test-utils';
import { nextTick } from 'vue';
import CiConfigMergedPreview from '~/pipeline_editor/components/editor/ci_config_merged_preview.vue';
import CiLint from '~/pipeline_editor/components/lint/ci_lint.vue';
import PipelineEditorTabs from '~/pipeline_editor/components/pipeline_editor_tabs.vue';
import PipelineGraph from '~/pipelines/components/pipeline_graph/pipeline_graph.vue';

import { mockLintResponse, mockCiYml } from '../mock_data';

describe('Pipeline editor tabs component', () => {
  let wrapper;
  const MockTextEditor = {
    template: '<div />',
  };
  const mockProvide = {
    glFeatures: {
      ciConfigVisualizationTab: true,
      ciConfigMergedTab: true,
    },
  };

  const createComponent = ({ props = {}, provide = {}, mountFn = shallowMount } = {}) => {
    wrapper = mountFn(PipelineEditorTabs, {
      propsData: {
        ciConfigData: mockLintResponse,
        ciFileContent: mockCiYml,
        isCiConfigDataLoading: false,
        ...props,
      },
      provide: { ...mockProvide, ...provide },
      stubs: {
        TextEditor: MockTextEditor,
      },
    });
  };

  const findEditorTab = () => wrapper.find('[data-testid="editor-tab"]');
  const findLintTab = () => wrapper.find('[data-testid="lint-tab"]');
  const findMergedTab = () => wrapper.find('[data-testid="merged-tab"]');
  const findVisualizationTab = () => wrapper.find('[data-testid="visualization-tab"]');

  const findAlert = () => wrapper.findComponent(GlAlert);
  const findCiLint = () => wrapper.findComponent(CiLint);
  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);
  const findPipelineGraph = () => wrapper.findComponent(PipelineGraph);
  const findTextEditor = () => wrapper.findComponent(MockTextEditor);
  const findMergedPreview = () => wrapper.findComponent(CiConfigMergedPreview);

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('editor tab', () => {
    it('displays editor only after the tab is mounted', async () => {
      createComponent({ mountFn: mount });

      expect(findTextEditor().exists()).toBe(false);

      await nextTick();

      expect(findTextEditor().exists()).toBe(true);
      expect(findEditorTab().exists()).toBe(true);
    });
  });

  describe('visualization tab', () => {
    describe('with feature flag on', () => {
      describe('while loading', () => {
        beforeEach(() => {
          createComponent({ props: { isCiConfigDataLoading: true } });
        });

        it('displays a loading icon if the lint query is loading', () => {
          expect(findLoadingIcon().exists()).toBe(true);
          expect(findPipelineGraph().exists()).toBe(false);
        });
      });
      describe('after loading', () => {
        beforeEach(() => {
          createComponent();
        });

        it('display the tab and visualization', () => {
          expect(findVisualizationTab().exists()).toBe(true);
          expect(findPipelineGraph().exists()).toBe(true);
        });
      });
    });

    describe('with feature flag off', () => {
      beforeEach(() => {
        createComponent({
          provide: {
            glFeatures: { ciConfigVisualizationTab: false },
          },
        });
      });

      it('does not display the tab or component', () => {
        expect(findVisualizationTab().exists()).toBe(false);
        expect(findPipelineGraph().exists()).toBe(false);
      });
    });
  });

  describe('lint tab', () => {
    describe('while loading', () => {
      beforeEach(() => {
        createComponent({ props: { isCiConfigDataLoading: true } });
      });

      it('displays a loading icon if the lint query is loading', () => {
        expect(findLoadingIcon().exists()).toBe(true);
      });

      it('does not display the lint component', () => {
        expect(findCiLint().exists()).toBe(false);
      });
    });
    describe('after loading', () => {
      beforeEach(() => {
        createComponent();
      });

      it('display the tab and the lint component', () => {
        expect(findLintTab().exists()).toBe(true);
        expect(findCiLint().exists()).toBe(true);
      });
    });
  });

  describe('merged tab', () => {
    describe('with feature flag on', () => {
      describe('while loading', () => {
        beforeEach(() => {
          createComponent({ props: { isCiConfigDataLoading: true } });
        });

        it('displays a loading icon if the lint query is loading', () => {
          expect(findLoadingIcon().exists()).toBe(true);
        });
      });

      describe('when `mergedYaml` is undefined', () => {
        beforeEach(() => {
          createComponent({ props: { ciConfigData: {} } });
        });

        it('show an error message', () => {
          expect(findAlert().exists()).toBe(true);
          expect(findAlert().text()).toBe(wrapper.vm.$options.errorTexts.loadMergedYaml);
        });

        it('does not render the `meged_preview` component', () => {
          expect(findMergedPreview().exists()).toBe(false);
        });
      });

      describe('after loading', () => {
        beforeEach(() => {
          createComponent();
        });

        it('display the tab and the merged preview component', () => {
          expect(findMergedTab().exists()).toBe(true);
          expect(findMergedPreview().exists()).toBe(true);
        });
      });
    });
    describe('with feature flag off', () => {
      beforeEach(() => {
        createComponent({ provide: { glFeatures: { ciConfigMergedTab: false } } });
      });

      it('does not display the merged tab', () => {
        expect(findMergedTab().exists()).toBe(false);
        expect(findMergedPreview().exists()).toBe(false);
      });
    });
  });
});
