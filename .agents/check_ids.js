const fs = require('fs');

const indexHtml = fs.readFileSync('index.html', 'utf8');

// List of element IDs accessed in switchActiveVehicle
const idsCheckedInIndex = [
    'selectedVehicleLabel',
    'headerVehicleName',
    'headerVinBadge',
    'heroCarName',
    'heroVinText',
    'heroCarSubtitle',
    'heroFuelType',
    'heroTankLabel',
    'heroChassisBadge',
    'heroFuelPercent',
    'heroGaugePercent',
    'heroFuelBar',
    'heroCircularProgress',
    'heroVehicleImg',
    'statActiveFuel',
    'cardOdoReading',
    'walletLinkedPlate',
    'logFuelVehicleName',
    'logOdoVehicleName',
    'inputFuelOdo',
    'inputNewOdo',
    'vehicleDropdownMenu'
];

console.log('Verifying IDs in index.html:');
idsCheckedInIndex.forEach(id => {
    const exists = indexHtml.includes(`id="${id}"`) || indexHtml.includes(`id='${id}'`);
    console.log(`  id="${id}": ${exists ? 'EXISTS' : 'NOT FOUND (safely guarded by if)'}`);
});
