import { Response } from 'miragejs';
import { getEmojis } from 'test_helpers/fixtures';

export default (server) => {
  server.get('/-/emojis/1/emojis.json', () => {
    return new Response(200, {}, getEmojis());
  });
};
