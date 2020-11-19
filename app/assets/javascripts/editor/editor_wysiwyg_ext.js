import Vue from 'vue';
import { EDITOR_LITE_PANEL_WIDGET_POS } from '~/editor/constants';
import RichEditor from './wysiwyg/rich_editor_ext.vue';

const MARKDOWN_PREVIEW_WIDGET = 'gitlab.markdown.preview.widget';

export default {
  init() {
    const instance = this;

    const panelWidget = {
      domNode: null,
      getId() {
        return MARKDOWN_PREVIEW_WIDGET;
      },
      getDomNode() {
        if (!this.domNode) {
          this.domNode = document.createElement('section');
          const wrapper = document.createElement('div');
          this.domNode.appendChild(wrapper);
        }
        return this.domNode;
      },
      getPosition() {
        return {
          position: EDITOR_LITE_PANEL_WIDGET_POS.left,
          widthIndex: 0.5,
          heightIndex: 1,
        };
      },
    };

    this.addPanelWidget(panelWidget);

    // eslint-disable-next-line no-new
    new Vue({
      el: panelWidget.getDomNode().firstElementChild,
      components: {
        RichEditor,
      },
      provide: {
        instance,
      },
      render(createElement) {
        return createElement('rich-editor');
      },
    });
  },
};
