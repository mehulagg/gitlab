import { shallowMount } from '@vue/test-utils';
import PipelineMiniGraph from '~/pipelines/components/pipelines_list/pipeline_mini_graph.vue';
import PipelineStage from '~/pipelines/components/pipelines_list/pipeline_stage.vue';

const { pipelines } = getJSONFixture('pipelines/pipelines.json');

describe('~/pipelines/components/pipelines_list/pipeline_mini.vue', () => {
  let wrapper;

  const [pipeline] = pipelines;

  const findPipelineStages = () => wrapper.findAll(PipelineStage);

  const createComponent = (props = {}) => {
    wrapper = shallowMount(PipelineMiniGraph, {
      propsData: {
        stages: pipeline.details.stages,
        ...props,
      },
    });
  };

  it('renders stages', () => {
    createComponent();

    expect(findPipelineStages()).toHaveLength(pipeline.details.stages.length);
  });

  it('renders stages with a custom class', () => {
    createComponent({ stagesClass: 'my-class' });

    expect(wrapper.findAll('.my-class')).toHaveLength(pipeline.details.stages.length);
  });

  it('does not fail when stages are missing', () => {
    createComponent({ stages: null });

    expect(wrapper.exists()).toBe(true);
    expect(findPipelineStages()).toHaveLength(0);
  });

  it('does not fail when stages are empty', () => {
    createComponent({ stages: [] });

    expect(wrapper.exists()).toBe(true);
    expect(findPipelineStages()).toHaveLength(0);
  });

  it('triggers events in "action request complete" in stages', () => {
    createComponent();

    findPipelineStages().at(0).vm.$emit('pipelineActionRequestComplete');
    findPipelineStages().at(1).vm.$emit('pipelineActionRequestComplete');

    expect(wrapper.emitted('pipelineActionRequestComplete')).toHaveLength(2);
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });
});
