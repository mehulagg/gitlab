import { shallowMount } from '@vue/test-utils';
import PipelineEditorHeader from '~/pipeline_editor/components/header/pipeline_editor_header.vue';
import PipelineStatus from '~/pipeline_editor/components/header/pipeline_status.vue';
import ValidationSegment from '~/pipeline_editor/components/header/validation_segment.vue';

import { mockCiYml, mockLintResponse } from '../../mock_data';

describe('Pipeline editor header', () => {
  let wrapper;
  const mockProvide = {
    glFeatures: {
      pipelineStatusForPipelineEditor: true,
    },
  };

  const createComponent = ({ provide = {} } = {}) => {
    wrapper = shallowMount(PipelineEditorHeader, {
      provide: {
        ...mockProvide,
        ...provide,
      },
      propsData: {
        ciConfigData: mockLintResponse,
        ciFileContent: mockCiYml,
        isCiConfigDataLoading: false,
        isNewCiConfigFile: false,
      },
    });
  };

  const findPipelineStatus = () => wrapper.findComponent(PipelineStatus);
  const findValidationSegment = () => wrapper.findComponent(ValidationSegment);

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('template', () => {
    it('hides the pipeline status for new projects without a CI file', () => {
      createComponent({ isNewCiConfigFile: true });

      expect(findPipelineStatus({}).exists()).toBe(true);
    });

    it('renders the pipeline status when CI file exists', () => {
      createComponent({ isNewCiConfigFile: false });

      expect(findPipelineStatus().exists()).toBe(true);
    });

    it('renders the validation segment', () => {
      createComponent();

      expect(findValidationSegment().exists()).toBe(true);
    });
  });

  describe('with pipeline status feature flag off', () => {
    beforeEach(() => {
      createComponent({
        provide: {
          glFeatures: { pipelineStatusForPipelineEditor: false },
        },
      });
    });

    it('does not render the pipeline status', () => {
      expect(findPipelineStatus().exists()).toBe(false);
    });
  });
});
