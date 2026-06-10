import pytest
from app.services.compliance.sk244 import run_sk244_check

def test_run_sk244_check_all_pass():
    inputs = {
        "supplier_same_district": True,
        "has_nib": True,
        "has_halal_cert": True,
        "daily_capacity": 1000,
        "required_servings": 500,
        "bpom_compliant": True,
        "has_contract": True,
    }
    result = run_sk244_check(inputs)
    assert result["overall_status"] == "memenuhi"
    assert result["score"] == 100
    assert result["passed_count"] == 6

def test_run_sk244_check_fail_capacity():
    inputs = {
        "supplier_same_district": True,
        "has_nib": True,
        "has_halal_cert": True,
        "daily_capacity": 100,
        "required_servings": 500,
        "bpom_compliant": True,
        "has_contract": True,
    }
    result = run_sk244_check(inputs)
    assert result["overall_status"] == "kurang"
    assert result["passed_count"] == 5
    assert "Lengkapi: Kapasitas produksi memadai" in result["recommendations"]
