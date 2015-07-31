class RootController < ApplicationController
  def index
    @app_intro = PageSection.find_by_name('app_intro')

    gon.imprisoned_count_timeline_prisoners_path = imprisoned_count_timeline_prisoners_path
    gon.article_incident_counts_articles_path = article_incident_counts_articles_path
    gon.prison_prisoner_counts_prisons_path = prison_prisoner_counts_prisons_path

    @featured_prisoner = Prisoner.where(currently_imprisoned: true).offset(rand(Prisoner.where(currently_imprisoned: true).count)).first
    @featured_prisoner_inc = (@featured_prisoner.blank?) || (@featured_prisoner.incidents.blank?) ? nil : @featured_prisoner.incidents.last

    @currently_imprisoned_count = Prisoner.currently_imprisoned_count
  end

  def about
    @project_description = PageSection.find_by_name('project_description')
  end

  def methodology
    @methodology = PageSection.find_by_name('methodology')
  end

  def disclaimer
    @disclaimer = PageSection.find_by_name('disclaimer')
  end

  def to_csv_zip
    send_file PwCsv.zip_all, type: 'application/zip'
  end
end
