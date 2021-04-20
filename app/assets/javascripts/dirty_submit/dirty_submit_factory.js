import DirtySubmitCollection from './dirty_submit_collection';
import DirtySubmitForm from './dirty_submit_form';

export default function dirtySubmitFactory(formOrForms, onChange) {
  const isCollection = formOrForms instanceof NodeList || formOrForms instanceof Array;

  if (isCollection) {
    return new DirtySubmitCollection(formOrForms);
  }

  return new DirtySubmitForm(formOrForms, onChange);
}
