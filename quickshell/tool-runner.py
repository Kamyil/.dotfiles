#!/usr/bin/env python3
"""Small, dependency-free backend for Quickshell's Tools picker."""

import ast
import colorsys
import json
import math
import operator
import os
import re
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path


def copy_value(value):
    import subprocess
    subprocess.run(["wl-copy"], input=value, text=True, check=True)
    success("Copied")

def emit(payload):
    print(json.dumps(payload, separators=(",", ":")))


def success(primary, copy_text=None, details=None, stale=False):
    emit({"ok": True, "primary": primary, "copyText": copy_text or primary,
          "details": details or [], "stale": stale})


def fail(message):
    emit({"ok": False, "error": message})
    raise SystemExit(1)


BINOPS = {ast.Add: operator.add, ast.Sub: operator.sub, ast.Mult: operator.mul,
          ast.Div: operator.truediv, ast.FloorDiv: operator.floordiv,
          ast.Mod: operator.mod, ast.Pow: operator.pow}
UNARYOPS = {ast.UAdd: operator.pos, ast.USub: operator.neg}
FUNCTIONS = {name: getattr(math, name) for name in (
    "sqrt", "sin", "cos", "tan", "asin", "acos", "atan", "log", "log10",
    "exp", "floor", "ceil", "degrees", "radians", "fabs")}
FUNCTIONS.update({"abs": abs, "round": round, "min": min, "max": max})
CONSTANTS = {"pi": math.pi, "e": math.e, "tau": math.tau}


def evaluate(node):
    if isinstance(node, ast.Expression):
        return evaluate(node.body)
    if isinstance(node, ast.Constant) and isinstance(node.value, (int, float)):
        return node.value
    if isinstance(node, ast.BinOp) and type(node.op) in BINOPS:
        left, right = evaluate(node.left), evaluate(node.right)
        if isinstance(node.op, ast.Pow) and abs(right) > 1000:
            raise ValueError("Exponent is too large")
        return BINOPS[type(node.op)](left, right)
    if isinstance(node, ast.UnaryOp) and type(node.op) in UNARYOPS:
        return UNARYOPS[type(node.op)](evaluate(node.operand))
    if isinstance(node, ast.Name) and node.id in CONSTANTS:
        return CONSTANTS[node.id]
    if isinstance(node, ast.Call) and isinstance(node.func, ast.Name) and node.func.id in FUNCTIONS and not node.keywords:
        return FUNCTIONS[node.func.id](*(evaluate(arg) for arg in node.args))
    raise ValueError("Unsupported expression")


def format_number(value):
    if not math.isfinite(float(value)):
        raise ValueError("Result is not finite")
    if float(value).is_integer():
        return str(int(value))
    return f"{value:.12g}"


def calculate(expression):
    if len(expression) > 256:
        fail("Expression is too long")
    try:
        result = evaluate(ast.parse(expression.replace("^", "**"), mode="eval"))
        success(format_number(result))
    except (SyntaxError, ValueError, TypeError, ZeroDivisionError, OverflowError) as error:
        fail(str(error) or "Invalid expression")


UNITS = {
    "m": ("length", 1, "m"), "meter": ("length", 1, "m"), "meters": ("length", 1, "m"),
    "km": ("length", 1000, "km"), "kilometer": ("length", 1000, "km"), "kilometers": ("length", 1000, "km"),
    "cm": ("length", .01, "cm"), "mm": ("length", .001, "mm"),
    "mi": ("length", 1609.344, "mi"), "mile": ("length", 1609.344, "mi"), "miles": ("length", 1609.344, "mi"),
    "yd": ("length", .9144, "yd"), "yard": ("length", .9144, "yd"), "yards": ("length", .9144, "yd"),
    "ft": ("length", .3048, "ft"), "foot": ("length", .3048, "ft"), "feet": ("length", .3048, "ft"),
    "in": ("length", .0254, "in"), "inch": ("length", .0254, "in"), "inches": ("length", .0254, "in"),
    "kg": ("mass", 1, "kg"), "g": ("mass", .001, "g"), "mg": ("mass", .000001, "mg"),
    "lb": ("mass", .45359237, "lb"), "lbs": ("mass", .45359237, "lb"), "pound": ("mass", .45359237, "lb"), "pounds": ("mass", .45359237, "lb"),
    "oz": ("mass", .028349523125, "oz"),
    "l": ("volume", 1, "L"), "liter": ("volume", 1, "L"), "liters": ("volume", 1, "L"), "litre": ("volume", 1, "L"), "litres": ("volume", 1, "L"),
    "ml": ("volume", .001, "mL"), "gal": ("volume", 3.785411784, "gal"),
    "b": ("data", 1, "B"), "kb": ("data", 1000, "kB"), "mb": ("data", 1000**2, "MB"), "gb": ("data", 1000**3, "GB"), "tb": ("data", 1000**4, "TB"),
    "kib": ("data", 1024, "KiB"), "mib": ("data", 1024**2, "MiB"), "gib": ("data", 1024**3, "GiB"), "tib": ("data", 1024**4, "TiB"),
}
TEMP = {"c": "°C", "°c": "°C", "celsius": "°C", "f": "°F", "°f": "°F", "fahrenheit": "°F", "k": "K", "kelvin": "K"}


def temperature(value, source, target):
    celsius = value if source == "°C" else (value - 32) * 5 / 9 if source == "°F" else value - 273.15
    return celsius if target == "°C" else celsius * 9 / 5 + 32 if target == "°F" else celsius + 273.15


def convert(query):
    match = re.fullmatch(r"\s*([+-]?(?:\d+(?:\.\d*)?|\.\d+))\s*([^\s]+)\s+(?:to|in)\s+([^\s]+)\s*", query, re.I)
    if not match:
        fail("Use: 12.5 km to miles")
    value, source_name, target_name = float(match.group(1)), match.group(2).lower(), match.group(3).lower()
    if source_name in TEMP and target_name in TEMP:
        target = TEMP[target_name]
        result = temperature(value, TEMP[source_name], target)
        success(f"{format_number(result)} {target}", format_number(result), [f"{format_number(value)} {TEMP[source_name]} = {format_number(result)} {target}"])
        return
    source, target = UNITS.get(source_name), UNITS.get(target_name)
    if not source or not target:
        fail(f"Unknown unit: {source_name if not source else target_name}")
    if source[0] != target[0]:
        fail("Those units measure different dimensions")
    result = value * source[1] / target[1]
    text = f"{format_number(result)} {target[2]}"
    success(text, format_number(result), [f"{format_number(value)} {source[2]} = {text}"])


def parse_color(value):
    value = value.strip().lower()
    match = re.fullmatch(r"#?([0-9a-f]{3}|[0-9a-f]{6})", value)
    if match:
        raw = match.group(1)
        if len(raw) == 3:
            raw = "".join(char * 2 for char in raw)
        return tuple(int(raw[index:index + 2], 16) for index in (0, 2, 4))
    match = re.fullmatch(r"rgba?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)(?:\s*,[^)]*)?\)", value)
    if match:
        rgb = tuple(int(part) for part in match.groups())
        if all(0 <= part <= 255 for part in rgb):
            return rgb
    raise ValueError("Use HEX or rgb(r, g, b)")


def color(value):
    try:
        red, green, blue = parse_color(value)
    except ValueError as error:
        fail(str(error))
    hue, light, saturation = colorsys.rgb_to_hls(red / 255, green / 255, blue / 255)
    hex_value = f"#{red:02X}{green:02X}{blue:02X}"
    success(hex_value, hex_value, [f"rgb({red}, {green}, {blue})", f"hsl({round(hue * 360)}, {round(saturation * 100)}%, {round(light * 100)}%)"])


def currency(query):
    match = re.fullmatch(r"\s*([+-]?(?:\d+(?:\.\d*)?|\.\d+))\s*([a-z]{3})\s+(?:to|in)\s+([a-z]{3})\s*", query, re.I)
    if not match:
        fail("Use: 150 USD to EUR")
    amount, source, target = float(match.group(1)), match.group(2).upper(), match.group(3).upper()
    cache_dir = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "quickshell-tools"
    cache_file = cache_dir / f"{source}-{target}.json"
    data, stale = None, False
    try:
        url = "https://api.frankfurter.dev/v1/latest?" + urllib.parse.urlencode({"from": source, "to": target})
        request = urllib.request.Request(url, headers={"User-Agent": "quickshell-tools/1.0"})
        with urllib.request.urlopen(request, timeout=4) as response:
            data = json.load(response)
        cache_dir.mkdir(parents=True, exist_ok=True)
        cache_file.write_text(json.dumps({"fetched": int(time.time()), "data": data}))
    except Exception:
        try:
            cached = json.loads(cache_file.read_text())
            data, stale = cached["data"], True
        except Exception:
            fail("Could not fetch an exchange rate and no cached rate exists")
    try:
        rate = float(data["rates"][target])
    except (KeyError, TypeError, ValueError):
        fail("The exchange service did not return that currency pair")
    result = amount * rate
    details = [f"1 {source} = {format_number(rate)} {target}", f"Rate date: {data.get('date', 'unknown')}"]
    if stale:
        details.append("Offline: using the last cached rate")
    success(f"{format_number(result)} {target}", format_number(result), details, stale)


def main():
    if len(sys.argv) < 3:
        fail("Missing tool or input")
    command, value = sys.argv[1], " ".join(sys.argv[2:]).strip()
    if not value:
        fail("Enter a value")
    {"calculate": calculate, "convert": convert, "color": color, "currency": currency, "copy": copy_value}.get(command, lambda _: fail("Unknown tool"))(value)


if __name__ == "__main__":
    main()
