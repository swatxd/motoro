"""
Direct unit test script for MOTORO FastAPI backend endpoints
"""
from main import (
    health_check, login, register_vehicle, get_fleet_summary, list_vehicles,
    select_vehicle, control_vehicle, log_odometer, log_fuel_charge, recharge_wallet,
    schedule_service, LoginRequest, RegisterVehicleRequest, VehicleControlRequest,
    OdometerLogRequest, FuelChargeLogRequest, WalletRechargeRequest, ServiceScheduleRequest
)

def run_tests():
    # 1. Health
    h = health_check()
    assert h["status"] == "healthy"
    print("[OK] Health check passed:", h["system"])

    # 2. Login
    auth = login(LoginRequest(email="driver@auradrive.io", password="password123"))
    assert auth.operator_email == "driver@auradrive.io"
    assert auth.access_token.startswith("motoro_jwt_")
    print("[OK] Login passed:", auth.operator_name, "| Session:", auth.session_id)

    # 3. Fleet Summary
    summary = get_fleet_summary()
    assert summary.total_vehicles >= 3
    assert summary.fleet_mileage_km > 0
    print("[OK] Fleet Summary passed: Total vehicles =", summary.total_vehicles, "| Mileage =", summary.fleet_mileage_km)

    # 4. List Vehicles
    vehicles = list_vehicles()
    assert len(vehicles) >= 3
    print("[OK] Vehicles list passed:", [v.name for v in vehicles])

    # 5. Vehicle Select
    sel = select_vehicle("BMW-M3-COMP-2025")
    assert sel["status"] == "success"
    print("[OK] Select vehicle passed:", sel["message"])

    # 6. Remote Controls
    ctrl = control_vehicle("AURADRIVE-2026-X7", VehicleControlRequest(action="toggle_lock"))
    assert ctrl["status"] == "success"
    print("[OK] Control passed:", ctrl["message"])

    ctrl_clim = control_vehicle("AURADRIVE-2026-X7", VehicleControlRequest(action="climate", temperature=21.0))
    assert ctrl_clim["status"] == "success"
    print("[OK] Climate control passed:", ctrl_clim["message"])

    # 7. Odometer Log
    odo = log_odometer("AURADRIVE-2026-X7", OdometerLogRequest(odometer_km=12550))
    assert odo["odometer_km"] == 12550
    print("[OK] Odometer log passed:", odo["message"])

    # 8. Fuel / Charge Log
    fuel = log_fuel_charge("AURADRIVE-2026-X7", FuelChargeLogRequest(amount=25.0, unit="kWh"))
    assert fuel["status"] == "success"
    print("[OK] Fuel/Charge log passed:", fuel["message"])

    # 9. Wallet Recharge
    wall = recharge_wallet(WalletRechargeRequest(amount=50.0))
    assert wall["balance"] > 124.50
    print("[OK] Wallet recharge passed. New balance: $", wall["balance"])

    # 10. Schedule Service
    srv = schedule_service("AURADRIVE-2026-X7", ServiceScheduleRequest(service_type="Brake Check", preferred_date="Next Monday"))
    assert srv["status"] == "success"
    print("[OK] Service scheduling passed:", srv["message"])

    print("\n==========================================")
    print("All 10 MOTORO Backend Endpoints Verified Successfully!")
    print("==========================================")

if __name__ == "__main__":
    run_tests()
