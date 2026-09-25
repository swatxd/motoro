const fs = require('fs');

console.log('--- Comprehensive Full App Verification ---');

const pages = [
  'index.html',
  'garage.html',
  'fuel_odo.html',
  'fasttag.html',
  'service.html',
  'qr_contact.html',
  'account.html'
];

let allPassed = true;

pages.forEach(file => {
  const content = fs.readFileSync(file, 'utf8');

  // 1. Check universal script presence
  const hasScript = content.includes('assets/js/motoro-fleet-menu.js');
  
  // 2. Check onVehicleChanged hook
  const hasHook = content.includes('onVehicleChanged') || content.includes('selectVehicle') || content.includes('switchActiveVehicle');

  // 3. Check dropdown elements
  const hasDropdownBtn = content.includes('id="vehicleDropdownBtn"');
  const hasDropdownMenu = content.includes('id="vehicleDropdownMenu"');
  const hasLabel = content.includes('id="selectedVehicleLabel"');

  console.log(`[${file}]`);
  console.log(`  motoro-fleet-menu.js script: ${hasScript ? 'PASS' : 'FAIL'}`);
  console.log(`  vehicle change handler hook: ${hasHook ? 'PASS' : 'FAIL'}`);
  console.log(`  vehicleDropdownBtn:          ${hasDropdownBtn ? 'PASS' : 'FAIL'}`);
  console.log(`  vehicleDropdownMenu:         ${hasDropdownMenu ? 'PASS' : 'FAIL'}`);
  console.log(`  selectedVehicleLabel:        ${hasLabel ? 'PASS' : 'FAIL'}`);

  if (!hasScript || !hasHook || !hasDropdownBtn || !hasDropdownMenu || !hasLabel) {
    allPassed = false;
  }
});

console.log(`\nUniversal Integration Status: ${allPassed ? 'ALL PAGES VERIFIED & PASSING!' : 'SOME ISSUES FOUND'}`);
