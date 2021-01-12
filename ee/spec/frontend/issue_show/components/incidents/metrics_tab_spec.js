import Vuex from 'vuex';
import { createLocalVue, shallowMount } from '@vue/test-utils';
import merge from 'lodash/merge';
import { GlFormInput, GlModal } from '@gitlab/ui';
import waitForPromises from 'helpers/wait_for_promises';
import MetricsTab from 'ee/issue_show/components/incidents/metrics_tab.vue';
import MetricsImage from 'ee/issue_show/components/incidents/metrics_image.vue';
import createStore from 'ee/issue_show/components/incidents/store';
import { getMetricImages } from 'ee/issue_show/components/incidents/service';
import UploadDropzone from '~/vue_shared/components/upload_dropzone/upload_dropzone.vue';
import { fileList, initialData } from './mock_data';

jest.mock('ee/issue_show/components/incidents/service', () => ({
  getMetricImages: jest.fn(),
}));

const mockEvent = { preventDefault: jest.fn() };

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Metrics tab', () => {
  let wrapper;
  let store;

  const mountComponent = (options = {}) => {
    store = createStore();

    wrapper = shallowMount(
      MetricsTab,
      merge(
        {
          localVue,
          store,
          provide: {
            canUpdate: true,
            iid: initialData.issueIid,
            projectId: initialData.projectId,
          },
        },
        options,
      ),
    );
  };

  beforeEach(() => {
    mountComponent();
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  const findUploadDropzone = () => wrapper.find(UploadDropzone);
  const findImages = () => wrapper.findAll(MetricsImage);
  const findModal = () => wrapper.find(GlModal);
  const submitModal = () => findModal().vm.$emit('primary', mockEvent);
  const cancelModal = () => findModal().vm.$emit('canceled');

  describe('empty state', () => {
    beforeEach(() => {
      mountComponent();
    });

    it('renders the upload component', () => {
      expect(findUploadDropzone().exists()).toBe(true);
    });
  });

  describe('permissions', () => {
    beforeEach(() => {
      mountComponent({ provide: { canUpdate: false } });
    });

    it('hides the upload component when disallowed', () => {
      expect(findUploadDropzone().exists()).toBe(false);
    });
  });

  describe('onLoad action', () => {
    it('should load images', async () => {
      getMetricImages.mockImplementation(() => Promise.resolve(fileList));

      mountComponent();

      await waitForPromises();

      expect(findImages().length).toBe(1);
    });
  });

  describe('add metric dialog', () => {
    const testUrl = 'test url';

    it('should open the add metric dialog when clicked', async () => {
      mountComponent();

      findUploadDropzone().vm.$emit('change');

      await waitForPromises();

      expect(findModal().attributes('visible')).toBe('true');
    });

    it('should close when cancelled', async () => {
      mountComponent({
        data() {
          return { modalVisible: true };
        },
      });

      cancelModal();

      await waitForPromises();

      expect(findModal().attributes('visible')).toBeFalsy();
    });

    it('should add files and url when selected', async () => {
      mountComponent({
        data() {
          return { modalVisible: true, modalUrl: testUrl, currentFiles: fileList };
        },
      });

      const dispatchSpy = jest.spyOn(store, 'dispatch');

      submitModal();

      await waitForPromises();

      expect(dispatchSpy).toHaveBeenCalledWith('uploadImage', { files: fileList, url: testUrl });
    });

    describe('url field', () => {
      beforeEach(() => {
        mountComponent({
          data() {
            return { modalVisible: true, modalUrl: testUrl };
          },
        });
      });

      it('should display the url field', () => {
        expect(wrapper.find(GlFormInput).attributes('value')).toBe(testUrl);
      });

      it('should clear url when cancelled', async () => {
        cancelModal();

        await waitForPromises();

        expect(wrapper.find(GlFormInput).attributes('value')).toBe('');
      });

      it('should clear url when submitted', async () => {
        submitModal();

        await waitForPromises();

        expect(wrapper.find(GlFormInput).attributes('value')).toBe('');
      });
    });
  });
});
