# Removes all generated files when any resources belonging to the observed
# models are created, changed, deleted, etc.
class GeneratedSweeper < ActionController::Caching::Sweeper
  observe Prisoner, Prison, Article, Tag, CriminalCode

  def after_commit(_record)
    remove_generated
  end

  def remove_generated
    generated_dir = Rails.public_path.join('generated')
    FileUtils.remove_dir(generated_dir, true) if File.directory?(generated_dir)
  end
end
