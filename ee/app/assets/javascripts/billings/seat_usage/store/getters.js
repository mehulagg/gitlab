import { s__ } from '~/locale';

export const tableItems = state => {
  if (state.members.length) {
    return state.members.map(({ name, username, avatar_url, web_url, email }) => {
      const formattedUserName = `@${username}`;

      return { user: { name, username: formattedUserName, avatar_url, web_url }, email };
    });
  }

  return [];
};

const MIN_SEARCH_STRING_SIZE = 3;

export const isSearchStringTooShort = state => {
  return state.search.length < MIN_SEARCH_STRING_SIZE;
};
