"""Collect/run unchanged upstream tests on Windows; never emulate resource limits."""
import os
import sys
import types
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORK = ROOT / "assignments" / "assignment1-basics"
os.chdir(WORK)
sys.path.insert(0, str(WORK))
os.environ.setdefault("PYTEST_DISABLE_PLUGIN_AUTOLOAD", "1")

if sys.platform == "win32":
    resource = types.ModuleType("resource")

    def unsupported(name):
        if name.startswith("__"):
            raise AttributeError(name)
        raise RuntimeError(f"resource.{name} is unavailable on Windows; use Linux for resource-limit tests")

    resource.__getattr__ = unsupported
    sys.modules["resource"] = resource

import pytest

raise SystemExit(pytest.main(["-p", "pytest_timeout", *sys.argv[1:]]))
