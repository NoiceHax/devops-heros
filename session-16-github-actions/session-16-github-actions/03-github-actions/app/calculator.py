import re
import sys

OPERATIONS = {
    "+": lambda a, b: a + b,
    "-": lambda a, b: a - b,
    "*": lambda a, b: a * b,
    "/": lambda a, b: divide(a, b),
}

EXPRESSION = re.compile(r"^\s*(-?[\d.]+)\s*([+\-*/])\s*(-?[\d.]+)\s*$")


def add(a, b):
    return a + b


def subtract(a, b):
    return a - b


def multiply(a, b):
    return a * b


def divide(a, b):
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b


def parse(expression):
    match = EXPRESSION.match(expression)
    if not match:
        raise ValueError("Invalid format, use: number operator number")
    return float(match.group(1)), match.group(2), float(match.group(3))


def evaluate(expression):
    a, operator, b = parse(expression)
    return OPERATIONS[operator](a, b)


def main():
    for line in sys.stdin:
        line = line.strip()
        if not line or line.lower() in ("q", "quit"):
            break
        try:
            print(evaluate(line))
        except ValueError as error:
            print(f"Error: {error}")


if __name__ == "__main__":
    main()
