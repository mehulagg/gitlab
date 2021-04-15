import { SNOWPLOW_JS_SOURCE } from './constants';

export default function getStandardContext({ base, extra = {} } = {}) {
  const standardContext = base || { ...window.gl?.snowplowStandardContext };

  return {
    schema: standardContext.schema,
    data: {
      ...(standardContext.data || {}),
      source: SNOWPLOW_JS_SOURCE,
      extra: extra || standardContext.data.extra,
    },
  };
}
