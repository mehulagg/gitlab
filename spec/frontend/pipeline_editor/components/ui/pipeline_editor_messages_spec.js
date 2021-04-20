import { shallowMount } from '@vue/test-utils';
import { TEST_HOST } from 'helpers/test_constants';
import CodeSnippetAlert from '~/pipeline_editor/components/code_snippet_alert/code_snippet_alert.vue';
import { CODE_SNIPPET_SOURCES } from '~/pipeline_editor/components/code_snippet_alert/constants';
import PipelineEditorMessages from '~/pipeline_editor/components/ui/pipeline_editor_messages.vue';

describe('Pipeline Editor messages', () => {
  let wrapper;

  const createComponent = () => {
    wrapper = shallowMount(PipelineEditorMessages, {});
  };

  const findCodeSnippetAlert = () => wrapper.findComponent(CodeSnippetAlert);

  describe('code snippet alert', () => {
    const setCodeSnippetUrlParam = (value) => {
      global.jsdom.reconfigure({
        url: `${TEST_HOST}/?code_snippet_copied_from=${value}`,
      });
    };

    it('does not show by default', () => {
      createComponent();

      expect(findCodeSnippetAlert().exists()).toBe(false);
    });

    it.each(CODE_SNIPPET_SOURCES)('shows if URL param is %s, and cleans up URL', (source) => {
      jest.spyOn(window.history, 'replaceState');
      setCodeSnippetUrlParam(source);
      createComponent();

      expect(findCodeSnippetAlert().exists()).toBe(true);
      expect(window.history.replaceState).toHaveBeenCalledWith({}, document.title, `${TEST_HOST}/`);
    });

    it('does not show if URL param is invalid', () => {
      setCodeSnippetUrlParam('foo_bar');
      createComponent();

      expect(findCodeSnippetAlert().exists()).toBe(false);
    });

    it('disappears on dismiss', async () => {
      setCodeSnippetUrlParam('api_fuzzing');
      createComponent();
      const alert = findCodeSnippetAlert();

      expect(alert.exists()).toBe(true);

      await alert.vm.$emit('dismiss');

      expect(alert.exists()).toBe(false);
    });
  });
});
