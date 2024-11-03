desc "Install SolidSession and its dependencies"
task "solid_session:install" do
  Rails::Command.invoke :generate, [ "solid_session:install" ]
end
