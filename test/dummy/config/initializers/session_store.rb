# StoredSession.configure do |_config|
#   # TODO: find out why setting options here doesn't reach the engine
#   # setting 'stored_session.config' initializer with 'after :load_config_initializers' hook also doesn't work
#   # _config.encrypt = false
# end

Rails.application.configure do
  # Override encrypt's value here. It has higher precedence than from stored_session.yml
  # config.stored_session.encrypt = false
end
