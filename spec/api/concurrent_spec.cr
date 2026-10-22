require "../spec_helper"

private alias Concurrent = TandaCLI::API::Concurrent

private def ok(value : T) : TandaCLI::API::Result(T) forall T
  TandaCLI::API::Result(T).new(value)
end

describe TandaCLI::API::Concurrent do
  describe ".all" do
    it "Keeps each result's own type" do
      text, number, list = Concurrent.all(
        -> : String { "hours" },
        -> : Int32 { 42 },
        -> : Array(Int32) { [1, 2, 3] },
      )

      text.should eq("hours")
      number.should eq(42)
      list.should eq([1, 2, 3])

      typeof(text).should eq(String)
      typeof(number).should eq(Int32)
      typeof(list).should eq(Array(Int32))
    end

    it "Runs the work concurrently" do
      gate = Channel(Nil).new

      first, second = Concurrent.all(
        -> : String { gate.receive; "waited" },
        -> : String { gate.send(nil); "released" },
      )

      first.should eq("waited")
      second.should eq("released")
    end

    it "Returns results in the order the work was given, not the order they finish" do
      gate = Channel(Nil).new

      first, second = Concurrent.all(
        -> : String { gate.receive; "slow" },
        -> : String { gate.send(nil); "fast" },
      )

      first.should eq("slow")
      second.should eq("fast")
    end

    it "Reraises a network error to the caller" do
      expect_raises(TandaCLI::API::NetworkError, "offline") do
        Concurrent.all(
          -> : String { "fine" },
          -> : String { raise TandaCLI::API::NetworkError.new("offline") },
        )
      end
    end

    it "Reraises an unexpected error to the caller instead of hanging" do
      expect_raises(ArgumentError, "nope") do
        Concurrent.all(-> : String { raise ArgumentError.new("nope") })
      end
    end
  end

  describe ".fetch" do
    it "Returns a result per input, in order" do
      results = Concurrent.fetch([3, 1, 2]) { |number| ok(number * 10) }

      results.map(&.or { 0 }).should eq([30, 10, 20])
    end

    it "Returns nothing for no inputs" do
      Concurrent.fetch(Array(Int32).new) { |number| ok(number) }.should be_empty
    end

    it "Reraises a network error to the caller" do
      expect_raises(TandaCLI::API::NetworkError, "offline") do
        Concurrent.fetch([1]) do |number|
          raise TandaCLI::API::NetworkError.new("offline") if number == 1

          ok(number)
        end
      end
    end

    it "Reraises an unexpected error to the caller instead of hanging" do
      expect_raises(ArgumentError, "nope") do
        Concurrent.fetch([1]) do |number|
          raise ArgumentError.new("nope") if number == 1

          ok(number)
        end
      end
    end
  end
end
