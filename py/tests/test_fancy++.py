import pytest

from fancy import fancy


def test_fancy_widget():
    w = fancy.Fancy++Widget(-3)
    assert w.get() == -3


@pytest.mark.parametrize("member_t, member_val", [(int, 1), (float, 3.1), (bool, False)])
def test_fancy_gadget(member_t, member_val):
    g = fancy.Fancy++Gadget[member_t](member_val)
    assert g.get() == pytest.approx(member_val)
