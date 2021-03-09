import { Range } from 'monaco-editor';
import { ERROR_INSTANCE_REQUIRED_FOR_EXTENSION, EDITOR_TYPE_CODE } from '../constants';

export class EditorLiteExtension {
  constructor({ instance, ...options } = {}) {
    if (instance) {
      Object.assign(instance, options);
    } else if (Object.entries(options).length) {
      throw new Error(ERROR_INSTANCE_REQUIRED_FOR_EXTENSION);
    }
    EditorLiteExtension.highlightLines(instance);
    if (instance.getEditorType() === EDITOR_TYPE_CODE) {
      EditorLiteExtension.setupLineLinking(instance);
    }
  }

  static highlightLines(instance) {
    const { hash } = window.location;
    if (!hash) {
      return;
    }
    const [start, end] = hash.replace(/#?L/g, '').split('-');
    const startLine = start ? parseInt(start, 10) : null;
    const endLine = end ? parseInt(end, 10) : startLine;
    if (startLine) {
      window.requestAnimationFrame(() => {
        instance.revealLineInCenter(startLine);
        instance.deltaDecorations(
          [],
          [
            {
              range: new Range(startLine, 1, endLine, 1),
              options: { isWholeLine: true, className: 'active-line-text' },
            },
          ],
        );
      });
    }
  }

  static setupLineLinking(instance) {
    instance.onMouseDown((e) => {
      const target = e.target.element;
      if (target.classList.contains('line-numbers')) {
        const elContent = target.textContent.trim().replace(' ', '-');
        const hrefAttr = `#L${elContent}`;
        let el = target.querySelector(`[href="${hrefAttr}"]`);
        if (!el) {
          el = document.createElement('a');
          el.href = hrefAttr;
        }
        target.appendChild(el).click();
      }
    });
  }
}
