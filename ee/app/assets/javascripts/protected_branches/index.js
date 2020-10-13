/* eslint-disable no-unused-vars */

import $ from 'jquery';
import ProtectedBranchCreate from '~/protected_branches/protected_branch_create';
import ProtectedBranchEditList from './protected_branch_edit_list';

$(() => {
  const protectedBranchCreate = new ProtectedBranchCreate({ hasLicense: true });
  const protectedBranchEditList = new ProtectedBranchEditList();
});
