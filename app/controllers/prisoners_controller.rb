class PrisonersController < ApplicationController
  before_action :set_prisoner, only: [:show, :edit, :update, :destroy]

  # GET /prisoners
  # GET /prisoners.json
  def index
    @prisoners = Prisoner.all
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
        format.html { redirect_to @prisoner, notice: 'Prisoner was successfully created.' }
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
        format.html { redirect_to @prisoner, notice: 'Prisoner was successfully updated.' }
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
      format.html { redirect_to prisoners_url, notice: 'Prisoner was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_prisoner
      @prisoner = Prisoner.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def prisoner_params
      params.require(:prisoner).permit(:name, incidents_attributes:
          [:id,
           :date_of_arrest,
           :description_of_arrest,
           :prison,
           :type,
           :subtype,
           :date_of_release,
           :description_of_release,
           :_destroy])
    end
end
