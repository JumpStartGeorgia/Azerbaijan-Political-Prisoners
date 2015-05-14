class PrisonsController < ApplicationController
  load_and_authorize_resource

  before_action :set_prison, only: [:show, :edit, :update, :destroy]
  before_action :set_prisoners_in_prison, only: [:show]
  before_action :set_gon_variables

  # GET /prisons
  # GET /prisons.json
  def index
    @prisons = Prison.all

    respond_to do |format|
      format.html
      format.json
      format.csv do
        send_data Prison.to_csv,
                  filename: "prisons_#{fileTimeStamp}.csv",
                  type: 'text/csv'
      end
    end
  end

  # GET /prisons/1
  # GET /prisons/1.json
  def show
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
        format.html { redirect_to @prison, notice: 'Prison was successfully created.' }
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
        format.html { redirect_to @prison, notice: 'Prison was successfully updated.' }
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
      format.html { redirect_to prisons_url, notice: 'Prison was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def prison_prisoner_counts
    if !File.exists?(Rails.public_path.join('system', 'json', 'prison_prisoner_count_chart.json'))
      Prison.generate_prison_prisoner_count_chart_json
    end

    respond_to do |format|
      format.json { render json: File.read(Rails.public_path.join('system', 'json', 'prison_prisoner_count_chart.json')) }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_prison
      @prison = Prison.find(params[:id])
    end

    def set_prisoners_in_prison
      @prisoners_in_prison = Prisoner.by_prison(@prison.id)
    end

    def set_gon_variables
      gon.tinymce_config = YAML.load_file("config/tinymce.yml")
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def prison_params
      params.require(:prison).permit(:name, :description)
    end
end
