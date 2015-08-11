class PrisonsController < ApplicationController
  before_action :redirect_to_newest_url, only: [:show, :edit, :update, :destroy]

  before_action :set_prison, only: [:show, :edit, :update, :destroy]
  authorize_resource

  before_action :set_prisoners_in_prison, only: [:show]
  before_action :set_gon_variables

  # GET /prisons
  # GET /prisons.json
  def index
    @prisons = Prison.with_current_and_all_prisoner_count

    respond_to do |format|
      format.html
      format.json
      format.csv do
        send_data Prison.to_csv,
                  filename: "prisons_#{GeneratedFile.timeStamp}.csv",
                  type: 'text/csv'
      end
    end
  end

  # GET /prisons/1
  # GET /prisons/1.json
  def show
    @prison_with_counts = Prison.with_current_and_all_prisoner_count(@prison.id).first
  end

  # GET /prisons/new
  def new
    @prison = Prison.new
  end

  # GET /prisons/1/edit
  def edit
  end

  # POST /prisons
  # POST /prisons.json
  def create
    @prison = Prison.new(prison_params)

    respond_to do |format|
      if @prison.save
        format.html do
          redirect_to @prison,
                      notice: t('shared.msgs.success_created',
                                obj: t('activerecord.models.prison', count: 1))
        end
        format.json { render :show, status: :created, location: @prison }
      else
        format.html { render :new }
        format.json { render json: @prison.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /prisons/1
  # PATCH/PUT /prisons/1.json
  def update
    respond_to do |format|
      if @prison.update(prison_params)
        format.html do
          redirect_to @prison,
                      notice: t('shared.msgs.success_updated',
                                obj: t('activerecord.models.prison', count: 1))
        end
        format.json { render :show, status: :ok, location: @prison }
      else
        format.html { render :edit }
        format.json { render json: @prison.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /prisons/1
  # DELETE /prisons/1.json
  def destroy
    @prison.destroy
    respond_to do |format|
      format.html do
        redirect_to prisons_url,
                    notice: t('shared.msgs.success_destroyed',
                              obj: t('activerecord.models.prison', count: 1))
      end
      format.json { head :no_content }
    end
  end

  def prison_prisoner_counts
    respond_to do |format|
      format.json { render json: File.read(Prison.current_prisoner_counts_chart_json) }
    end
  end

  private

  # # Use callbacks to share common setup or constraints between actions.
  def set_prison
    @prison = Prison.friendly.find(params[:id])
  end

  def set_prisoners_in_prison
    @prisoners_in_prison = Prisoner.by_prison(@prison.id)
  end

  def set_gon_variables
    gon.tinymce_config = YAML.load_file('config/tinymce.yml')
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def prison_params
    params.require(:prison).permit(Prison.globalize_attribute_names)
  end

  # if request uses id instead of slug, corrects to use the right path
  def redirect_to_newest_url
    @prison = Prison.friendly.find params[:id]
    return false if request.path == (url_for action: action_name, id: @prison.slug, only_path: true)
    redirect_to (url_for action: action_name, id: @prison.slug, only_path: true), status: :moved_permanently
  end
end
