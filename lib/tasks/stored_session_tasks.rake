namespace :stored_session do
  desc "Expire inactive sessions"
  task expire: :environment do
    StoredSession::Session.expire
  end

  desc "Queue a job to expire inactive sessions"
  task "expire_later" => :environment do
    StoredSession::Session.expire_later
  end
end
