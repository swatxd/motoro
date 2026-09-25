const fs = require('fs');
const content = fs.readFileSync('qr_contact.html', 'utf8');

const checks = [
  { name: 'motoro_active_vin sync', test: content.includes('motoro_active_vin') },
  { name: 'vehicleDropdownBtn', test: content.includes('id="vehicleDropdownBtn"') },
  { name: 'selectedVehicleLabel', test: content.includes('id="selectedVehicleLabel"') },
  { name: 'changeVehicle func', test: content.includes('function changeVehicle(') },
  { name: 'account link in header', test: content.includes('href="account.html"') },
  { name: 'live scanner section', test: content.includes('id="scannerTab"') },
  { name: 'camera video element', test: content.includes('id="cameraVideo"') },
  { name: '1-page pdf print element', test: content.includes('id="motoroPrintDocument"') },
  { name: 'pdf preview modal', test: content.includes('id="pdfPreviewModal"') },
  { name: 'svg download function', test: content.includes('function downloadStickerSvg()') },
  { name: 'web audio beep function', test: content.includes('function playScanBeep()') },
  { name: 'instant demo scans', test: content.includes("simulateScan('MH 12 RN 2024'") }
];

checks.forEach(c => console.log(c.name.padEnd(30), c.test ? 'PASS' : 'FAIL'));
const allPass = checks.every(c => c.test);
console.log('Result:', allPass ? 'ALL CHECKS PASSED' : 'SOME CHECKS FAILED');
process.exit(allPass ? 0 : 1);
