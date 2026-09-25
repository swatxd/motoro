const http = require('http');

function request(method, path, data = null) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: '127.0.0.1',
      port: 8000,
      path: path,
      method: method,
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const req = http.request(options, res => {
      let body = '';
      res.on('data', chunk => (body += chunk));
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, data: JSON.parse(body) });
        } catch (e) {
          resolve({ status: res.statusCode, raw: body });
        }
      });
    });

    req.on('error', err => reject(err));
    if (data) {
      req.write(JSON.stringify(data));
    }
    req.end();
  });
}

async function runTests() {
  console.log('--- Testing All Backend Endpoints ---');

  // 1. Health
  const health = await request('GET', '/health');
  console.log('/health:', health.status === 200 ? 'PASS' : 'FAIL', health.status);

  // 2. Auth OTP send & verify
  const otpSend = await request('POST', '/api/v1/auth/otp/send', { phone_or_email: '9876543210' });
  console.log('/api/v1/auth/otp/send:', otpSend.status === 200 ? 'PASS' : 'FAIL', otpSend.data?.demo_code);
  const otpVerify = await request('POST', '/api/v1/auth/otp/verify', {
    phone_or_email: '9876543210',
    otp_code: otpSend.data?.demo_code || '492810'
  });
  console.log('/api/v1/auth/otp/verify:', otpVerify.status === 200 ? 'PASS' : 'FAIL', otpVerify.data?.access_token ? 'token issued' : 'no token');

  // 3. Vehicles menu
  const menu = await request('GET', '/api/v1/vehicles/menu');
  console.log('/api/v1/vehicles/menu:', menu.status === 200 ? 'PASS' : 'FAIL', `(${menu.data?.length} vehicles)`);

  // 4. Vehicle list
  const vehicles = await request('GET', '/api/v1/vehicles');
  console.log('/api/v1/vehicles:', vehicles.status === 200 ? 'PASS' : 'FAIL', `(${vehicles.data?.length} vehicles)`);

  // 5. Fleet summary
  const summary = await request('GET', '/api/v1/fleet/summary');
  console.log('/api/v1/fleet/summary:', summary.status === 200 ? 'PASS' : 'FAIL');

  // 6. Select vehicle
  const sel = await request('POST', '/api/v1/vehicles/select/IND-KA01-NEXON-EV');
  console.log('/api/v1/vehicles/select/IND-KA01-NEXON-EV:', sel.status === 200 ? 'PASS' : 'FAIL');

  // 7. Telemetry & Location
  const telem = await request('GET', '/api/v1/vehicles/IND-KA01-NEXON-EV/telemetry');
  console.log('/api/v1/vehicles/.../telemetry:', telem.status === 200 ? 'PASS' : 'FAIL');
  const loc = await request('GET', '/api/v1/vehicles/IND-KA01-NEXON-EV/location');
  console.log('/api/v1/vehicles/.../location:', loc.status === 200 ? 'PASS' : 'FAIL');

  // 8. Odometer log
  const odo = await request('POST', '/api/v1/vehicles/IND-KA01-NEXON-EV/odometer', { odometer_km: 15500 });
  console.log('/api/v1/vehicles/.../odometer:', odo.status === 200 ? 'PASS' : 'FAIL', odo.data?.odometer_km);

  // 9. Fuel / Charge log
  const fuel = await request('POST', '/api/v1/vehicles/IND-KA01-NEXON-EV/fuel-charge', {
    amount_litres: 10,
    price_per_litre: 16.5,
    fuel_station: 'Tata Power EZ Charge Kozhikode'
  });
  console.log('/api/v1/vehicles/.../fuel-charge:', fuel.status === 200 ? 'PASS' : 'FAIL');

  // 10. Service schedule
  const srv = await request('POST', '/api/v1/vehicles/IND-KA01-NEXON-EV/service-schedule', {
    service_types: ['Periodic Maintenance', 'High Voltage Check'],
    preferred_date: '2026-09-15',
    service_center: 'Malayalam Tata Motors & EV Care Hub'
  });
  console.log('/api/v1/vehicles/.../service-schedule:', srv.status === 200 ? 'PASS' : 'FAIL', srv.data?.confirmation_code);

  // 11. Wallet recharge
  const wall = await request('POST', '/api/v1/wallet/recharge', {
    amount: 1500,
    payment_method: 'UPI'
  });
  console.log('/api/v1/wallet/recharge:', wall.status === 200 ? 'PASS' : 'FAIL', wall.data?.balance);

  // Re-select XUV700
  await request('POST', '/api/v1/vehicles/select/IND-MH12-XUV700');
  console.log('Restored active vehicle to IND-MH12-XUV700');
}

runTests().catch(console.error);
