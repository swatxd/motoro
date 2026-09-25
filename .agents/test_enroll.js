const fs = require('fs');
const path = require('path');

async function testBackendAndPages() {
    console.log('--- Testing Backend Live Fleet Endpoints ---');
    
    // 1. Fetch initial menu
    const menuRes = await fetch('http://127.0.0.1:8000/api/v1/vehicles/menu');
    if (!menuRes.ok) {
        throw new Error(`GET /api/v1/vehicles/menu failed with status ${menuRes.status}`);
    }
    const initialMenu = await menuRes.json();
    console.log(`Initial menu has ${initialMenu.length} vehicles.`);
    if (initialMenu.length < 3) {
        throw new Error(`Expected at least 3 vehicles in initial menu, got ${initialMenu.length}`);
    }

    // 2. Enroll a new Indian vehicle
    const testCar = {
        name: 'Tata Safari Dark Edition',
        plate: 'MH 14 SF 9911',
        fuel_type: 'Diesel',
        tank_capacity_l: 50,
        odometer_km: 1800,
        fastag_bank: 'ICICI Bank FASTag',
        image_url: 'assets/images/mahindra_xuv700.jpg'
    };

    const enrollRes = await fetch('http://127.0.0.1:8000/api/v1/vehicles/enroll', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(testCar)
    });

    if (!enrollRes.ok) {
        throw new Error(`POST /api/v1/vehicles/enroll failed with status ${enrollRes.status}`);
    }
    const enrolledCar = await enrollRes.json();
    console.log(`Enrolled car successfully: ${enrolledCar.name} with VIN ${enrolledCar.vin} and plate ${enrolledCar.plate}`);

    // 3. Verify it shows in live menu
    const updatedMenuRes = await fetch('http://127.0.0.1:8000/api/v1/vehicles/menu');
    const updatedMenu = await updatedMenuRes.json();
    const found = updatedMenu.find(c => c.vin === enrolledCar.vin);
    if (!found) {
        throw new Error(`Enrolled vehicle ${enrolledCar.vin} not found in updated live menu!`);
    }
    console.log(`Verified vehicle ${found.name} is present in live menu!`);

    // 4. Clean up test car
    const delRes = await fetch(`http://127.0.0.1:8000/api/v1/vehicles/${encodeURIComponent(enrolledCar.vin)}`, {
        method: 'DELETE'
    });
    if (!delRes.ok) {
        console.warn(`DELETE cleanup returned status ${delRes.status}`);
    } else {
        console.log(`Cleaned up test car ${enrolledCar.vin}`);
    }

    // 5. Test static HTML files for proper integrations
    console.log('\n--- Testing UI Pages Integration ---');
    const pages = [
        'garage.html',
        'index.html',
        'service.html',
        'fuel_odo.html',
        'fasttag.html',
        'qr_contact.html',
        'account.html'
    ];

    for (const page of pages) {
        const filePath = path.join(__dirname, '..', page);
        const content = fs.readFileSync(filePath, 'utf-8');
        
        if (!content.includes('assets/js/motoro-fleet-menu.js')) {
            throw new Error(`Missing motoro-fleet-menu.js script in ${page}`);
        }
        if (!content.includes('id="vehicleDropdownMenu"')) {
            throw new Error(`Missing vehicleDropdownMenu container in ${page}`);
        }
        if (!content.includes('id="selectedVehicleLabel"')) {
            throw new Error(`Missing selectedVehicleLabel element in ${page}`);
        }
        console.log(`✓ ${page}: Has live fleet menu script and dropdown containers`);
    }

    // Check garage.html specific elements
    const garageContent = fs.readFileSync(path.join(__dirname, '..', 'garage.html'), 'utf-8');
    const garageRequired = [
        'id="garageFleetGrid"',
        'id="garageEnrolledCountBadge"',
        'id="enrollModal"',
        'id="hsrpLiveNumber"',
        'id="hsrpStateBadge"',
        'selectModelPreset'
    ];
    for (const req of garageRequired) {
        if (!garageContent.includes(req)) {
            throw new Error(`garage.html missing ${req}`);
        }
    }
    console.log(`✓ garage.html: Has HSRP plate visualizer, model presets, and fleet grid IDs`);

    console.log('\nAll enrollment and live menu verification checks PASSED!');
}

testBackendAndPages().catch(err => {
    console.error('Test FAILED:', err);
    process.exit(1);
});
