class Order
  def initialize(coupon:)
    @coupon = coupon
  end

  def coupon_valid?
    @coupon.valid?
  end

  def total

  end

end

class CouponStub
  def valid?
    true
  end
end

describe Order do
  it "responds to total" do
    order = Order.new(coupon: nil) # dummy!
    expect{order.total}.to_not raise_error
  end

  it "checks if coupon is valid" do
    coupon_stub = CouponStub.new

    order = Order.new(coupon: coupon_stub)
    expect(order.coupon_valid?).to eq true
  end
end
