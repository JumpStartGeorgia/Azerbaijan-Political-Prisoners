class TagsController < ApplicationController
  # before_action :redirect_to_newest_url, only: [:show, :edit, :update, :destroy]

  load_and_authorize_resource :find_by => :slug

  before_action :set_tag, only: [:show, :edit, :update, :destroy]
  before_action :set_prisoners_with_tag, only: [:show]
  before_action :set_gon_variables

  # GET /tags
  # GET /tags.json
  def index
    @tags = Tag.all.order(:name)

    respond_to do |format|
      format.html
      format.json
      format.csv do
        send_data Tag.to_csv,
                  filename: "tags_#{fileTimeStamp}.csv",
                  type: 'text/csv'
      end
    end
  end

  # GET /tags/1
  # GET /tags/1.json
  def show
  end

  # GET /tags/new
  def new
    @tag = Tag.new
  end

  # GET /tags/1/edit
  def edit
  end

  # POST /tags
  # POST /tags.json
  def create
    @tag = Tag.new(tag_params)

    respond_to do |format|
      if @tag.save
        format.html { redirect_to @tag, notice: t('app.msgs.success_created', obj: t('activerecord.models.tag')) }
        format.json { render :show, status: :created, location: @tag }
      else
        format.html { render :new }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tags/1
  # PATCH/PUT /tags/1.json
  def update
    respond_to do |format|
      if @tag.update(tag_params)
        format.html { redirect_to @tag, notice: t('app.msgs.success_updated', obj: t('activerecord.models.tag')) }
        format.json { render :show, status: :ok, location: @tag }
      else
        format.html { render :edit }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.json
  def destroy
    @tag.destroy
    respond_to do |format|
      format.html { redirect_to tags_url, notice: t('app.msgs.success_destroyed', obj: t('activerecord.models.tag')) }
      format.json { head :no_content }
    end
  end

  private

  # # Use callbacks to share common setup or constraints between actions.
  def set_tag
    @tag = Tag.friendly.find(params[:id])
  end

  def set_prisoners_with_tag
    @prisoners_with_tag = Prisoner.by_tag(@tag.id)
  end

  def set_gon_variables
    gon.tinymce_config = YAML.load_file('config/tinymce.yml')
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def tag_params
    params.require(:tag).permit(:name, :description)
  end

  # using history for friendly_ids
  # so this checks if an old slug is being used, if so, redirect to correct one
  # def redirect_to_newest_url
  #   @tag = Tag.friendly.find params[:id]

  #   if request.path != tag_path(@tag)
  #     return redirect_to @tag, :status => :moved_permanently
  #   end
  # end


end
