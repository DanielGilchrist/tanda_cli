require "./spec_helper"

Spectator.describe Tanda::CLI::Current do
  before_each do
    Tanda::CLI::Current.reset!
  end

  context "Current user" do
    it "Raises when Current.user is called without a user set" do
      expect_raises Tanda::CLI::Current::UserNotSet do
        Tanda::CLI::Current.user
      end
    end

    context "Setting user" do
      let(user) { Tanda::CLI::Current::User.new(id: 1, time_zone: "Europe/London") }

      it "Returns set user when calling Current.user" do
        Tanda::CLI::Current.set_user!(user)
        expect(Tanda::CLI::Current.user).to eq(user)
      end

      it "Raises when Current.set_user! is called a second time" do
        Tanda::CLI::Current.set_user!(user)
        expect_raises Tanda::CLI::Current::UserAlreadySet do
          Tanda::CLI::Current.set_user!(user)
        end
      end
    end
  end
end
