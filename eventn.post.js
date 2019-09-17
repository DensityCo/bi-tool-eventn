const moment = require('moment');

/**
 * insertDoorway - core insert function
 *
 * @returns {Promise<void>}
 */
function insertDoorway(
  table_name,
  ts,
  doorway_id,
  entrancesVal,
  exitsVal,
  space_id,
  count,
) {
  const calcUtilPerc = `(round((${count}/(select capacity from meta_space where id = '${space_id}')* 100),2))`;

  return context.stores.density()
    .raw(`INSERT INTO ${table_name} (doorway_id, entrances, exits, total_events, peak_occupancy, utilization, timestamp) 
          VALUES ('${doorway_id}', ${entrancesVal}, ${exitsVal}, 1, ${entrancesVal}, ${calcUtilPerc}, '${ts}') 
          ON DUPLICATE KEY UPDATE 
            total_events = total_events +1, 
            entrances = entrances + ${entrancesVal},
            exits = exits + ${exitsVal},
            peak_occupancy = if((entrances - exits) > peak_occupancy, (entrances - exits), peak_occupancy),
            utilization = ${calcUtilPerc}
            `);
}

/**
 * onPost - Eventn default function called with an  HTTP POST request
 *
 * @param context
 * @param request
 * @returns {Promise<void>}
 */
async function onPost(context, request) {
  try {
    const {
      count,
      direction,
      doorway_id,
      space_id,
      timestamp,
    } = request.payload;

    let entrancesVal = 0;
    let exitsVal = 0;

    if (direction === 1) {
      entrancesVal = 1;
    } else {
      exitsVal = 1;
    }

    // doorway_minute
    const minuteStart = moment(timestamp)
      .startOf('minute')
      .format('YYYY-MM-DD HH:mm:ss');

    await insertDoorway(
      'doorway_minute',
      minuteStart,
      doorway_id,
      entrancesVal,
      exitsVal,
      space_id,
      count,
    );

    // doorway_hourly
    const hourStart = moment(timestamp)
      .startOf('hour')
      .format('YYYY-MM-DD HH:mm:ss');

    await insertDoorway(
      'doorway_hourly',
      hourStart,
      doorway_id,
      entrancesVal,
      exitsVal,
      space_id,
      count,
    );

    // doorway_daily
    const dayStart = moment(timestamp)
      .startOf('day')
      .format('YYYY-MM-DD HH:mm:ss');

    await insertDoorway(
      'doorway_daily',
      dayStart,
      doorway_id,
      entrancesVal,
      exitsVal,
      space_id,
      count,
    );

    // meta_space_doorway
    await context.stores.density().raw(
      `INSERT INTO meta_space_doorway (space_id, doorway_id)
            VALUES ('${space_id}', '${doorway_id}')
            ON DUPLICATE KEY UPDATE id = id;`,
    );
  } catch (e) {
    throw new Error(e);
  }
}

module.exports = onPost;
