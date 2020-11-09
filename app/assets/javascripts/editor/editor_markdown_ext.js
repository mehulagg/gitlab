import { debounce } from 'lodash';
import { __ } from '~/locale';
import axios from '~/lib/utils/axios_utils';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import { EDITOR_LITE_PANEL_WIDGET_POS } from '~/editor/constants';

const MARKDOWN_PREVIEW_WIDGET = "'gitlab.markdown.preview.widget";
const MARKDOWN_PREVIEW_ERROR = __('An error occurred previewing the file');

const getPreview = editor => {
  const url = window.location.href.replace('edit', 'preview');
  return axios
    .post(url, {
      content: editor.getValue(),
    })
    .then(({ data }) => {
      return data;
    });
};

export default {
  init() {
    this.addAction({
      id: 'markdown-preview',
      label: __('Toggle Preview'),
      keybindings: [
        // eslint-disable-next-line no-bitwise,no-undef
        monaco.KeyMod.chord(monaco.KeyMod.CtrlCmd | monaco.KeyCode.KEY_K, monaco.KeyCode.KEY_V),
      ],
      contextMenuGroupId: 'navigation',
      contextMenuOrder: 1.5,

      // Method that will be executed when the action is triggered.
      // @param editor The editor instance is passed in as a convinience
      run(ed) {
        const panelWidget = {
          domNode: null,
          getId() {
            return MARKDOWN_PREVIEW_WIDGET;
          },
          getDomNode() {
            if (!this.domNode) {
              this.domNode = document.createElement('section');
            }
            return this.domNode;
          },
          getPosition() {
            return {
              position: EDITOR_LITE_PANEL_WIDGET_POS.right,
              widthIndex: 0.5,
              heightIndex: 1,
            };
          },
        };
        const fetchPreview = () => {
          getPreview(ed)
            .then(data => {
              panelWidget.getDomNode().innerHTML = data;
            })
            .catch(() => createFlash(MARKDOWN_PREVIEW_ERROR));
        };

        if (Object.keys(ed.panelWidgets).indexOf(MARKDOWN_PREVIEW_WIDGET) !== -1) {
          ed.removePanelWidget(panelWidget);
          ed.disposeDisposableEvent(MARKDOWN_PREVIEW_WIDGET);
        } else {
          fetchPreview();
          ed.addListenerAndStoreDisposable(
            MARKDOWN_PREVIEW_WIDGET,
            debounce(fetchPreview.bind(this), 250),
          );

          ed.addPanelWidget(panelWidget);
        }
      },
    });
  },
  getSelectedText(selection = this.getSelection()) {
    const { startLineNumber, endLineNumber, startColumn, endColumn } = selection;
    const valArray = this.getValue().split('\n');
    let text = '';
    if (startLineNumber === endLineNumber) {
      text = valArray[startLineNumber - 1].slice(startColumn - 1, endColumn - 1);
    } else {
      const startLineText = valArray[startLineNumber - 1].slice(startColumn - 1);
      const endLineText = valArray[endLineNumber - 1].slice(0, endColumn - 1);

      for (let i = startLineNumber, k = endLineNumber - 1; i < k; i += 1) {
        text += `${valArray[i]}`;
        if (i !== k - 1) text += `\n`;
      }
      text = text
        ? [startLineText, text, endLineText].join('\n')
        : [startLineText, endLineText].join('\n');
    }
    return text;
  },

  replaceSelectedText(text, select = undefined) {
    const forceMoveMarkers = !select;
    this.executeEdits('', [{ range: this.getSelection(), text, forceMoveMarkers }]);
  },

  moveCursor(dx = 0, dy = 0) {
    const pos = this.getPosition();
    pos.column += dx;
    pos.lineNumber += dy;
    this.setPosition(pos);
  },

  /**
   * Adjust existing selection to select text within the original selection.
   * - If `selectedText` is not supplied, we fetch selected text with
   *
   * ALGORITHM:
   *
   * MULTI-LINE SELECTION
   * 1. Find line that contains `toSelect` text.
   * 2. Using the index of this line and the position of `toSelect` text in it,
   * construct:
   *   * newStartLineNumber
   *   * newStartColumn
   *
   * SINGLE-LINE SELECTION
   * 1. Use `startLineNumber` from the current selection as `newStartLineNumber`
   * 2. Find the position of `toSelect` text in it to get `newStartColumn`
   *
   * 3. `newEndLineNumber` — Since this method is supposed to be used with
   * markdown decorators that are pretty short, the `newEndLineNumber` is
   * suggested to be assumed the same as the startLine.
   * 4. `newEndColumn` — pretty obvious
   * 5. Adjust the start and end positions of the current selection
   * 6. Re-set selection on the instance
   *
   * @param {string} toSelect - New text to select within current selection.
   * @param {string} selectedText - Currently selected text. It's just a
   * shortcut: If it's not supplied, we fetch selected text from the instance
   */
  selectWithinSelection(toSelect, selectedText) {
    const currentSelection = this.getSelection();
    if (currentSelection.isEmpty() || !toSelect) {
      return;
    }
    const text = selectedText || this.getSelectedText(currentSelection);
    let lineShift;
    let newStartLineNumber;
    let newStartColumn;

    const textLines = text.split('\n');

    if (textLines.length > 1) {
      // Multi-line selection
      lineShift = textLines.findIndex(line => line.indexOf(toSelect) !== -1);
      newStartLineNumber = currentSelection.startLineNumber + lineShift;
      newStartColumn = textLines[lineShift].indexOf(toSelect) + 1;
    } else {
      // Single-line selection
      newStartLineNumber = currentSelection.startLineNumber;
      newStartColumn = currentSelection.startColumn + text.indexOf(toSelect);
    }

    const newEndLineNumber = newStartLineNumber;
    const newEndColumn = newStartColumn + toSelect.length;

    const newSelection = currentSelection
      .setStartPosition(newStartLineNumber, newStartColumn)
      .setEndPosition(newEndLineNumber, newEndColumn);

    this.setSelection(newSelection);
  },
};
