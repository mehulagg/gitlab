import { nextTick } from 'vue';
import { shallowMount, mount } from '@vue/test-utils';
import { GlLoadingIcon } from '@gitlab/ui';
import CiLint from '~/pipeline_editor/components/lint/ci_lint.vue';
import PipelineGraph from '~/pipelines/components/pipeline_graph/pipeline_graph.vue';
import PipelineEditorTabs from '~/pipeline_editor/components/pipeline_editor_tabs.vue';
import CiConfigMergedPreview from '~/pipeline_editor/components/editor/ci_config_merged_preview.vue';

import { mockLintResponse, mockCiYml } from '../mock_data';

describe('Pipeline editor tabs component', () => {
  let wrapper;
  const MockTextEditor = {
    template: '<div />',
  };
  const mockProvide = {
    glFeatures: {
      ciConfigVisualizationTab: true,
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

  const findLoadingIcon = () => wrapper.find(GlLoadingIcon);
  const findEditorTab = () => wrapper.find('[data-testid="editor-tab"]');
  const findLintTab = () => wrapper.find('[data-testid="lint-tab"]');
  const findMergedTab = () => wrapper.find('[data-testid="merged-tab"]');
  const findVisualizationTab = () => wrapper.find('[data-testid="visualization-tab"]');
  const findTextEditor = () => wrapper.find(MockTextEditor);
  const findPipelineGraph = () => wrapper.find(PipelineGraph);
  const findCiLint = () => wrapper.find(CiLint);
  const findMergedPreview = () => wrapper.find(CiConfigMergedPreview);

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('tabs', () => {
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
      describe('while loading', () => {
        beforeEach(() => {
          createComponent({ props: { isCiConfigDataLoading: true } });
        });

        it('displays a loading icon if the lint query is loading', () => {
          expect(findLoadingIcon().exists()).toBe(true);
        });
      });
      describe('after loading', () => {
        beforeEach(() => {
          createComponent();
        });

        it('display the tab and the lint component', () => {
          expect(findMergedTab().exists()).toBe(true);
          expect(findMergedPreview().exists()).toBe(true);
        });
      });
    });
  });
});
