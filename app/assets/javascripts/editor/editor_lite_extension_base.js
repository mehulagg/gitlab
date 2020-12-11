import { ERROR_INSTANCE_REQUIRED_FOR_EXTENSION } from './constants';

export class EditorLiteExtension {
  constructor({ instance, ...options } = {}) {
    if (instance) {
      Object.assign(instance, options);
    } else if (Object.entries(options).length) {
      // eslint-disable-next-line no-console
      console.error(ERROR_INSTANCE_REQUIRED_FOR_EXTENSION);
      /* eslint-disable-next-line @gitlab/require-i18n-strings */
      throw new Error(ERROR_INSTANCE_REQUIRED_FOR_EXTENSION);
    }
  }
}
