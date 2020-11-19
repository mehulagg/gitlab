import { MarkdownParser } from 'prosemirror-markdown';
import MarkdownIt from 'markdown-it';

export const fromMarkdown = ({ schema, markdown, plugins = [], mappers = {} }) => {
  const markdownit = new MarkdownIt('commonmark');

  plugins.forEach(plugin => markdownit.use(plugin));

  const parser = new MarkdownParser(schema, markdownit, {
    paragraph: { block: 'paragraph' },
    heading: { block: 'heading', getAttrs: tok => ({ level: Number(tok.tag.slice(1)) }) },
    em: { mark: 'em' },
    list_item: { block: 'list_item' },
    bullet_list: { block: 'bullet_list' },
    ordered_list: {
      block: 'ordered_list',
      getAttrs: tok => ({ order: Number(tok.attrGet('start')) || 1 }),
    },
    strong: { mark: 'strong' },
    ...mappers,
  });

  return parser.parse(markdown).toJSON();
};
