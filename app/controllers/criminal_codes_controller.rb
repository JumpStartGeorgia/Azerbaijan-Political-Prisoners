class CriminalCodesController < ApplicationController
  load_and_authorize_resource

  before_action :set_criminal_code, only: [:show, :edit, :update, :destroy]

  # GET /criminal_codes
  # GET /criminal_codes.json
  def index
    @criminal_codes = CriminalCode.all.order(:name)
  end

  # GET /criminal_codes/1
  # GET /criminal_codes/1.json
  def show
  end

  # GET /criminal_codes/new
  def new
    @criminal_code = CriminalCode.new
  end

  # GET /criminal_codes/1/edit
  def edit
  end

  # POST /criminal_codes
  # POST /criminal_codes.json
  def create
    @criminal_code = CriminalCode.new(criminal_code_params)

    respond_to do |format|
      if @criminal_code.save
        format.html { redirect_to @criminal_code, notice: t('app.msgs.success_created', obj: t('activerecord.models.criminal_code')) }
        format.json { render :show, status: :created, location: @criminal_code }
      else
        format.html { render :new }
        format.json { render json: @criminal_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /criminal_codes/1
  # PATCH/PUT /criminal_codes/1.json
  def update
    respond_to do |format|
      if @criminal_code.update(criminal_code_params)
        format.html { redirect_to @criminal_code, notice: t('app.msgs.success_updated', obj: t('activerecord.models.criminal_code')) }
        format.json { render :show, status: :ok, location: @criminal_code }
      else
        format.html { render :edit }
        format.json { render json: @criminal_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /criminal_codes/1
  # DELETE /criminal_codes/1.json
  def destroy
    @criminal_code.destroy
    respond_to do |format|
      format.html { redirect_to criminal_codes_url, notice: t('app.msgs.success_destroyed', obj: t('activerecord.models.criminal_code')) }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_criminal_code
    @criminal_code = CriminalCode.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def criminal_code_params
    params.require(:criminal_code).permit(:name)
  end
end
