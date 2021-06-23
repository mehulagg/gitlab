import { shallowMount } from '@vue/test-utils';
import BlobButtonGroup from '~/repository/components/blob_button_group.vue';
import UploadBlobModal from '~/repository/components/upload_blob_modal.vue';

const DEFAULT_PROPS = {
  name: 'some name',
  path: 'some/path',
  canPushCode: true,
  replacePath: 'some/replace/path',
};

const DEFAULT_INJECT = {
  targetBranch: 'master',
  originalBranch: 'master',
};

describe('BlobButtonGroup component', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = shallowMount(BlobButtonGroup, {
      propsData: {
        ...DEFAULT_PROPS,
        ...props,
      },
      provide: {
        ...DEFAULT_INJECT,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  const findUploadBlobModal = () => wrapper.findComponent(UploadBlobModal);

  it('renders component', () => {
    createComponent();

    const { name, path } = DEFAULT_PROPS;

    expect(wrapper.props()).toMatchObject({
      name,
      path,
    });
  });

  it('renders UploadBlobModal', () => {
    createComponent();

    const { targetBranch, originalBranch } = DEFAULT_INJECT;
    const { name, path, canPushCode, replacePath } = DEFAULT_PROPS;
    const title = `Replace ${name}`;

    expect(findUploadBlobModal().props()).toMatchObject({
      modalTitle: title,
      commitMessage: title,
      targetBranch,
      originalBranch,
      canPushCode,
      path,
      replacePath,
      primaryBtnText: 'Replace file',
    });
  });
});
