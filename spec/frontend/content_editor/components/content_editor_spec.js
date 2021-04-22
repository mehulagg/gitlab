import { EditorContent } from '@tiptap/vue-2';
import { shallowMount } from '@vue/test-utils';
import ContentEditor from '~/content_editor/components/content_editor.vue';
import TopToolbar from '~/content_editor/components/top_toolbar.vue';
import createEditor from '~/content_editor/services/create_editor';

describe('ContentEditor', () => {
  let wrapper;
  let editor;

  const createWrapper = async (_editor) => {
    wrapper = shallowMount(ContentEditor, {
      propsData: {
        editor: _editor,
      },
    });
  };

  beforeEach(async () => {
    editor = await createEditor({ renderMarkdown: () => 'sample text' });
    createWrapper(editor);
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders editor content component and attaches editor instance', async () => {
    expect(wrapper.findComponent(EditorContent).props().editor).toBe(editor);
  });

  it('renders top toolbar component and attaches editor instance', async () => {
    expect(wrapper.findComponent(TopToolbar).props().editor).toBe(editor);
  });
});
