/**
 * MOTORO Connected Fleet - Live Menu & Vehicle Synchronizer
 * Dynamically fetches vehicle fleet from FastAPI backend and synchronizes header dropdowns across all pages.
 */

const MOTORO_API_BASE = 'http://127.0.0.1:8000';

const MOTORO_DEFAULT_FLEET = [
    {
        vin: 'IND-MH12-XUV700',
        plate: 'MH 12 RN 2024',
        name: 'Mahindra XUV700 AX7 L',
        brand: 'Mahindra',
        fuel_type: 'Diesel mHawk 2.2L',
        image_url: 'assets/images/mahindra_xuv700.jpg',
        is_selected: true,
        tank_capacity_l: 60,
        odometer_km: 14820,
        fastag_bank: 'ICICI Bank FASTag'
    },
    {
        vin: 'IND-KA01-NEXON-EV',
        plate: 'KA 01 EQ 4050',
        name: 'Tata Nexon EV Empowered+',
        brand: 'Tata',
        fuel_type: 'Electric (40.5 kWh)',
        image_url: 'assets/images/tata_nexon_ev.jpg',
        is_selected: false,
        tank_capacity_l: 40.5,
        odometer_km: 9450,
        fastag_bank: 'HDFC Bank FASTag'
    },
    {
        vin: 'IND-DL08-THAR-4X4',
        plate: 'DL 08 CA 7788',
        name: 'Mahindra Thar 4x4 MT',
        brand: 'Mahindra',
        fuel_type: 'Diesel mHawk 130',
        image_url: 'assets/images/mahindra_thar.jpg',
        is_selected: false,
        tank_capacity_l: 57,
        odometer_km: 21300,
        fastag_bank: 'SBI FASTag'
    }
];

// In-memory fleet cache
let currentFleetList = [...MOTORO_DEFAULT_FLEET];

/**
 * Get the currently active VIN from storage or defaults
 */
function getActiveVin() {
    return localStorage.getItem('motoro_active_vin') || sessionStorage.getItem('motoro_active_vin') || 'IND-MH12-XUV700';
}

/**
 * Fetch live fleet list from FastAPI backend with fallback to localStorage
 */
async function fetchLiveFleetMenu() {
    try {
        const res = await fetch(`${MOTORO_API_BASE}/api/v1/vehicles/menu`, { signal: AbortSignal.timeout(1800) });
        if (res.ok) {
            const data = await res.json();
            if (Array.isArray(data) && data.length > 0) {
                currentFleetList = data;
                localStorage.setItem('motoro_fleet', JSON.stringify(data));
                syncPageFleetDictionaries();
                renderLiveVehicleDropdown();
                updateActiveVehicleBadge();
                if (typeof renderIndexFleetCards === 'function') renderIndexFleetCards();
                if (typeof renderGarageFleetGrid === 'function') renderGarageFleetGrid();
                if (typeof updateFleetCountBadge === 'function') updateFleetCountBadge();
                return currentFleetList;
            }
        }
    } catch (_) {
        // Backend not reachable, try localStorage
    }

    try {
        const stored = localStorage.getItem('motoro_fleet');
        if (stored) {
            const parsed = JSON.parse(stored);
            if (Array.isArray(parsed) && parsed.length > 0) {
                currentFleetList = parsed;
            }
        }
    } catch (_) {}

    syncPageFleetDictionaries();
    renderLiveVehicleDropdown();
    updateActiveVehicleBadge();
    if (typeof renderIndexFleetCards === 'function') renderIndexFleetCards();
    if (typeof renderGarageFleetGrid === 'function') renderGarageFleetGrid();
    if (typeof updateFleetCountBadge === 'function') updateFleetCountBadge();
    return currentFleetList;
}

/**
 * Render the live dropdown menu in the header
 */
function renderLiveVehicleDropdown() {
    const menu = document.getElementById('vehicleDropdownMenu');
    if (!menu) return;

    const activeVin = getActiveVin();

    let itemsHtml = `
        <div class="px-3 py-2 border-b border-outline-variant/30 flex items-center justify-between">
            <span class="text-[10px] font-headline uppercase tracking-wider text-slate-400 font-bold">Enrolled Fleet Tags</span>
            <span class="text-[9px] font-mono font-bold bg-primary/10 text-primary px-1.5 py-0.5 rounded-full">${currentFleetList.length} Connected</span>
        </div>
        <div class="max-h-64 overflow-y-auto py-1 space-y-0.5">
    `;

    currentFleetList.forEach(car => {
        const isSelected = (car.vin === activeVin);
        const activeClass = isSelected ? 'bg-primary/10 text-primary font-bold' : 'hover:bg-surface-container text-on-surface';
        const checkmark = isSelected 
            ? '<span class="material-symbols-outlined text-base text-primary">check_circle</span>' 
            : '<span class="w-4 h-4 rounded-full border border-slate-300"></span>';

        itemsHtml += `
            <button type="button" onclick="changeVehicle('${car.vin}')"
                class="w-full text-left px-3 py-2 text-xs flex items-center justify-between transition-colors cursor-pointer group ${activeClass}">
                <div class="flex items-center gap-2.5 min-w-0">
                    <img src="${car.image_url || 'assets/images/mahindra_xuv700.jpg'}" alt="${car.name}" 
                        class="w-7 h-7 rounded-lg object-cover border border-outline-variant/40 shrink-0" 
                        onerror="this.src='assets/images/mahindra_xuv700.jpg'" />
                    <div class="truncate">
                        <div class="flex items-center gap-1.5">
                            <span class="font-bold truncate text-[11px]">${car.name}</span>
                        </div>
                        <p class="text-[10px] text-secondary font-mono">${car.plate}</p>
                    </div>
                </div>
                <div class="shrink-0 ml-2">
                    ${checkmark}
                </div>
            </button>
        `;
    });

    itemsHtml += `
        </div>
        <div class="p-1.5 border-t border-outline-variant/30 bg-slate-50/80 rounded-b-2xl">
            <button type="button" onclick="handleMenuEnrollClick()"
                class="w-full py-2 px-3 rounded-xl bg-primary text-white hover:bg-primary-hover font-bold text-xs flex items-center justify-center gap-1.5 shadow-sm transition-all cursor-pointer">
                <span class="material-symbols-outlined text-sm">add_circle</span>
                <span>Enroll New Indian Car</span>
            </button>
        </div>
    `;

    menu.innerHTML = itemsHtml;
}

/**
 * Update the header badge with the active vehicle's plate
 */
function updateActiveVehicleBadge() {
    const activeVin = getActiveVin();
    const label = document.getElementById('selectedVehicleLabel');
    if (!label) return;

    const car = currentFleetList.find(c => c.vin === activeVin) || currentFleetList[0];
    if (car) {
        label.textContent = car.plate;
    }
}

/**
 * Handle clicking "+ Enroll New Vehicle" inside the dropdown menu
 */
function handleMenuEnrollClick() {
    const menu = document.getElementById('vehicleDropdownMenu');
    if (menu) menu.classList.add('hidden');

    const enrollModal = document.getElementById('enrollModal');
    if (enrollModal && typeof openEnrollVehicleModal === 'function') {
        openEnrollVehicleModal();
    } else {
        window.location.href = 'garage.html?openEnroll=true';
    }
}

/**
 * Synchronize page-specific legacy mock dictionaries with the live fleet list
 * so newly enrolled vehicles work seamlessly across all pages without undefined errors.
 */
function syncPageFleetDictionaries() {
    if (!Array.isArray(currentFleetList)) return;

    currentFleetList.forEach(car => {
        const vin = car.vin;
        const cleanPlate = car.plate || vin.replace('IND-', '').replace(/-/g, ' ');
        const brand = car.brand || (car.name ? car.name.split(' ')[0] : 'Indian');
        const isEv = (car.fuel_type && (car.fuel_type.toLowerCase().includes('ev') || car.fuel_type.toLowerCase().includes('electric')));
        const cap = Number(car.tank_capacity_l || (isEv ? 40.5 : 55.0));
        const odo = Number(car.odometer_km || 12400);
        const fastagBank = car.fastag_bank || 'ICICI Bank FASTag';

        // 1. fuel_odo.html: VEHICLES
        if (typeof window.VEHICLES === 'object' && window.VEHICLES !== null) {
            if (!window.VEHICLES[vin]) {
                window.VEHICLES[vin] = {
                    vin: vin,
                    name: car.name,
                    plate: cleanPlate,
                    fuelType: car.fuel_type || (isEv ? 'Electric (40.5 kWh LFP)' : 'Diesel mHawk 2.2L'),
                    fuelCapacity: cap,
                    fuelLevelLitres: isEv ? Number((cap * 0.82).toFixed(1)) : Number((cap * 0.76).toFixed(1)),
                    fuelPercent: 78.0,
                    odometerKm: odo,
                    serviceDueKm: 2100,
                    avgMileage: isEv ? 9.2 : 14.5,
                    estRangeKm: isEv ? 370 : 610,
                    defaultFuelPrice: isEv ? 16.50 : 94.20
                };
            }
        }

        // 2. fasttag.html: fastTagDB
        if (typeof window.fastTagDB === 'object' && window.fastTagDB !== null) {
            if (!window.fastTagDB[vin]) {
                const tagSerial = `NETC-${Math.floor(1000 + Math.random()*9000)}-${Math.floor(1000 + Math.random()*9000)}-${Math.floor(1000 + Math.random()*9000)}`;
                window.fastTagDB[vin] = {
                    name: car.name,
                    plate: cleanPlate,
                    tagSerial: tagSerial,
                    bank: fastagBank,
                    balance: 1500.00,
                    status: 'Active',
                    monthlyPass: 'None'
                };
            }
        }

        // 3. service.html: fleetDB
        if (typeof window.fleetDB === 'object' && window.fleetDB !== null) {
            if (!window.fleetDB[vin]) {
                window.fleetDB[vin] = {
                    name: car.name,
                    plate: cleanPlate,
                    brand: brand,
                    odometer: odo,
                    fuelLevel: isEv ? `80% (${(cap * 0.8).toFixed(1)} kWh)` : `75% (${(cap * 0.75).toFixed(1)} L)`,
                    serviceDue: 'In 2,100 km'
                };
            }
        }

        // 4. qr_contact.html: fleetData
        if (typeof window.fleetData === 'object' && window.fleetData !== null) {
            if (!window.fleetData[vin]) {
                window.fleetData[vin] = {
                    name: car.name,
                    plate: cleanPlate,
                    city: 'Kozhikode, Kerala',
                    brand: brand,
                    img: car.image_url || 'assets/images/mahindra_xuv700.jpg'
                };
            }
        }

        // 5. index.html & account.html: vehiclesDB
        if (typeof window.vehiclesDB === 'object' && window.vehiclesDB !== null) {
            if (!window.vehiclesDB[vin]) {
                window.vehiclesDB[vin] = {
                    name: car.name,
                    plate: cleanPlate,
                    chassis: 'IND...' + vin.slice(-4),
                    subtitle: 'Enrolled Indian Fleet • Telemetry Active',
                    fuelType: car.fuel_type || (isEv ? 'Electric' : 'Diesel'),
                    tankLabel: isEv ? 'EV Battery SoC' : 'Fuel Tank Level',
                    fuelPercent: 80.0,
                    fuelLitres: Number((cap * 0.8).toFixed(1)),
                    capacityLitres: cap,
                    rangeKm: isEv ? 385 : 580,
                    odometerKm: odo,
                    serviceDueKm: 1800,
                    img: car.image_url || 'assets/images/mahindra_xuv700.jpg',
                    fuel: isEv ? 'Electric' : (car.fuel_type || 'Diesel'),
                    bank: fastagBank,
                    bal: 1500.00,
                    odo: odo
                };
            }
        }
    });
}

/**
 * Universal change vehicle function
 */
async function changeVehicle(vin) {
    try {
        localStorage.setItem('motoro_active_vin', vin);
        sessionStorage.setItem('motoro_active_vin', vin);
    } catch (_) {}

    // Update backend asynchronously
    try {
        fetch(`${MOTORO_API_BASE}/api/v1/vehicles/select/${encodeURIComponent(vin)}`, {
            method: 'POST',
            signal: AbortSignal.timeout(1500)
        }).catch(() => {});
    } catch (_) {}

    syncPageFleetDictionaries();

    const car = currentFleetList.find(c => c.vin === vin);
    const plate = car ? car.plate : vin;

    updateActiveVehicleBadge();
    renderLiveVehicleDropdown();

    const menu = document.getElementById('vehicleDropdownMenu') || document.getElementById('serviceVehicleDropdownMenu');
    if (menu) menu.classList.add('hidden');

    // Notify all page-specific listeners
    if (typeof onVehicleChanged === 'function') {
        try { onVehicleChanged(vin); } catch (e) { console.warn('onVehicleChanged error:', e); }
    }
    if (typeof selectVehicle === 'function') {
        try { selectVehicle(vin); } catch (e) { console.warn('selectVehicle error:', e); }
    }
    if (typeof selectServiceVehicle === 'function') {
        try { selectServiceVehicle(vin); } catch (e) { console.warn('selectServiceVehicle error:', e); }
    }
    if (typeof selectFleetVehicle === 'function') {
        try { selectFleetVehicle(vin); } catch (e) { console.warn('selectFleetVehicle error:', e); }
    }
    if (typeof switchActiveVehicle === 'function') {
        try { switchActiveVehicle(vin); } catch (e) { console.warn('switchActiveVehicle error:', e); }
    }
    if (typeof updateVehicleUI === 'function') {
        try { updateVehicleUI(vin); } catch (e) { console.warn('updateVehicleUI error:', e); }
    }
    if (typeof renderIndexFleetCards === 'function') {
        try { renderIndexFleetCards(); } catch (e) { console.warn('renderIndexFleetCards error:', e); }
    }
    if (typeof renderGarageFleetGrid === 'function') {
        try { renderGarageFleetGrid(); } catch (e) { console.warn('renderGarageFleetGrid error:', e); }
    }

    if (typeof showToast === 'function') {
        showToast('Active Vehicle', `Switched to ${car ? car.name : vin} (${plate})`);
    }
}

/**
 * Enroll a new vehicle to the backend and local fleet
 */
async function enrollVehicleToBackend(vehicleData) {
    let enrolled = null;

    // 1. Try FastAPI backend
    try {
        const res = await fetch(`${MOTORO_API_BASE}/api/v1/vehicles/enroll`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(vehicleData),
            signal: AbortSignal.timeout(3000)
        });
        if (res.ok) {
            enrolled = await res.json();
        }
    } catch (_) {}

    const cleanPlate = vehicleData.plate.toUpperCase().trim();
    const isEv = (vehicleData.fuel_type && (vehicleData.fuel_type.toLowerCase().includes('electric') || vehicleData.fuel_type.toLowerCase().includes('ev')));
    const cap = Number(vehicleData.tank_capacity_l || vehicleData.fuel_capacity_litres || (isEv ? 40.5 : 55.0));
    const odo = Number(vehicleData.odometer_km || 1500);
    const fastagBank = vehicleData.fastag_bank || 'ICICI Bank FASTag';
    const imageUrl = vehicleData.image_url || 'assets/images/mahindra_xuv700.jpg';

    // 2. Fallback to client synthesis if backend was offline
    if (!enrolled) {
        const vin = `IND-${cleanPlate.replace(/\s+/g, '-')}`;
        enrolled = {
            vin: vin,
            name: vehicleData.name,
            plate: cleanPlate,
            brand: vehicleData.brand || vehicleData.name.split(' ')[0],
            fuel_type: vehicleData.fuel_type,
            image_url: imageUrl,
            odometer_km: odo,
            tank_capacity_l: cap,
            fastag_bank: fastagBank,
            is_selected: true
        };
    }

    // 3. Update local state
    const menuItem = {
        vin: enrolled.vin,
        plate: cleanPlate,
        name: vehicleData.name,
        brand: vehicleData.brand || vehicleData.name.split(' ')[0],
        fuel_type: vehicleData.fuel_type,
        image_url: imageUrl,
        is_selected: true,
        tank_capacity_l: cap,
        odometer_km: odo,
        fastag_bank: fastagBank
    };

    // Remove duplicates if re-enrolling
    currentFleetList = currentFleetList.filter(c => c.vin !== enrolled.vin);
    currentFleetList.unshift(menuItem);

    try {
        localStorage.setItem('motoro_fleet', JSON.stringify(currentFleetList));
        localStorage.setItem('motoro_active_vin', enrolled.vin);
        sessionStorage.setItem('motoro_active_vin', enrolled.vin);
    } catch (_) {}

    // 4. Update UI and page DBs
    syncPageFleetDictionaries();
    updateActiveVehicleBadge();
    renderLiveVehicleDropdown();

    if (typeof renderIndexFleetCards === 'function') {
        try { renderIndexFleetCards(); } catch (e) { console.warn('renderIndexFleetCards error:', e); }
    }
    if (typeof renderGarageFleetGrid === 'function') {
        try { renderGarageFleetGrid(); } catch (e) { console.warn('renderGarageFleetGrid error:', e); }
    }
    if (typeof updateFleetCountBadge === 'function') {
        try { updateFleetCountBadge(); } catch (e) { console.warn('updateFleetCountBadge error:', e); }
    }

    try {
        window.dispatchEvent(new CustomEvent('motoro:fleetUpdated', { detail: menuItem }));
    } catch (_) {}

    return enrolled;
}

/**
 * Universal toggle vehicle dropdown function
 */
function toggleVehicleDropdown() {
    const menu = document.getElementById('vehicleDropdownMenu') || document.getElementById('serviceVehicleDropdownMenu');
    if (menu) menu.classList.toggle('hidden');
}
window.toggleVehicleDropdown = toggleVehicleDropdown;
window.changeVehicle = changeVehicle;
window.syncPageFleetDictionaries = syncPageFleetDictionaries;
window.enrollVehicleToBackend = enrollVehicleToBackend;
window.fetchLiveFleetMenu = fetchLiveFleetMenu;
window.getActiveVin = getActiveVin;

// Auto-initialize on load
document.addEventListener('DOMContentLoaded', async () => {
    await fetchLiveFleetMenu();
    syncPageFleetDictionaries();
    updateActiveVehicleBadge();

    // Trigger page update with current active VIN
    const active = getActiveVin();
    if (typeof onVehicleChanged === 'function') onVehicleChanged(active);
    else if (typeof selectVehicle === 'function') selectVehicle(active);
    else if (typeof selectServiceVehicle === 'function') selectServiceVehicle(active);
    else if (typeof selectFleetVehicle === 'function') selectFleetVehicle(active);
    else if (typeof updateVehicleUI === 'function') updateVehicleUI(active);

    // Check if openEnroll query param is set
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('openEnroll') === 'true') {
        setTimeout(() => {
            if (typeof openEnrollVehicleModal === 'function') {
                openEnrollVehicleModal();
            }
        }, 300);
    }
});

// Sync changes across browser tabs
window.addEventListener('storage', (e) => {
    if (e.key === 'motoro_active_vin' || e.key === 'motoro_fleet') {
        fetchLiveFleetMenu().then(() => {
            syncPageFleetDictionaries();
            const active = getActiveVin();
            if (typeof onVehicleChanged === 'function') onVehicleChanged(active);
            else if (typeof selectVehicle === 'function') selectVehicle(active);
            else if (typeof selectServiceVehicle === 'function') selectServiceVehicle(active);
            else if (typeof selectFleetVehicle === 'function') selectFleetVehicle(active);
            else if (typeof updateVehicleUI === 'function') updateVehicleUI(active);
        });
    }
});

