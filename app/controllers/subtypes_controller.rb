class SubtypesController < ApplicationController
  before_action :set_subtype, only: [:show, :edit, :update, :destroy]
  before_action :set_gon_variables

  # GET /subtypes
  # GET /subtypes.json
  def index
    @subtypes = Subtype.all
  end

  # GET /subtypes/1
  # GET /subtypes/1.json
  def show
  end

  # GET /subtypes/new
  def new
    @subtype = Subtype.new
  end

  # GET /subtypes/1/edit
  def edit
  end

  # POST /subtypes
  # POST /subtypes.json
  def create
    @subtype = Subtype.new(subtype_params)

    respond_to do |format|
      if @subtype.save
        format.html { redirect_to @subtype, notice: 'Subtype was successfully created.' }
        format.json { render :show, status: :created, location: @subtype }
      else
        format.html { render :new }
        format.json { render json: @subtype.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /subtypes/1
  # PATCH/PUT /subtypes/1.json
  def update
    respond_to do |format|
      if @subtype.update(subtype_params)
        format.html { redirect_to @subtype, notice: 'Subtype was successfully updated.' }
        format.json { render :show, status: :ok, location: @subtype }
      else
        format.html { render :edit }
        format.json { render json: @subtype.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subtypes/1
  # DELETE /subtypes/1.json
  def destroy
    @subtype.destroy
    respond_to do |format|
      format.html { redirect_to subtypes_url, notice: 'Subtype was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subtype
      @subtype = Subtype.find(params[:id])
    end

    def set_gon_variables
      gon.tinymce_config = YAML.load_file("config/tinymce.yml")
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def subtype_params
      params.require(:subtype).permit(:name, :type_id, :description)
    end
end
