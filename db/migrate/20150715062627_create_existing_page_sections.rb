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
      content: "<h2>How do we decide who are political prisoners?</h2>\r\n<p>Deciding who is or is not a political prisoner is not a random decision, but one founded in a definition. While several definitions exist, each used by various stakeholders, we have decided to use the Parliamentary Assembly of the Council of Europe's (PACE) definition.</p>\r\n<p>This methodology is the most relevant, as Azerbaijan is not only a member of the Council of Europe, but chaired the Council in 2014.</p>\r\n<h2>The definition of political prisoner</h2>\r\n<p><strong>Author(s):</strong> Parliamentary Assembly</p>\r\n<p><strong>Origin</strong>: Assembly debate on 3 October 2012 (33rd Sitting) (see <a href=\"http://assembly.coe.int/nw/xml/XRef/X2H-Xref-ViewHTML.asp?FileID=18995&amp;lang=en\" target=\"_blank\">Doc. 13011</a>, report of the Committee on Legal Affairs and Human Rights, rapporteur: Mr Str&auml;sser). Text adopted by the Assembly on 3 October 2012 (33rd Sitting).</p>\r\n<ol>\r\n<li>The Parliamentary Assembly recalls that the definition of \"political prisoner\" was elaborated within the Council of Europe in 2001 by the independent experts of the Secretary General, mandated to assess cases of alleged political prisoners in Armenia and Azerbaijan in the context of the accession of the two States to the Organisation.</li>\r\n<li>The Parliamentary Assembly notes that the criteria put forward by the above-mentioned experts were inspired by, inter alia, the specific circumstances of the civil war in Namibia in 1989. They were applied to cases with regard to two countries during their accession to the Council of Europe and have not until now been subject to comprehensive debate or explicit approval by the Parliamentary Assembly.</li>\r\n<li>The Assembly reaffirms its support for these criteria, summed up as follows:\r\n<p>\"A person deprived of his or her personal liberty is to be regarded as a 'political prisoner':</p>\r\n<ol type=\"a\">\r\n<li>if the detention has been imposed in violation of one of the fundamental guarantees set out in the European Convention on Human Rights and its Protocols (ECHR), in particular freedom of thought, conscience and religion, freedom of expression and information, freedom of assembly and association;</li>\r\n<li>if the detention has been imposed for purely political reasons without connection to any offence;</li>\r\n<li>if, for political motives, the length of the detention or its conditions are clearly out of proportion to the offence the person has been found guilty of or is suspected of;</li>\r\n<li>if, for political motives, he or she is detained in a discriminatory manner as compared to other persons; or,</li>\r\n<li>if the detention is the result of proceedings which were clearly unfair and this appears to be connected with political motives of the authorities.\" (SG/Inf(2001)34, paragraph 10).</li>\r\n</ol>\r\n</li>\r\n<li>Those deprived of their personal liberty for terrorist crimes shall not be considered political prisoners if they have been prosecuted and sentenced for such crimes according to national legislation and the European Convention on Human Rights (ETS No. 5).</li>\r\n<li>The Assembly invites the competent authorities of all the member States of the Council of Europe to reassess the cases of any alleged political prisoners by application of the above-mentioned criteria and to release or retry any such prisoners as appropriate.</li>\r\n</ol>\r\n<p><em>Source: </em><a href=\"http://assembly.coe.int/nw/xml/XRef/Xref-XML2HTML-en.asp?fileid=19150&amp;lang=EN\" target=\"_blank\"><em>http://assembly.coe.int/nw/xml/XRef/Xref-XML2HTML-en.asp?fileid=19150&amp;lang=EN</em></a></p>"
    )
  end

  def down
    PageSection.destroy_all
  end
end
