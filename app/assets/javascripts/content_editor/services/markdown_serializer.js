import { MarkdownSerializer as ProseMirrorMarkdownSerializer } from 'prosemirror-markdown/src/to_markdown';
import { DOMParser as ProseMirrorDOMParser } from 'prosemirror-model';

const wrapHtmlPayload = (payload) => `<div>${payload}</div>`;

/**
 * A markdown serializer converts arbitrary Markdown content
 * into a ProseMirror document and viceversa. To convert Markdown
 * into a ProseMirror document, the Markdown should be rendered.
 *
 * The client should provide a render function to allow flexibility
 * on the desired rendering approach.
 *
 * @param {Function} params.render Render function
 * that parses the Markdown and converts it into HTML.
 * @returns a markdown serializer
 */
export default ({ render = () => null }) => ({
  /**
   * Converts a Markdown string into a ProseMirror JSONDocument based
   * on a ProseMirror schema.
   * @param {ProseMirror.Schema} params.schema A ProseMirror schema that defines
   * the types of content supported in the document
   * @param {String} params.content An arbitrary markdown string
   * @returns A ProseMirror JSONDocument
   */
  deserialize: async ({ schema, content }) => {
    const html = await render(content);

    if (!html) {
      return null;
    }

    const parser = new DOMParser();
    const {
      body: { firstElementChild },
    } = parser.parseFromString(wrapHtmlPayload(html), 'text/html');
    const state = ProseMirrorDOMParser.fromSchema(schema).parse(firstElementChild);

    return state.toJSON();
  },

  /**
   * Converts a ProseMirror JSONDocument based
   * on a ProseMirror schema into Markdown
   * @param {ProseMirror.Schema} params.schema A ProseMirror schema that defines
   * the types of content supported in the document
   * @param {String} params.content A ProseMirror JSONDocument
   * @returns A Markdown string
   */
  serialize: ({ serializerSpec: { nodes, marks }, schema, content }) => {
    const document = schema.nodeFromJSON(content);
    const serializer = new ProseMirrorMarkdownSerializer(nodes, marks);

    return serializer.serialize(document, {
      tightLists: true,
    });
  },
});
