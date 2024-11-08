namespace :stored_session do
  desc "Expire inactive sessions"
  task expire: :environment do
    count = StoredSession::Session.expire

    max_created_age = StoredSession.config.session_max_created_age.ago
    max_updated_age = StoredSession.config.session_max_updated_age.ago

    if count.zero?
      puts "No sessions to expire created before #{max_created_age} or updated before #{max_updated_age}"
    else
      puts "Expired #{count} session(s) created before #{max_created_age} or updated before #{max_updated_age}"
    end
  end

  desc "Queue a job to expire inactive sessions"
  task expire_later: :environment do
    StoredSession::Session.expire_later
    puts "Enqueued session expiration job"
  end
end
