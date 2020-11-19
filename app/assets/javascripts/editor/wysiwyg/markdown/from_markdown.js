import { MarkdownParser } from 'prosemirror-markdown';
import MarkdownIt from 'markdown-it';

export const fromMarkdown = ({ schema, markdown, plugins = [], mappers = {} }) => {
  const markdownit = new MarkdownIt('commonmark');

  plugins.forEach(plugin => markdownit.use(plugin));

  const parser = new MarkdownParser(schema, markdownit, {
    blockquote: {block: "blockquote"},
    paragraph: {block: "paragraph"},
    list_item: {block: "list_item"},
    bullet_list: {block: "bullet_list"},
    ordered_list: {block: "ordered_list", getAttrs: tok => ({order: +tok.attrGet("start") || 1})},
    heading: {block: "heading", getAttrs: tok => ({level: +tok.tag.slice(1)})},
    code_block: {block: "code_block", noCloseToken: true},
    fence: {block: "code_block", getAttrs: tok => ({params: tok.info || ""}), noCloseToken: true},
    hr: {node: "horizontal_rule"},
    image: {node: "image", getAttrs: tok => ({
        src: tok.attrGet("src"),
        title: tok.attrGet("title") || null,
        alt: tok.children[0] && tok.children[0].content || null
      })},
    hardbreak: {node: "hard_break"},

    em: {mark: "em"},
    strong: {mark: "strong"},
    link: {mark: "link", getAttrs: tok => ({
        href: tok.attrGet("href"),
        title: tok.attrGet("title") || null
      })},
    code_inline: {mark: "code", noCloseToken: true},
    ...mappers,
  });

  return parser.parse(markdown).toJSON();
};
