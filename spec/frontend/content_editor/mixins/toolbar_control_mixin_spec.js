import { shallowMount } from '@vue/test-utils';
import { nextTick } from 'vue';
import toolbarControlMixin from '~/content_editor/mixins/toolbar_control_mixin';
import { createTestEditor } from '../test_utils';

describe('content_editor/mixins/toolbar_control_mixin', () => {
  let tiptapEditor;
  let wrapper;

  const buildEditor = () => {
    tiptapEditor = createTestEditor();
  };

  const buildWrapper = () => {
    wrapper = shallowMount(
      {
        mixins: [toolbarControlMixin],
        data() {
          return {
            editorContent: null,
            editorSelection: null,
          };
        },
        onTiptapDocUpdate({ editor }) {
          this.editorContent = editor.getHTML();
        },
        onTiptapSelectionUpdate({ editor }) {
          this.editorSelection = editor.state.selection.from;
        },
        template: `
        <div>
          <span v-html="editorContent"></span>
          <span>{{ editorSelection }}</span>
        </div>
        `,
      },
      {
        provide: { tiptapEditor },
      },
    );
  };

  beforeEach(() => {
    buildEditor();
    buildWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when editor content changes', () => {
    it('onTiptapDocUpdate event hook is invoked', async () => {
      const content = '<p>My paragraph</p>';

      tiptapEditor.commands.insertContent(content);

      await nextTick();

      expect(wrapper.html()).toContain(content);
    });
  });

  describe('when editor selection changes', () => {
    it('onTiptapSelectionUpdate event hook is invoked', async () => {
      const content = '<p>My paragraph</p>';

      tiptapEditor.commands.insertContent(content);

      await nextTick();

      expect(wrapper.text()).toContain(tiptapEditor.state.selection.from);
    });
  });

  describe('when component is destroyed', () => {
    it('removes onTiptapDocUpdate and onTiptapSelectionUpdate hooks', () => {
      jest.spyOn(tiptapEditor, 'off');

      wrapper.destroy();

      expect(tiptapEditor.off).toHaveBeenCalledWith('update', wrapper.vm.docUpdateHandler);
      expect(tiptapEditor.off).toHaveBeenCalledWith(
        'selectionUpdate',
        wrapper.vm.selectionUpdateHandler,
      );
    });
  });
});
