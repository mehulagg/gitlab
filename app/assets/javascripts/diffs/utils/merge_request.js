import { uuids } from "./uuids";

const endpointRE = /^(\/?(.+?)\/(.+?)\/-\/merge_requests\/(\d+)).*$/i;

export function getDerivedMergeRequestInformation({ endpoint } = {}) {
  let mrPath;
  let userOrGroup;
  let project;
  let id;
  const matches = endpointRE.exec(endpoint);

  if (matches) {
    [, mrPath, userOrGroup, project, id] = matches;
  }

  return {
    mrPath,
    userOrGroup,
    project,
    id,
  };
}

export function identifier( { metadata } ){
  const { userOrGroup, project, id } = getDerivedMergeRequestInformation({ "endpoint": metadata.latest_version_path });
  // This is a *count* not an index! Version 2 is index 2! If there's only 1 version, it's null!
  const version = metadata.merge_request_diff.version_index || 1;

  return uuids({
    seeds: [userOrGroup, project, id, version],
  })[0];
}
