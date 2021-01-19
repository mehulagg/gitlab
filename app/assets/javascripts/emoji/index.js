import emojiAliases from 'emojis/aliases.json';
import axios from '../lib/utils/axios_utils';
import AccessorUtilities from '../lib/utils/accessor';

let emojiMap = null;
let emojiList = null;
let aliases = null;
let validEmojiNames = null;

export const FallbackEmojiKey = 'grey_question';
export const EMOJI_VERSION = '1';

const isLocalStorageAvailable = AccessorUtilities.isLocalStorageAccessSafe();

async function loadEmoji() {
  if (
    isLocalStorageAvailable &&
    window.localStorage.getItem('gl-emoji-map-version') === EMOJI_VERSION &&
    window.localStorage.getItem('gl-emoji-map')
  ) {
    return JSON.parse(window.localStorage.getItem('gl-emoji-map'));
  }

  // We load the JSON file direct from the server
  // because it can't be loaded from a CDN due to
  // cross domain problems with JSON
  const { data } = await axios.get(
    `${gon.relative_url_root || ''}/-/emojis/${EMOJI_VERSION}/emojis.json`,
  );
  window.localStorage.setItem('gl-emoji-map-version', EMOJI_VERSION);
  window.localStorage.setItem('gl-emoji-map', JSON.stringify(data));
  return data;
}

async function prepareEmojiMap() {
  emojiMap = await loadEmoji();

  if (!emojiMap[FallbackEmojiKey]) {
    throw new Error(`emojiMap does not have the indicated fallback emoji ${FallbackEmojiKey}`);
  }

  validEmojiNames = [...Object.keys(emojiMap), ...Object.keys(emojiAliases)];

  const emojiNames = Object.keys(emojiMap);
  emojiNames.forEach((name) => {
    emojiMap[name].name = name;
  });

  emojiList = Object.values(emojiMap);
  aliases = Object.keys(emojiAliases);
}

export function initEmojiMap() {
  initEmojiMap.promise = initEmojiMap.promise || prepareEmojiMap();
  return initEmojiMap.promise;
}

export function normalizeEmojiName(name) {
  return Object.prototype.hasOwnProperty.call(emojiAliases, name) ? emojiAliases[name] : name;
}

export function getValidEmojiNames() {
  return validEmojiNames;
}

export function isEmojiNameValid(name) {
  if (!emojiMap) {
    // eslint-disable-next-line @gitlab/require-i18n-strings
    throw new Error('The emoji map is uninitialized or initialization has not completed');
  }

  return name in emojiMap || name in emojiAliases;
}

export function getAllEmoji() {
  return emojiMap;
}

export function searchEmoji(query) {
  if (!query) {
    return [];
  }

  const lowercaseQuery = query.toLowerCase();
  const containsName = emojiList.filter((emoji) => emoji.name.indexOf(lowercaseQuery) >= 0);
  const containsAlias = aliases.filter((alias) => alias.indexOf(query) >= 0);
  const containsDescription = emojiList.filter((emoji) => emoji.d.indexOf(lowercaseQuery) >= 0);
  const matchesUnicode = emojiList.filter((emoji) => emoji.e === query);

  return {
    byName: containsName,
    aliases: containsAlias,
    byDescription: containsDescription,
    byUnicode: matchesUnicode,
  };
}

export function getEmojiNames(result) {
  const { byName, aliases, byDescription, byUnicode } = result;

  return [
    ...byUnicode,
    ...byDescription,
    ...aliases.map((alias) => emojiMap[emojiAliases[alias]]),
    ...byName,
  ].map((emoji) => emoji.name);
}

let emojiCategoryMap;
export function getEmojiCategoryMap() {
  if (!emojiCategoryMap) {
    emojiCategoryMap = {
      activity: [],
      people: [],
      nature: [],
      food: [],
      travel: [],
      objects: [],
      symbols: [],
      flags: [],
    };
    Object.keys(emojiMap).forEach((name) => {
      const emoji = emojiMap[name];
      if (emojiCategoryMap[emoji.c]) {
        emojiCategoryMap[emoji.c].push(name);
      }
    });
  }
  return emojiCategoryMap;
}

/**
 * Retrieves an emoji by name or alias.
 *
 * @param {String} query The emoji name
 * @param {Boolean} fallback If true, a fallback emoji will be returned if the
 * named emoji does not exist.
 * @returns {Object} The matching emoji.
 */
export function getEmojiInfo(query, fallback = true) {
  if (!emojiMap) {
    // eslint-disable-next-line @gitlab/require-i18n-strings
    throw new Error('The emoji map is uninitialized or initialization has not completed');
  }

  if (!query) {
    return fallback ? emojiMap[FallbackEmojiKey] : null;
  }

  const lowercaseQuery = query.toLowerCase();
  const name = normalizeEmojiName(lowercaseQuery);

  if (name in emojiMap) {
    return emojiMap[name];
  }

  return fallback ? emojiMap[FallbackEmojiKey] : null;
}

export function emojiFallbackImageSrc(inputName) {
  const { name } = getEmojiInfo(inputName);
  return `${gon.asset_host || ''}${
    gon.relative_url_root || ''
  }/-/emojis/${EMOJI_VERSION}/${name}.png`;
}

export function emojiImageTag(name, src) {
  return `<img class="emoji" title=":${name}:" alt=":${name}:" src="${src}" width="20" height="20" align="absmiddle" />`;
}

export function glEmojiTag(inputName, options) {
  const opts = { sprite: false, ...options };
  const name = normalizeEmojiName(inputName);
  const fallbackSpriteClass = `emoji-${name}`;

  const fallbackSpriteAttribute = opts.sprite
    ? `data-fallback-sprite-class="${fallbackSpriteClass}"`
    : '';

  return `
    <gl-emoji
      ${fallbackSpriteAttribute}
      data-name="${name}"></gl-emoji>
  `;
}
