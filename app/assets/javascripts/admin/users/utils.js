import { convertToCamelCase } from '~/lib/utils/text_utility';

export const generateUserPaths = (paths, id) => {
  return Object.fromEntries(
    Object.entries(paths).map(([action, genericPath]) => {
      return [action, genericPath.replace('id', id)];
    }),
  );
};

export const arrayToCamelCase = (array) => {
  return array.map((i) => convertToCamelCase(i));
};
