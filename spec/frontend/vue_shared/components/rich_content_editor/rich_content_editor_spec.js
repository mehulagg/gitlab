import { shallowMount } from '@vue/test-utils';
import RichContentEditor from '~/vue_shared/components/rich_content_editor/rich_content_editor.vue';
import AddImageModal from '~/vue_shared/components/rich_content_editor/modals/add_image/add_image_modal.vue';
import InsertVideoModal from '~/vue_shared/components/rich_content_editor/modals/insert_video_modal.vue';
import {
  EDITOR_TYPES,
  EDITOR_HEIGHT,
  EDITOR_PREVIEW_STYLE,
  CUSTOM_EVENTS,
} from '~/vue_shared/components/rich_content_editor/constants';

import {
  addCustomEventListener,
  removeCustomEventListener,
  addImage,
  insertVideo,
  registerHTMLToMarkdownRenderer,
  getEditorOptions,
} from '~/vue_shared/components/rich_content_editor/services/editor_service';

jest.mock('~/vue_shared/components/rich_content_editor/services/editor_service', () => ({
  ...jest.requireActual('~/vue_shared/components/rich_content_editor/services/editor_service'),
  addCustomEventListener: jest.fn(),
  removeCustomEventListener: jest.fn(),
  addImage: jest.fn(),
  insertVideo: jest.fn(),
  registerHTMLToMarkdownRenderer: jest.fn(),
  getEditorOptions: jest.fn(),
}));

describe('Rich Content Editor', () => {
  let wrapper;

  const content = '## Some Markdown';
  const imageRoot = 'path/to/root/';
  const findEditor = () => wrapper.find({ ref: 'editor' });
  const findAddImageModal = () => wrapper.find(AddImageModal);
  const findInsertVideoModal = () => wrapper.find(InsertVideoModal);

  const buildWrapper = () => {
    wrapper = shallowMount(RichContentEditor, {
      propsData: { content, imageRoot },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when content is loaded', () => {
    const editorOptions = {};

    beforeEach(() => {
      getEditorOptions.mockReturnValueOnce(editorOptions);
      buildWrapper();
    });

    it('renders an editor', () => {
      expect(findEditor().exists()).toBe(true);
    });

    it('renders the correct content', () => {
      expect(findEditor().props().initialValue).toBe(content);
    });

    it('provides options generated by the getEditorOptions service', () => {
      expect(findEditor().props().options).toBe(editorOptions);
    });

    it('has the correct preview style', () => {
      expect(findEditor().props().previewStyle).toBe(EDITOR_PREVIEW_STYLE);
    });

    it('has the correct initial edit type', () => {
      expect(findEditor().props().initialEditType).toBe(EDITOR_TYPES.wysiwyg);
    });

    it('has the correct height', () => {
      expect(findEditor().props().height).toBe(EDITOR_HEIGHT);
    });
  });

  describe('when content is changed', () => {
    beforeEach(() => {
      buildWrapper();
    });

    it('emits an input event with the changed content', () => {
      const changedMarkdown = '## Changed Markdown';
      const getMarkdownMock = jest.fn().mockReturnValueOnce(changedMarkdown);

      findEditor().setMethods({ invoke: getMarkdownMock });
      findEditor().vm.$emit('change');

      expect(wrapper.emitted().input[0][0]).toBe(changedMarkdown);
    });
  });

  describe('when content is reset', () => {
    beforeEach(() => {
      buildWrapper();
    });

    it('should reset the content via setMarkdown', () => {
      const newContent = 'Just the body content excluding the front matter for example';
      const mockInstance = { invoke: jest.fn() };
      wrapper.vm.$refs.editor = mockInstance;

      wrapper.vm.resetInitialValue(newContent);

      expect(mockInstance.invoke).toHaveBeenCalledWith('setMarkdown', newContent);
    });
  });

  describe('when editor is loaded', () => {
    beforeEach(() => {
      buildWrapper();
    });

    it('adds the CUSTOM_EVENTS.openAddImageModal custom event listener', () => {
      expect(addCustomEventListener).toHaveBeenCalledWith(
        wrapper.vm.editorApi,
        CUSTOM_EVENTS.openAddImageModal,
        wrapper.vm.onOpenAddImageModal,
      );
    });

    it('adds the CUSTOM_EVENTS.openInsertVideoModal custom event listener', () => {
      expect(addCustomEventListener).toHaveBeenCalledWith(
        wrapper.vm.editorApi,
        CUSTOM_EVENTS.openInsertVideoModal,
        wrapper.vm.onOpenInsertVideoModal,
      );
    });

    it('registers HTML to markdown renderer', () => {
      expect(registerHTMLToMarkdownRenderer).toHaveBeenCalledWith(wrapper.vm.editorApi);
    });
  });

  describe('when editor is destroyed', () => {
    beforeEach(() => {
      buildWrapper();
    });

    it('removes the CUSTOM_EVENTS.openAddImageModal custom event listener', () => {
      wrapper.vm.$destroy();

      expect(removeCustomEventListener).toHaveBeenCalledWith(
        wrapper.vm.editorApi,
        CUSTOM_EVENTS.openAddImageModal,
        wrapper.vm.onOpenAddImageModal,
      );
    });

    it('removes the CUSTOM_EVENTS.openInsertVideoModal custom event listener', () => {
      wrapper.vm.$destroy();

      expect(removeCustomEventListener).toHaveBeenCalledWith(
        wrapper.vm.editorApi,
        CUSTOM_EVENTS.openInsertVideoModal,
        wrapper.vm.onOpenInsertVideoModal,
      );
    });
  });

  describe('add image modal', () => {
    beforeEach(() => {
      buildWrapper();
    });

    it('renders an addImageModal component', () => {
      expect(findAddImageModal().exists()).toBe(true);
    });

    it('calls the onAddImage method when the addImage event is emitted', () => {
      const mockImage = { imageUrl: 'some/url.png', altText: 'some description' };
      const mockInstance = { exec: jest.fn() };
      wrapper.vm.$refs.editor = mockInstance;

      findAddImageModal().vm.$emit('addImage', mockImage);
      expect(addImage).toHaveBeenCalledWith(mockInstance, mockImage);
    });
  });

  describe('insert video modal', () => {
    beforeEach(() => {
      buildWrapper();
    });

    it('renders an insertVideoModal component', () => {
      expect(findInsertVideoModal().exists()).toBe(true);
    });

    it('calls the onInsertVideo method when the insertVideo event is emitted', () => {
      const mockUrl = 'https://www.youtube.com/embed/someId';
      const mockInstance = { exec: jest.fn() };
      wrapper.vm.$refs.editor = mockInstance;

      findInsertVideoModal().vm.$emit('insertVideo', mockUrl);
      expect(insertVideo).toHaveBeenCalledWith(mockInstance, mockUrl);
    });
  });
});
