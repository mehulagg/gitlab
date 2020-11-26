import { mount } from '@vue/test-utils';
import stubChildren from 'helpers/stub_children';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import FileIcon from '~/vue_shared/components/file_icon.vue';
import component from '~/packages/details/components/package_files.vue';

import { npmFiles, mavenFiles } from '../../mock_data';

describe('Package Files', () => {
  let wrapper;

  const findAllRows = () => wrapper.findAll('[data-testid="download-link"');
  const findDownloadLink = () => wrapper.find('[data-testid="download-link"');
  const findFileIcon = () => wrapper.find(FileIcon);
  const findCreatedAt = () => wrapper.find(TimeAgoTooltip);

  const createComponent = (packageFiles = npmFiles) => {
    wrapper = mount(component, {
      propsData: {
        packageFiles,
      },
      stubs: {
        ...stubChildren(component),
        GlTable: false,
        GlLink: '<div><slot></slot></div>',
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('rows', () => {
    it('renders a single file for an npm package', () => {
      createComponent();

      expect(findAllRows()).toHaveLength(1);
    });

    it('renders multiple files for a package that contains more than one file', () => {
      createComponent(mavenFiles);

      expect(findAllRows()).toHaveLength(2);
    });
  });

  describe('link', () => {
    it('exist', () => {
      createComponent();

      expect(findDownloadLink().exists()).toBe(true);
    });

    it('has the correct attrs bound', () => {
      createComponent();

      expect(findDownloadLink().attributes('href')).toBe(npmFiles[0].download_path);
    });

    it('on click emits "file-download" event', () => {
      createComponent();

      findDownloadLink().vm.$emit('click');

      expect(wrapper.emitted('file-download')).toEqual([[]]);
    });
  });

  describe('file-icon', () => {
    it('exists', () => {
      createComponent();

      expect(findFileIcon().exists()).toBe(true);
    });

    it('has the correct props bound', () => {
      createComponent();

      expect(findFileIcon().props('fileName')).toBe(npmFiles[0].file_name);
    });
  });

  describe('time-ago tooltip', () => {
    it('exist', () => {
      createComponent();

      expect(findCreatedAt().exists()).toBe(true);
    });

    it('has the correct props bound', () => {
      createComponent();

      expect(findCreatedAt().props('time')).toBe(npmFiles[0].created_at);
    });
  });
});
