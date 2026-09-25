const fs = require('fs');

const pages = [
  'index.html',
  'garage.html',
  'fuel_odo.html',
  'fasttag.html',
  'service.html',
  'qr_contact.html',
  'account.html',
  'login.html',
  'otp_verification.html',
  'payment_gateway.html'
];

console.log('Auditing vehicle switching hooks in pages:');
pages.forEach(page => {
  if (!fs.existsSync(page)) return;
  const content = fs.readFileSync(page, 'utf8');
  
  const hasMotoroFleetMenu = content.includes('motoro-fleet-menu.js');
  const hasChangeVehicle = content.includes('function changeVehicle(');
  const hasSelectVehicle = content.includes('function selectVehicle(');
  const hasSwitchActive = content.includes('function switchActiveVehicle(');
  const hasOnVehicleChanged = content.includes('function onVehicleChanged(');

  console.log(`[${page}]:`);
  console.log(`  motoro-fleet-menu.js: ${hasMotoroFleetMenu ? 'YES' : 'NO'}`);
  console.log(`  function changeVehicle: ${hasChangeVehicle ? 'YES (local override)' : 'NO'}`);
  console.log(`  function selectVehicle: ${hasSelectVehicle ? 'YES' : 'NO'}`);
  console.log(`  function switchActiveVehicle: ${hasSwitchActive ? 'YES' : 'NO'}`);
  console.log(`  function onVehicleChanged: ${hasOnVehicleChanged ? 'YES' : 'NO'}`);
});
