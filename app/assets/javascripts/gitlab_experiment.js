import { get, camelCase } from 'lodash';

export default class GitlabExperiment {
  static run(experimentName, variants) {
    const variant = this.currentVariantName(experimentName);

    switch (variant) {
      case 'control': return variants.use.call();
      case 'candidate': return variants.try.call();
      default: return variants[variant].call();
    };
  }

  static currentVariantName(experimentName) {
    return camelCase(get(window, ['gon', 'global', 'experiment', experimentName, 'variant'], 'control'));
  }
}
