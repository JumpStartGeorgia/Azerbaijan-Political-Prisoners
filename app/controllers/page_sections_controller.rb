class PageSectionsController < ApplicationController
  before_action :set_page_section, only: [:show, :edit, :update, :destroy]

  # GET /page_sections
  # GET /page_section.json
  def index
    @page_sections = PageSection.all
  end

  # GET /page_sections/1
  # GET /page_sections/1.json
  def show
  end

  # GET /page_sections/new
  def new
    @page_section = PageSection.new
  end

  # GET /page_sections/1/edit
  def edit
  end

  # POST /page_sections
  # POST /page_sections.json
  def create
    @page_section = PageSection.new(page_params)

    respond_to do |format|
      if @page_section.save
        format.html { redirect_to @page_section, notice: 'Page Section was successfully created.' }
        format.json { render :show, status: :created, location: @page_section }
      else
        format.html { render :new }
        format.json { render json: @page_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /page_sections/1
  # PATCH/PUT /page_sections/1.json
  def update
    respond_to do |format|
      if @page_section.update(page_params)
        format.html { redirect_to @page_section, notice: 'Page Section was successfully updated.' }
        format.json { render :show, status: :ok, location: @page_section }
      else
        format.html { render :edit }
        format.json { render json: @page_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /page_sections/1
  # DELETE /page_sections/1.json
  def destroy
    @page_section.destroy
    respond_to do |format|
      format.html { redirect_to pages_url, notice: 'Page Section was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  before_action :set_tinymce_config

  def set_tinymce_config
    gon.tinymce_config = YAML.load_file('config/tinymce.yml')
  end
  private :set_tinymce_config

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page_section
      @page_section = PageSection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def page_section_params
      params.require(:page_section).permit(:name, :title, :content)
    end
end
