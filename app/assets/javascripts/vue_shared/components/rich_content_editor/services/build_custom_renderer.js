import renderBlockHtml from './renderers/render_html_block';
import renderKramdownList from './renderers/render_kramdown_list';
import renderKramdownText from './renderers/render_kramdown_text';
import renderIdentifierInstanceText from './renderers/render_identifier_instance_text';
import renderIdentifierParagraph from './renderers/render_identifier_paragraph';
import renderEmbeddedRubyText from './renderers/render_embedded_ruby_text';
import renderFontAwesomeHtmlInline from './renderers/render_font_awesome_html_inline';
import renderSoftbreak from './renderers/render_softbreak';

const htmlInlineRenderers = [renderFontAwesomeHtmlInline];
const htmlBlockRenderers = [renderBlockHtml];
const listRenderers = [renderKramdownList];
const paragraphRenderers = [renderIdentifierParagraph, renderEmbeddedRubyText];
const textRenderers = [renderKramdownText, renderIdentifierInstanceText];
const softbreakRenderers = [renderSoftbreak];

const executeRenderer = (renderers, node, context) => {
  const availableRenderer = renderers.find(renderer => renderer.canRender(node, context));

  return availableRenderer ? availableRenderer.render(node, context) : context.origin();
};

const buildCustomRendererFunctions = (customRenderers, defaults) => {
  const customTypes = Object.keys(customRenderers).filter(type => !defaults[type]);
  const customEntries = customTypes.map(type => {
    const fn = (node, context) => executeRenderer(customRenderers[type], node, context);
    return [type, fn];
  });

  return Object.fromEntries(customEntries);
};

const buildCustomHTMLRenderer = (
  sourceContent,
  customRenderers = {
    htmlBlock: [],
    htmlInline: [],
    list: [],
    paragraph: [],
    text: [],
    softbreak: [],
  },
) => {
  const defaults = {
    htmlBlock(node, context) {
      const allHtmlBlockRenderers = [...customRenderers.htmlBlock, ...htmlBlockRenderers];

      return executeRenderer(allHtmlBlockRenderers, node, context);
    },
    htmlInline(node, context) {
      const allHtmlInlineRenderers = [...customRenderers.htmlInline, ...htmlInlineRenderers];

      return executeRenderer(allHtmlInlineRenderers, node, context);
    },
    list(node, context) {
      const allListRenderers = [...customRenderers.list, ...listRenderers];

      return executeRenderer(allListRenderers, node, context);
    },
    paragraph(node, context) {
      const allParagraphRenderers = [...customRenderers.paragraph, ...paragraphRenderers];

      return executeRenderer(allParagraphRenderers, node, Object.assign(context, { sourceContent }));
    },
    text(node, context) {
      const allTextRenderers = [...customRenderers.text, ...textRenderers];

      return executeRenderer(allTextRenderers, node, context);
    },
    softbreak(node, context) {
      const allSoftbreakRenderers = [...customRenderers.softbreak, ...softbreakRenderers];

      return executeRenderer(allSoftbreakRenderers, node, context);
    },
  };

  return {
    ...buildCustomRendererFunctions(customRenderers, defaults),
    ...defaults,
  };
};

export default buildCustomHTMLRenderer;
