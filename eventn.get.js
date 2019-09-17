/**
 * This script can be used to populate the meta_space table
 * and only needs to be run once.
 *
 * Copy the below to replace the Eventn GET function, replace
 * the `densityApiToken` value and run by pressing the GET
 * button within the test panel.
 */
const densityApiToken = '*********************';

const fetch = require('node-fetch');
const Headers = fetch.Headers;

function getSpaces() {
  return fetch('https://api.density.io/v2/spaces/', {
    headers: new Headers({
      Authorization: `Bearer ${densityApiToken}`,
    }),
  }).then(response => response.json());
}

async function onGet(context) {
  const spaces = await getSpaces();

  if (!spaces.results) {
    return spaces;
  }

  const results = spaces.results.map(a => ({
    id: a.id,
    name: a.name,
    description: a.description,
    space_type: a.space_type,
    capacity: a.capacity || 0,
  }));

  return await context.stores.density('meta_space').insert(results);
}

module.exports = onGet;
