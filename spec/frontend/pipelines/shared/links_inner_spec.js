import { mount, shallowMount } from '@vue/test-utils';
import { DRAW_FAILURE } from '~/pipelines/constants';
import PipelineGraph from '~/pipelines/components/graph/graph_component.vue';
import LinksInner from '~/pipelines/components/graph_shared/links_inner.vue';
import {
  generateResponse,
  mockPipelineResponse,
} from '../graph/mock_data';

import { mockRects } from './mock_data.js'


console.log(Element.prototype.getBoundingClientRect);



describe('links_inner component', () => {

  let wrapper;

  // const findLinkedColumns = () => wrapper.findAll(LinkedPipelinesColumn);
  // const findStageColumns = () => wrapper.findAll(StageColumnComponent);

  const pipeline = generateResponse(mockPipelineResponse, 'root/fungi-xoxo');
  const containerId = `pipeline-links-container-${pipeline.id}`;

  const defaultProps = {
    containerId: containerId,
    containerMeasurements: { width: 400, height: 400 },
    pipelineId: pipeline.id,
    pipelineData: pipeline.stages,
  };

  const createComponent = ({ mountFn = shallowMount, props = {} } = {}) => {
    wrapper = mountFn(LinksInner, {
      propsData: {
        ...defaultProps,
        ...props,
      },
      slots: {
        default: PipelineGraph
      }
    });
  };

  beforeEach(() => {
    jest.spyOn(Element.prototype, 'getBoundingClientRect').mockImplementation(() => {
      // Get random rect value
      return mockRects[Math.floor(Math.random() * mockRects.length)];
    });
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('with error while rendering', () => {
    beforeEach(() => {
      // Fail to fully unwrap to force error
      wrapper = createComponent();
      jest.spyOn(wrapper.vm, '$emit');
      // wrapper = createComponent({ props: { pipelineData: [pipeline] }});
    });

    it('emits the error that link could not be drawn', () => {
      console.log(wrapper.html());
      expect(wrapper.vm.$emit).toHaveBeenCalled();
    });
  });

});

// draws an svg
// renders expected number of links
// link highlights on hover , others fade
