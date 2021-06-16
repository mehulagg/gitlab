import { Link } from '@tiptap/extension-link';

export const tiptapExtension = Link.extend({
  addAttributes() {
    return {
      ...this.parent?.(),
      href: {
        default: null,
        parseHTML: (element) => {
          return {
            href: element.dataset.originalUrl || element.getAttribute('href'),
          };
        },
      },
      'data-original-url': {
        default: null,
        parseHTML: (element) => {
          return {
            href: element.dataset.originalUrl,
          };
        },
      },
    };
  },
}).configure({
  openOnClick: false,
});

export const serializer = {
  open() {
    return '[';
  },
  close(state, mark) {
    const href = mark.attrs['data-original-url'] || mark.attrs.href;
    return `](${state.esc(href)}${mark.attrs.title ? ` ${state.quote(mark.attrs.title)}` : ''})`;
  },
};
