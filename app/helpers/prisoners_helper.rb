module PrisonersHelper
  # Used on prisoner form; creates array of gender ids and translated terms
  def gender_collection
    [[t('activerecord.attributes.prisoner.gender.female'),
      Prisoner.get_gender_id_from_key(:female)],
     [t('activerecord.attributes.prisoner.gender.male'),
      Prisoner.get_gender_id_from_key(:male)],
     [t('activerecord.attributes.prisoner.gender.other'),
      Prisoner.get_gender_id_from_key(:other)]]
  end
end
