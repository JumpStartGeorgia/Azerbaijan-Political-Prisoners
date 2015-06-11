class StripSpaces < ActiveRecord::Migration
  def up
    Prisoner.transaction do
      Article.find_each(&:save)
      CriminalCode.find_each(&:save)
      Incident.find_each(&:save)
      Prison.find_each(&:save)
      Prisoner.find_each(&:save)
      Tag.find_each(&:save)
    end
  end

  def down
    # do nothing
  end
end
