import { shallowMount } from '@vue/test-utils';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';
import TopToolbar from '~/content_editor/components/top_toolbar.vue';

describe('content_editor/components/top_toolbar', () => {
  let wrapper;
  let editor;

  const buildEditor = () => {
    editor = {};
  };

  const buildWrapper = () => {
    wrapper = extendedWrapper(
      shallowMount(TopToolbar, {
        propsData: {
          editor,
        },
      }),
    );
  };

  beforeEach(() => {
    buildEditor();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it.each`
    testId            | buttonProps
    ${'bold'}         | ${{ contentType: 'bold', iconName: 'bold', label: 'Bold text', executeCommand: true }}
    ${'italic'}       | ${{ contentType: 'italic', iconName: 'italic', label: 'Italic text', executeCommand: true }}
    ${'code'}         | ${{ contentType: 'code', iconName: 'code', label: 'Code', executeCommand: true }}
    ${'blockquote'}   | ${{ contentType: 'blockquote', iconName: 'quote', label: 'Insert a quote', executeCommand: true }}
    ${'bullet-list'}  | ${{ contentType: 'bulletList', iconName: 'list-bulleted', label: 'Add a bullet list', executeCommand: true }}
    ${'ordered-list'} | ${{ contentType: 'orderedList', iconName: 'list-numbered', label: 'Add a numbered list', executeCommand: true }}
  `('renders $testId button', ({ testId, buttonProps }) => {
    buildWrapper();
    expect(wrapper.findByTestId(testId).props()).toEqual({
      ...buttonProps,
      editor,
    });
  });
});
