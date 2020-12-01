import { GlLink, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import MergeTrainHelperText from 'ee/vue_merge_request_widget/components/merge_train_helper_text.vue';
import { trimText } from 'helpers/text_helper';

describe('MergeTrainHelperText', () => {
  let wrapper;

  const defaultProps = {
    pipelineId: 123,
    pipelineLink: 'path/to/pipeline',
    mergeTrainWhenPipelineSucceedsDocsPath: 'path/to/help',
    mergeTrainLength: 2,
  };

  const findDocumentationLink = () => wrapper.find('[data-testid="documentation-link"]');
  const findPipelineLink = () => wrapper.find('[data-testid="pipeline-link"]');

  const createWrapper = propsData => {
    wrapper = shallowMount(MergeTrainHelperText, {
      propsData: {
        ...defaultProps,
        ...propsData,
      },
      stubs: {
        GlSprintf,
        GlLink,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('should return the "start" version of the message if there is no existing merge train', () => {
    createWrapper({ mergeTrainLength: 0 });

    expect(trimText(wrapper.text())).toBe(
      'This action will start a merge train when pipeline #123 succeeds. More information',
    );
  });

  it('should render the correct pipeline link in the helper text', () => {
    createWrapper();

    const pipelineLink = findPipelineLink();

    expect(pipelineLink.exists()).toBe(true);
    expect(pipelineLink.text()).toContain('#123');
    expect(pipelineLink.attributes('href')).toBe(defaultProps.pipelineLink);
  });

  it('should render the correct documentation link in the helper text', () => {
    createWrapper();

    expect(findDocumentationLink().exists()).toBe(true);
    expect(findDocumentationLink().attributes('href')).toBe(
      defaultProps.mergeTrainWhenPipelineSucceedsDocsPath,
    );
  });
});
