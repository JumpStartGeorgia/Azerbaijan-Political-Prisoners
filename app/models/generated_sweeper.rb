# Removes all generated files when any resources belonging to the observed
# models are created, changed, deleted, etc.
class GeneratedSweeper < ActionController::Caching::Sweeper
  observe Prisoner, Prison, Article, Tag, CriminalCode

  def after_commit(_record)
    GeneratedFile.remove
  end
end
