class CreateExistingPageSections < ActiveRecord::Migration
  def up
    I18n.locale = :en

    PageSection.create(
      name: 'project_description',
      label: 'About',
      content: "<p>Prisoners.watch has been created by a group of people who want to shed light on the ongoing attempts by the government of Azerbaijan to limit fundamental rights, most notably freedom of speech, association, and belief. This site presents a database of people who have been deprived of their liberty because they demanded to be heard.</p>\r\n<p>Here you can explore the faces and stories of the people who are or have been in an Azerbaijani prison because they have dared to uncover corruption, expose the truth, or publicly speak their mind.</p>\r\n<p>Moreover, you can now see trends and summary statistics about these prisoners of conscience.</p>\r\n<p>As Azerbaijani civil society remains under attack, this is a work in progress. The data and features found here are constantly being updated and challenged. As Azerbaijan is a member of the Council of Europe, and is a voluntary signatory of all its conventions and statutes, we adhere to the <a href='/en/methdology'>PACE definition</a> of a political prisoner when deciding whether or not to include a prisoner in this database. Other prisoners have been removed from the database at their own request.</p>"
    )

    PageSection.create(
      name: 'app_intro',
      label: 'Application Introduction',
      content: "<p>Azerbaijan's track record on human rights has deteriorated dramatically since 2012. This trend is most evident in the high number of politically motivated arrests, which have targeted human rights defenders, journalists and others. Here you can meet Azerbaijan's political prisoners, and you can explore the scope of Azerbaijan's efforts to stifle freedoms of expression.</p>"
    )

    PageSection.create(
      name: 'disclaimer',
      label: 'Disclaimer',
      content: "<p>The information and data in this site is a work in progress. It is constantly being updated and challenged according to <a href='/en/methdology'>PACE’s definition of a political prisoner</a>.</p>"
    )

    PageSection.create(
      name: 'methodology',
      label: 'Methodology',
      content: ""
    )
  end

  def down
    PageSection.destroy_all
  end
end
