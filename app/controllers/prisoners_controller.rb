require 'yaml'

class PrisonersController < ApplicationController
  before_action :redirect_to_newest_url, only: [:show, :edit, :update, :destroy]

  before_action :set_prisoner, only: [:show, :edit, :update, :destroy]
  authorize_resource

  # GET /prisoners
  # GET /prisoners.json
  def index
    @prisoners = Prisoner.with_translations.search_for(params[:q]).with_meta_data.ordered.ordered_date_of_arrest.paginate(page: params[:page])

    respond_to do |format|
      format.html
      format.json
      format.csv do
        send_data Prisoner.to_csv,
                  filename: "prisoners_#{GeneratedFile.timeStamp}.csv",
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
        format.html do
          redirect_to @prisoner,
                      notice: t('shared.msgs.success_created',
                                obj: t('activerecord.models.prisoner', count: 1))
        end
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
        format.html do
          redirect_to @prisoner,
                      notice: t('shared.msgs.success_updated',
                                obj: t('activerecord.models.prisoner', count: 1))
        end
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
      format.html do
        redirect_to prisoners_url,
                    notice: t('shared.msgs.success_destroyed',
                              obj: t('activerecord.models.prisoner', count: 1))
      end
      format.json { head :no_content }
    end
  end

  def incidents_to_csv
    send_data Incident.to_csv,
              filename: "incidents_#{GeneratedFile.timeStamp}.csv",
              type: 'text/csv'
  end

  def imprisoned_count_timeline
    respond_to do |format|
      format.json { render json: File.read(Prisoner.imprisoned_count_timeline_json) }
    end
  end

  private

  # # Use callbacks to share common setup or constraints between actions.
  def set_prisoner
    @prisoner = Prisoner.friendly.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def prisoner_params
    params.require(:prisoner).permit(
      *Prison.globalize_attribute_names,
      :date_of_birth,
      :gender_id,
      :portrait
    )
  end

  # if request uses id instead of slug, corrects to use the right path
  def redirect_to_newest_url
    @prisoner = Prisoner.friendly.find params[:id]
    return false if request.path == (url_for action: action_name, id: @prisoner.slug, only_path: true)
    redirect_to (url_for action: action_name, id: @prisoner.slug, only_path: true), status: :moved_permanently
  end
end
