import { capitalize } from 'lodash';
import { mount, shallowMount } from '@vue/test-utils';
import PipelineGraph from '~/pipelines/components/graph/graph_component.vue';
import StageColumnComponent from '~/pipelines/components/graph/stage_column_component.vue';
import LinkedPipelinesColumn from '~/pipelines/components/graph/linked_pipelines_column.vue';
import { unwrapPipelineData } from '~/pipelines/components/graph/utils';
import { mockPipelineResponse } from './mock_data';

describe('graph component', () => {

  let wrapper;

  const findLinkedColumns = () => wrapper.findAll(LinkedPipelinesColumn);
  const findStageColumns = () => wrapper.findAll(StageColumnComponent);
  const findStageColumnTitleAt = idx => wrapper.findAll('[data-testid="stage-column-title"]').at(idx);

  const generateResponse = raw => unwrapPipelineData(raw.data.project.pipeline.id, raw.data)

  const defaultProps = {
    pipeline: generateResponse(mockPipelineResponse),
  };

  const createComponent = ({ method = shallowMount, props = {} } = {}) => {
    wrapper = method(PipelineGraph, {
      propsData: {
        ...defaultProps,
        ...props
      }
    })
  }

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('with data', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the main columns in the graph', () => {
      expect(findStageColumns()).toHaveLength(defaultProps.pipeline.stages.length);
    });
  });

  describe('when linked pipelines are not present', () => {
    beforeEach(() => {
      createComponent();
    });

    it('should not render a linked pipelines column', () => {
      expect(findLinkedColumns()).toHaveLength(0);
    });
  });

  describe('capitalizeStageName', () => {
    const firstStage = defaultProps.pipeline.stages[1].name;

    beforeEach(() => {
      const unescapedTitle = `${(firstStage)} &lt;img src=x onerror=alert(document.domain)&gt;`
      const dataCopy = { ...mockPipelineResponse };
      dataCopy.data.project.pipeline.stages.nodes[1].name = unescapedTitle;
      createComponent({ props: generateResponse(dataCopy), method: mount });
    });

    it('capitalizes and escapes stage name', () => {
      expect(findStageColumnTitleAt(1).text()).toEqual(
        capitalize(firstStage),
      );
    });
  });
});
