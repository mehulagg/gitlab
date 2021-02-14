const rails = require('./routes.json');
const webpack = require('./config/autoentries.json');

const sanitizedRails = rails.filter(x => Boolean(x))
  .map(x => x.replace(/\//g,'.').replace(/#index$/,'').replace(/#/g,'.'))

const noRoutes = Object.keys(webpack).flatMap(y => {
  const x= y.replace(/^pages./,'')
  if(sanitizedRails.includes(x)){
    return []
  }
  return  x;
})


console.log(noRoutes)
console.log(noRoutes.length)
