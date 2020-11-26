import IssuableForm from '~/issuable_form';
import groupsSelect from '~/groups_select';

export default class IssuableFormEE extends IssuableForm {
  constructor(form) {
    super(form);

    groupsSelect();
  }
}
