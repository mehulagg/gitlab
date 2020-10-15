import { frontMatterify, stringify } from './front_matterify';

const parseSourceFile = raw => {
  const remake = source => frontMatterify(source);

  let editable = remake(raw);
  let lastValidMatter = null;

  const syncContent = (newVal, isBody) => {
    if (isBody) {
      editable.content = newVal;
    } else {
      // 1. Cache last valid matter to account for mid-edit resulting in matter invalidation
      if (editable.hasMatter) {
        lastValidMatter = editable.matter;
      }

      // 2. Update editable
      editable = remake(newVal);

      // 3. Use last valid matter cache if mid-edit results in matter invalidation
      if (!editable.isMatterValid) {
        editable.matter = lastValidMatter;
      }
    }
  };

  const content = (isBody = false) => (isBody ? editable.content : stringify(editable));

  const matter = () => editable.matter;

  const syncMatter = settings => {
    editable.matter = settings;
  };

  const isModified = () => stringify(editable) !== raw;

  const hasMatter = () => editable.hasMatter;

  const isMatterValid = () => editable.isMatterValid;

  return {
    matter,
    isMatterValid,
    syncMatter,
    content,
    syncContent,
    isModified,
    hasMatter,
  };
};

export default parseSourceFile;
