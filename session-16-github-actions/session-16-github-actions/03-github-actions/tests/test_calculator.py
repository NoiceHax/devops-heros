import pytest

from app.calculator import add, subtract, multiply, divide, evaluate, parse


def test_add():
    assert add(10, 5) == 15


def test_subtract():
    assert subtract(10, 5) == 5


def test_multiply():
    assert multiply(10, 5) == 50


def test_divide():
    assert divide(10, 5) == 2


def test_divide_by_zero():
    with pytest.raises(ValueError):
        divide(10, 0)


def test_parse():
    assert parse("10 + 5") == (10.0, "+", 5.0)


def test_parse_no_spaces():
    assert parse("3*7") == (3.0, "*", 7.0)


def test_parse_negative():
    assert parse("-4 + 9") == (-4.0, "+", 9.0)


def test_parse_invalid():
    with pytest.raises(ValueError):
        parse("10 ** 5")


def test_evaluate():
    assert evaluate("100 / 4") == 25


def test_evaluate_divide_by_zero():
    with pytest.raises(ValueError):
        evaluate("1 / 0")
