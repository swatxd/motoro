const fs = require('fs');

const files = ['index.html', 'fuel_odo.html', 'fasttag.html', 'service.html', 'qr_contact.html', 'garage.html', 'account.html'];

let allOk = true;

files.forEach(f => {
    const content = fs.readFileSync(f, 'utf8');
    const checks = {
        motoro_active_vin: content.includes('motoro_active_vin'),
        vehicleDropdownBtn: content.includes('vehicleDropdownBtn'),
        selectedVehicleLabel: content.includes('selectedVehicleLabel'),
        changeVehicle: content.includes('changeVehicle'),
        accountLink: content.includes('href="account.html"')
    };

    console.log(`[${f}]`);
    for (const [k, v] of Object.entries(checks)) {
        console.log(`  - ${k}: ${v ? 'OK' : 'MISSING'}`);
        if (!v) allOk = false;
    }
});

console.log(`\nOverall check: ${allOk ? 'ALL PASSED' : 'SOME CHECKS FAILED'}`);

