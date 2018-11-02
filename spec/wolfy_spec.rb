class Order
  attr_accessor :discounted

  def initialize(coupon:, coupon_gateway:)
    @coupon = coupon
    @discounted = false
    @coupon_gateway = coupon_gateway
  end

  def process_discount
    if coupon_valid? && coupon_has_been_used?
      @coupon.invalidate
      @discounted = true
    end
  end

  def total
    process_discount
  end

  def coupon_valid?
    @coupon.valid?
  end

  private
  def coupon_has_been_used?
    @coupon_gateway.check_coupon(@coupon.code)
  end
end

class CouponGatewayFake

  def initialize
    @used_coupons = []
  end

  def check_coupon(coupon_code)
    if @used_coupons.include?(coupon_code)
      false
    else
      @used_coupons << coupon_code
      true
    end
  end
end

class CouponGatewayStub
  def check_coupon(coupon_code)
    true
  end
end

class ValidCouponStub
  def valid?
    true
  end

  def invalidate

  end

  def code
    'code'
  end
end

class CouponSpy
  def initialize
    @invalidate_called = 0
  end

  def code

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

class CouponGatewayMock

  def initialize(test_suite)
    @check_coupon_called = false
    @test_suite = test_suite
  end

  def check_coupon(coupon_code)
    @coupon_code = coupon_code
    @check_coupon_called = true
  end

  def verify_check_coupon_with(coupon_code)
    @test_suite.expect(@coupon_code).to @test_suite.eq(coupon_code)
    @test_suite.expect(@check_coupon_called).to @test_suite.eq(true)
  end
end

describe Order do
  xit "responds to total" do
    order = Order.new(coupon: nil) # dummy!
    expect{order.total}.to_not raise_error
  end
  #
  it "checks if coupon is valid" do
    coupon_stub = ValidCouponStub.new
    coupon_gateway_stub = CouponGatewayStub.new
    order = Order.new(coupon: coupon_stub, coupon_gateway: coupon_gateway_stub)
    expect(order.coupon_valid?).to eq true
  end

  it "invalidates the coupon when discount is applied" do
    coupon_spy = CouponSpy.new
    coupon_gateway_stub = CouponGatewayStub.new
    order = Order.new(coupon: coupon_spy, coupon_gateway: coupon_gateway_stub)
    order.total
    expect(coupon_spy.invalidate_called?).to eq(true)
  end

  it "doesn't let a coupon be used twice" do
    coupon_stub = ValidCouponStub.new
    coupon_gateway_fake = CouponGatewayFake.new
    order = Order.new(coupon: coupon_stub, coupon_gateway: coupon_gateway_fake)
    order.total

    expect(order.discounted).to eq(true)

    order2 = Order.new(coupon: coupon_stub, coupon_gateway: coupon_gateway_fake)
    order2.total
    expect(order2.discounted).to eq(false)
  end

  it "calls checks the coupon with the correct code" do
    coupon_gateway_mock = CouponGatewayMock.new(self)
    coupon_stub = ValidCouponStub.new
    order = Order.new(coupon: coupon_stub, coupon_gateway: coupon_gateway_mock)
    order.total

    coupon_gateway_mock.verify_check_coupon_with(coupon_stub.code)
  end
end
