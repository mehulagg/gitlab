import List from './list.vue';
import Url from './url.vue';

export const typesComponents = {
  List,
  Url,
};

export const supportedTypes = Object.keys(typesComponents).map((x) => x.toLowerCase());
