require 'yaml'

class PrisonersController < ApplicationController
  load_and_authorize_resource

  before_action :set_prisoner, only: [:show, :edit, :update, :destroy]
  before_action :set_form_collections, only: [:new, :edit]
  before_action :set_gon_variables

  # GET /prisoners
  # GET /prisoners.json
  def index
    @prisoners = Prisoner.all.includes(:incidents).order(:name)

    respond_to do |format|
      format.html
      format.json
      format.csv do
        send_data Prisoner.to_csv,
                  filename: "prisoners_#{fileTimeStamp}.csv",
                  type: 'text/csv'
      end
    end
  end

  # GET /prisoners/1
  # GET /prisoners/1.json
  def show
  end

  # GET /prisoners/new
  def new
    @prisoner = Prisoner.new
  end

  # GET /prisoners/1/edit
  def edit
  end

  # POST /prisoners
  # POST /prisoners.json
  def create
    @prisoner = Prisoner.new(prisoner_params)

    respond_to do |format|
      if @prisoner.save
        format.html { redirect_to @prisoner, notice: t('app.msgs.success_created', obj: t('activerecord.models.prisoner')) }
        format.json { render :show, status: :created, location: @prisoner }
      else
        format.html { render :new }
        format.json { render json: @prisoner.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /prisoners/1
  # PATCH/PUT /prisoners/1.json
  def update
    respond_to do |format|
      if @prisoner.update(prisoner_params)
        format.html { redirect_to @prisoner, notice: t('app.msgs.success_updated', obj: t('activerecord.models.prisoner')) }
        format.json { render :show, status: :ok, location: @prisoner }
      else
        format.html { render :edit }
        format.json { render json: @prisoner.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /prisoners/1
  # DELETE /prisoners/1.json
  def destroy
    @prisoner.destroy
    respond_to do |format|
      format.html { redirect_to prisoners_url, notice: t('app.msgs.success_destroyed', obj: t('activerecord.models.prisoner')) }
      format.json { head :no_content }
    end
  end

  def incidents_to_csv
    send_data Incident.to_csv,
              filename: "incidents_#{fileTimeStamp}.csv",
              type: 'text/csv'
  end

  def imprisoned_count_timeline
    unless File.exist?(Rails.public_path.join('system', 'json', 'imprisoned_count_timeline.json'))
      Prisoner.generate_imprisoned_count_timeline_json
    end

    respond_to do |format|
      format.json { render json: File.read(Rails.public_path.join('system', 'json', 'imprisoned_count_timeline.json')) }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_prisoner
    @prisoner = Prisoner.find(params[:id])
  end

  def set_form_collections
    @tags = Tag.all.order(:name)
  end

  def set_gon_variables
    gon.tinymce_config = YAML.load_file('config/tinymce.yml')
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def prisoner_params
    params.require(:prisoner).permit(:name, :portrait, incidents_attributes:
        [:id,
         :date_of_arrest,
         :description_of_arrest,
         :prison_id,
         :date_of_release,
         :description_of_release,
         :_destroy,
         article_ids: [],
         tag_ids: []
        ])
  end
end
