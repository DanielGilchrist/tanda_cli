require "./spec_helper"

describe Tanda::CLI::Current do
  context "Setting user" do
    before_each do
      Tanda::CLI::Current.reset!
    end

    it "Raises when Current.user! is called without a user set" do
      expect_raises Tanda::CLI::Current::UserNotSet do
        puts Tanda::CLI::Current.user!
      end
    end

    it "Returns set user when calling Current.user!" do
      user = Tanda::CLI::Current::User.new(id: 1, time_zone: "Europe/London")

      Tanda::CLI::Current.set_user!(user)
      Tanda::CLI::Current.user!.should eq(user)
    end

    it "Raises when Current.set_user! is called a second time" do
      user = Tanda::CLI::Current::User.new(id: 1, time_zone: "Europe/London")

      Tanda::CLI::Current.set_user!(user)
      expect_raises Tanda::CLI::Current::UserAlreadySet do
        Tanda::CLI::Current.set_user!(user)
      end
    end
  end
end