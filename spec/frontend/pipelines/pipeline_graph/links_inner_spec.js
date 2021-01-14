import { mount } from '@vue/test-utils';
import LinksInner from '~/pipelines/components/graph_shared/links_inner.vue';
import { pipelineData } from './mock_data';
import { setHTMLFixture } from '../../helpers/fixtures';

describe('Links Inner component', () => {
  const containerId = 'pipeline-graph-container';
  const defaultProps = {
    containerId,
    containerMeasurements: { width: 1019, height: 445 },
    pipelineId: 1,
    pipelineData: [],
  };
  let wrapper;

  const createComponent = (props) => {
    wrapper = mount(LinksInner, {
      propsData: { ...defaultProps, ...props },
    });
  };

  const findLinkSvg = () => wrapper.find('#link-svg');
  // TODO: This file test that the links, given the right data, renders correctly

  // Setup some HTML fixtures and give them the container ID + a size

  // We need to ensure the right number of links are rendered
  // We need to ensure the lines are rendered properly
  // Test multiple data type, like parallel jobs, downstream/upstream
  beforeEach(() => {
    setHTMLFixture(`<div id="${containerId}"></div>`);
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('basic SVG creation', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders an SVG of the right size', () => {
      expect(findLinkSvg().exists()).toBe(true);
      expect(findLinkSvg().attributes('width')).toBe(
        `${defaultProps.containerMeasurements.width}px`,
      );
      expect(findLinkSvg().attributes('height')).toBe(
        `${defaultProps.containerMeasurements.height}px`,
      );
    });
  });

  describe('with no pipeline data', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders the component', () => {
      expect(findLinkSvg().exists()).toBe(true);
    });
  });

  fdescribe('with one need', () => {
    beforeEach(() => {
      createComponent({ pipelineData: pipelineData.stages });
    });

    it('renders one link', () => {
      console.log(document.body.innerHTML);
      console.log(wrapper.html());
      // TODO: Mock getBoundingClientRect to return all the properties we need
    });
  });

  describe('with large data set', () => {
    it('renders the correct link path for each', () => {});

    it('renders the correct link for a parallel job', () => {});

    it('renders the correct link for an upstream job', () => {});

    it('renders the correct link for a downstream job', () => {});
  });

  describe('highlight behaviour', () => {
    it('changes the color of links that are relevant to a job needs', () => {});
  });
});
