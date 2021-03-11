import Cookies from 'js-cookie';
import { chunk, memoize, uniq } from 'lodash';
import { initEmojiMap, getEmojiCategoryMap } from '~/emoji';
import { EMOJIS_PER_ROW, EMOJI_ROW_HEIGHT, CATEGORY_ROW_HEIGHT } from '../constants';

export const generateCategoryHeight = (emojisLength) =>
  emojisLength * EMOJI_ROW_HEIGHT + CATEGORY_ROW_HEIGHT;

export const getFrequentlyUsedEmojis = () => {
  const savedEmojis = Cookies.get('frequently_used_emojis');

  if (!savedEmojis) return null;

  const emojis = chunk(uniq(savedEmojis.split(',')), 9);

  return {
    frequently_used: {
      emojis,
      top: 0,
      height: generateCategoryHeight(emojis.length),
    },
  };
};

export const addToFrequentlyUsed = (emoji) => {
  const frequentlyUsedEmojis = uniq(
    (Cookies.get('frequently_used_emojis') || '')
      .split(',')
      .filter((e) => e)
      .concat(emoji),
  );

  Cookies.set('frequently_used_emojis', frequentlyUsedEmojis.join(','), { expires: 365 });
};

export const hasFrequentlyUsedEmojis = () => getFrequentlyUsedEmojis() !== null;

export const getEmojiCategories = memoize(async () => {
  await initEmojiMap();

  const categories = await getEmojiCategoryMap();
  const frequentlyUsedEmojis = getFrequentlyUsedEmojis();
  let top = frequentlyUsedEmojis
    ? frequentlyUsedEmojis.frequently_used.top + frequentlyUsedEmojis.frequently_used.height
    : 0;

  return Object.freeze(
    Object.keys(categories)
      .filter((c) => c !== 'frequently_used')
      .reduce((acc, category) => {
        const emojis = chunk(categories[category], EMOJIS_PER_ROW);
        const height = generateCategoryHeight(emojis.length);
        const newAcc = {
          ...acc,
          [category]: { emojis, height, top },
        };
        top += height;

        return newAcc;
      }, frequentlyUsedEmojis || {}),
  );
});
