require "../spec_helper"

describe TandaCLI::Commands::CurrentUser do
  describe TandaCLI::Commands::CurrentUser::Display do
    it "Shows the current user" do
      context = run(["current_user", "display"])
      context.stdout.to_s.should eq("Test Organisation (User 1)\n")
    end

    it "Says nothing is set when no organisation is current" do
      context = run(["current_user", "display"], config_fixture: :no_current_user)
      context.stdout.to_s.should eq("A current user hasn't been set!\n")
    end
  end

  describe TandaCLI::Commands::CurrentUser::List do
    it "Lists every organisation and marks the current one" do
      context = run(["current_user", "list"], config_fixture: :multiple_organisations)

      context.stdout.to_s.should eq(<<-OUTPUT)
        Test Organisation (current)
        User ID: 1

        Other Organisation
        User ID: 2


        OUTPUT
    end

    it "Marks nothing as current when no organisation is current" do
      context = run(["current_user", "list"], config_fixture: :no_current_user)
      context.stdout.to_s.should_not contain("(current)")
    end
  end

  describe TandaCLI::Commands::CurrentUser::Set do
    it "Sets the current user by user id" do
      context = run(["current_user", "set", "2"], config_fixture: :multiple_organisations)

      context.state.current_organisation?.try(&.user_id).should eq(2)
      context.stdout.to_s.should eq("Success: The current user has been set to \"2 in Other Organisation\"\n")
    end

    it "Sets the current user by organisation name" do
      context = run(["current_user", "set", "other"], config_fixture: :multiple_organisations)

      context.state.current_organisation?.try(&.name).should eq("Other Organisation")
    end

    it "Unsets the previously current organisation" do
      context = run(["current_user", "set", "2"], config_fixture: :multiple_organisations)

      context.state.organisations.select(&.current?).map(&.user_id).should eq([2])
    end

    it "Errors when nothing matches" do
      context = run(["current_user", "set", "nope"], config_fixture: :multiple_organisations)

      context.exit_status.should eq(1)
      context.stderr.to_s.should eq("Error: Invalid argument \"nope\"\n")
      context.state.current_organisation?.try(&.user_id).should eq(1)
    end
  end
end
