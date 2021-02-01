import { shallowMount } from '@vue/test-utils';
import { GlAlert } from '@gitlab/ui';

import { mockCiYml, mockCiConfigPath } from '../../mock_data';
import { EDITOR_READY_EVENT } from '~/editor/constants';
import CiConfigMergedPreview from '~/pipeline_editor/components/editor/ci_config_merged_preview.vue';

describe('Text editor component', () => {
  let wrapper;

  const MockEditorLite = {
    template: '<div/>',
    props: ['value', 'fileName', 'editorOptions'],
    mounted() {
      this.$emit(EDITOR_READY_EVENT);
    },
  };

  const createComponent = () => {
    wrapper = shallowMount(CiConfigMergedPreview, {
      provide: {
        ciConfigPath: mockCiConfigPath,
      },
      attrs: {
        value: mockCiYml,
      },
      stubs: {
        EditorLite: MockEditorLite,
      },
    });
  };

  const findAlert = () => wrapper.find(GlAlert);
  const findEditor = () => wrapper.find(MockEditorLite);

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('template', () => {
    beforeEach(() => {
      createComponent();
    });

    it('shows an information message that the section is not editable', () => {
      expect(findAlert().exists()).toBe(true);
      expect(findAlert().text()).toBe(wrapper.vm.$options.i18n.viewOnlyMessage);
    });

    it('contains an editor', () => {
      expect(findEditor().exists()).toBe(true);
    });

    it('editor contains the value provided', () => {
      expect(findEditor().props('value')).toBe(mockCiYml);
    });

    it('editor is configured for the CI config path', () => {
      expect(findEditor().props('fileName')).toBe(mockCiConfigPath);
    });

    it('editor is readonly', () => {
      expect(findEditor().props('editorOptions')).toMatchObject({
        readOnly: true,
      });
    });
  });
});
