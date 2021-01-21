import { mount } from '@vue/test-utils';
import LinkedPipelinesMiniList from 'ee/vue_shared/components/linked_pipelines_mini_list.vue';
import mockData from 'ee_jest/vue_mr_widget/mock_data';
import { trimText } from 'helpers/text_helper';
import pipelineComponent from '~/vue_merge_request_widget/components/mr_widget_pipeline.vue';
import mockLinkedPipelines from '../vue_shared/components/linked_pipelines_mock_data';

describe('MRWidgetPipeline', () => {
  let wrapper;

  const findPipelineInfoContainer = () => wrapper.find('[data-testid="pipeline-info-container"');
  const findPipelinesMiniList = () => wrapper.find(LinkedPipelinesMiniList);

  function createComponent(pipeline) {
    wrapper = mount(pipelineComponent, {
      propsData: {
        pipeline,
        pipelineCoverageDelta: undefined,
        hasCi: true,
        ciStatus: 'success',
        sourceBranchLink: undefined,
        sourceBranch: undefined,
        mrTroubleshootingDocsPath: 'help',
        ciTroubleshootingDocsPath: 'help2',
      },
    });
  }

  afterEach(() => {
    wrapper.destroy();
  });

  describe('for each type of pipeline', () => {
    let pipeline;

    beforeEach(() => {
      ({ pipeline } = JSON.parse(JSON.stringify(mockData)));

      pipeline.ref.tag = false;
      pipeline.ref.branch = false;
    });

    describe('for a merge train pipeline', () => {
      it('renders a pipeline widget that reads "Merge train pipeline <ID> <status> for <SHA>"', () => {
        pipeline.details.name = 'Merge train pipeline';
        pipeline.merge_request_event_type = 'merge_train';

        createComponent(pipeline);

        const expected = `Merge train pipeline #${pipeline.id} ${pipeline.details.status.label} for ${pipeline.commit.short_id}`;
        const actual = trimText(findPipelineInfoContainer().text());

        expect(actual).toBe(expected);
      });
    });

    describe('for a merged result pipeline', () => {
      it('renders a pipeline widget that reads "Merged result pipeline <ID> <status> for <SHA>"', () => {
        pipeline.details.name = 'Merged result pipeline';
        pipeline.merge_request_event_type = 'merged_result';

        createComponent(pipeline);

        const expected = `Merged result pipeline #${pipeline.id} ${pipeline.details.status.label} for ${pipeline.commit.short_id}`;
        const actual = trimText(findPipelineInfoContainer().text());

        expect(actual).toBe(expected);
      });
    });
  });

  describe('pipeline graph', () => {
    describe('when upstream pipelines are passed', () => {
      beforeEach(() => {
        const pipeline = { ...mockData.pipeline, triggered_by: mockLinkedPipelines.triggered_by };

        createComponent(pipeline);
      });

      it('should render the linked pipelines mini list', () => {
        expect(findPipelinesMiniList().exists()).toBe(true);
      });

      it('should render the linked pipelines mini list as an upstream list', () => {
        expect(findPipelinesMiniList().classes('is-upstream')).toBe(true);
      });

      it('should add a single triggeredBy into an array', () => {
        const triggeredBy = findPipelinesMiniList().props('triggeredBy');

        expect(triggeredBy).toEqual(expect.any(Array));
        expect(triggeredBy).toHaveLength(1);
        expect(triggeredBy[0]).toBe(mockLinkedPipelines.triggered_by);
      });
    });

    describe('when downstream pipelines are passed', () => {
      beforeEach(() => {
        const pipeline = { ...mockData.pipeline, triggered: mockLinkedPipelines.triggered };

        createComponent(pipeline);
      });

      it('should render the linked pipelines mini list', () => {
        expect(findPipelinesMiniList().exists()).toBe(true);
      });

      it('should render the linked pipelines mini list as a downstream list', () => {
        expect(findPipelinesMiniList().classes('is-downstream')).toBe(true);
      });

      it('should pass the triggered pipelines', () => {
        const triggered = findPipelinesMiniList().props('triggered');

        expect(triggered).toBe(mockLinkedPipelines.triggered);
      });
    });
  });
});
