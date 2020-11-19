import { MarkdownSerializer, defaultMarkdownSerializer } from 'prosemirror-markdown';

export const toMarkdown = ({ content = '', nodes = {}, marks = {} }) => {
  const serializer = new MarkdownSerializer(
    {
      ...defaultMarkdownSerializer.nodes,
      ...nodes,
    },
    {
      ...defaultMarkdownSerializer.marks,
      ...marks,
    }
  );

  return serializer.serialize(content);
};
