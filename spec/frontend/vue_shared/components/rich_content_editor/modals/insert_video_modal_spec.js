import { shallowMount } from '@vue/test-utils';
import { GlModal } from '@gitlab/ui';
import InsertVideoModal from '~/vue_shared/components/rich_content_editor/modals/insert_video_modal.vue';

describe('Insert Video Modal', () => {
  let wrapper;

  const findModal = () => wrapper.find(GlModal);
  const findUrlInput = () => wrapper.find({ ref: 'urlInput' });

  beforeEach(() => {
    wrapper = shallowMount(InsertVideoModal, {
      provide: { glFeatures: { sseImageUploads: true } }
    });
  });

  describe('when content is loaded', () => {
    it('renders a modal component', () => {
      expect(findModal().exists()).toBe(true);
    });

    it('renders an input to add a URL', () => {
      expect(findUrlInput().exists()).toBe(true);
    });
  });

  describe('insert video', () => {
    it('emits an insertVideo event when a valid URL is specified', () => {
      const preventDefault = jest.fn();
      const mockImage = { url: '/some/valid/url' };
      wrapper.setData({ ...mockImage });

      findModal().vm.$emit('ok', { preventDefault });
      expect(preventDefault).not.toHaveBeenCalled();
      expect(wrapper.emitted('insertVideo')).toEqual([
        [{ url: mockImage.url }],
      ]);
    });
  });
});
