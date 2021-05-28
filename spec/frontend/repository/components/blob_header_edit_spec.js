import { GlButton } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import BlobHeaderEdit from '~/repository/components/blob_header_edit.vue';
import WebIdeLink from '~/vue_shared/components/web_ide_link.vue';

const DEFAULT_PROPS = {
  editPath: 'some_file.js/edit',
  webIdePath: 'some_file.js/ide/edit',
};

describe('BlobHeaderEdit component', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = shallowMount(BlobHeaderEdit, {
      propsData: {
        ...DEFAULT_PROPS,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const findButtons = () => wrapper.findAll(GlButton);
  const findEditButton = () => wrapper.findAll(GlButton).at(0);
  const findWebIdeButton = () => wrapper.findAll(GlButton).at(1);
  const findWebIdeLink = () => wrapper.find(WebIdeLink);

  it('renders component', () => {
    createComponent();

    const { editPath, webIdePath } = DEFAULT_PROPS;

    expect(wrapper.props()).toMatchObject({
      editPath,
      webIdePath,
    });
  });

  it('renders both buttons', () => {
    createComponent();

    expect(findButtons()).toHaveLength(2);
  });

  it('renders the Edit button', () => {
    createComponent();

    expect(findEditButton().attributes('href')).toBe(DEFAULT_PROPS.editPath);
    expect(findEditButton().text()).toBe('Edit');
  });

  it('renders the Web IDE button', () => {
    createComponent();

    expect(findWebIdeButton().attributes('href')).toBe(DEFAULT_PROPS.webIdePath);
    expect(findWebIdeButton().text()).toBe('Web IDE');
  });

  it('renders WebIdeLink component', () => {
    window.gon.features = {
      consolidatedEditButton: true,
    };

    createComponent();

    const { editPath: editUrl, webIdePath: webIdeUrl } = DEFAULT_PROPS;

    expect(findWebIdeLink().props()).toMatchObject({
      editUrl,
      webIdeUrl,
      isBlob: true,
    });
  });
});
