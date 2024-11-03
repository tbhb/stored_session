class SolidSession::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  def copy_files
    copy_file "config/session.yml", force: true
  end
end
