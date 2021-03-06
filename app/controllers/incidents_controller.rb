class IncidentsController < ApplicationController
  before_action :set_incident, only: [:edit, :update, :destroy]
  authorize_resource

  before_action :set_form_variables, only: [:new, :edit]
  before_action :set_tinymce_config_gon
  before_action :set_prisoner

  # GET /prisoners/{@prisoner.slug}/incidents/new
  def new
    @incident = Incident.new
  end

  # GET /prisoners/{@prisoner.slug}/incidents/1/edit
  def edit
  end

  # POST /prisoners/{@prisoner.slug}/incidents
  # POST /prisoners/{@prisoner.slug}/incidents.json
  def create
    @incident = Incident.new(incident_params)
    @incident.prisoner_id = @prisoner.id

    respond_to do |format|
      if @incident.save
        format.html do
          redirect_to @prisoner,
                      notice: t('shared.msgs.success_created',
                                obj: t('activerecord.models.incident', count: 1))
        end
        format.json { render :show, status: :created, location: @prisoner }
      else
        set_form_variables
        format.html { render :new }
        format.json { render json: @incident.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /prisoners/{@prisoner.slug}/incidents/1
  # PATCH/PUT /prisoners/{@prisoner.slug}/incidents/1.json
  def update
    respond_to do |format|
      if @incident.update(incident_params)
        format.html do
          redirect_to @prisoner,
                      notice: t('shared.msgs.success_updated',
                                obj: t('activerecord.models.incident', count: 1))
        end
        format.json { render :show, status: :ok, location: @prisoner }
      else
        set_form_variables
        format.html { render :edit }
        format.json do
          render json: @incident.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /prisoners/{@prisoner.slug}/incidents/1
  # DELETE /prisoners/{@prisoner.slug}/incidents/1.json
  def destroy
    @incident.destroy
    respond_to do |format|
      format.html do
        redirect_to @prisoner,
                    notice: t('shared.msgs.success_destroyed',
                              obj: t('activerecord.models.incident', count: 1))
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_incident
    @incident = Incident.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def incident_params
    params.require(:incident).permit(
      :id,
      :prisoner_id,
      :date_of_arrest,
      :prison_id,
      :date_of_release,
      *Incident.globalize_attribute_names,
      article_ids: [],
      tag_ids: []
    )
  end

  def set_tinymce_config_gon
    gon.tinymce_config = YAML.load_file('config/tinymce.yml')
  end

  # Set tags and prisons to be used in dropdowns on form
  def set_form_variables
    @articles = CriminalCode.all.includes(:articles).with_translations
    @tags = Tag.includes(:translations).order(:name)
    @prisons = Prison.includes(:translations).order(:name)

    gon.select_charges = t('shared.actions.with_obj.select',
                           obj: t('activerecord.models.charge', count: 999))
    gon.select_tags = t('shared.actions.with_obj.select',
                        obj: t('activerecord.models.tag', count: 999))                           
  end

  def set_prisoner
    @prisoner = Prisoner.friendly.find(params[:prisoner_id])
    not_found(prisoners_path) if @prisoner.blank?
  end
end
