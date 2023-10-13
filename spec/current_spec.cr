require "./spec_helper"

Spectator.describe TandaCLI::Current do
  context "Current user" do
    it "Raises when Current.user is called without a user set" do
      expect_raises TandaCLI::Current::UserNotSet do
        TandaCLI::Current.user
      end
    end

    context "Setting user" do
      let(user) { TandaCLI::Current::User.new(id: 1, organisation_name: "Pokemart", time_zone: "Europe/London") }

      it "Returns set user when calling Current.user" do
        TandaCLI::Current.set_user!(user)
        expect(TandaCLI::Current.user).to eq(user)
      end

      it "Raises when Current.set_user! is called a second time" do
        TandaCLI::Current.set_user!(user)
        expect_raises TandaCLI::Current::UserAlreadySet do
          TandaCLI::Current.set_user!(user)
        end
      end
    end
  end
end
