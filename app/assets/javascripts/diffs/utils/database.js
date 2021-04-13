import Dexie from 'dexie';

const schemaVersions = {
  "1": {
    "mergeRequests": "&id",
    "diffs": "id, mrId, [id+mrId]"
  }
}

export function openDatabase(){
  const db = new Dexie('diffs');
  const schemas = Object.entries(schemaVersions);

  schemas.forEach( ( [ version, schema ] ) => {
    db
      .version( version )
      .stores( schema );
  } );

  return db;
}

export async function cacheMergeRequestMetadata( { metadata, db = openDatabase() } ){
  return db
    .table( "mergeRequests" )
    .put( metadata );
}

export async function cacheDiffFiles( { files, db = openDatabase() } ){
  return db
    .table("diffs")
    .bulkPut( files );
}

export async function getMergeRequestById( { mrId, db = openDatabase() } ){
  return db.table("mergeRequests").get(mrId);
}

export async function getDiffFilesByMrId( { mrId, db = openDatabase() } ){
  return db
    .table("diffs")
    .where({ mrId })
    .sortBy( "order" );
}
