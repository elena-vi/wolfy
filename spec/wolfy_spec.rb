class Order
  def initialize(coupon:)
    @coupon = coupon
    @discounted = false
  end

  def coupon_valid?
    @coupon.valid?
  end

  def process_discount
    if coupon_valid?
      @coupon.invalidate
      @coupon.invalidate
    end
  end

  def total
    process_discount
  end
end

class ValidCouponStub
  def valid?
    true
  end
end

class CouponSpy
  def initialize
    @invalidate_called = 0
  end

  def valid?
    true
  end

  def invalidate
    @invalidate_called = true
  end

  def invalidate_called?
    @invalidate_called
  end
end

describe Order do
  xit "responds to total" do
    order = Order.new(coupon: nil) # dummy!
    expect{order.total}.to_not raise_error
  end

  it "checks if coupon is valid" do
    coupon_stub = ValidCouponStub.new
    order = Order.new(coupon: coupon_stub)
    expect(order.coupon_valid?).to eq true
  end

  it "invalidates the coupon when discount is applied" do
    coupon_spy = CouponSpy.new
    order = Order.new(coupon: coupon_spy)
    order.total
    expect(coupon_spy.invalidate_called?).to eq(true)
  end
end
