class ArticlesController < ApplicationController
  load_and_authorize_resource

  before_action :set_article, only: [:show, :edit, :update, :destroy]
  before_action :set_prisoners_with_article, only: [:show]
  before_action :set_gon_variables

  # GET /articles
  # GET /articles.json
  def index
    @articles = Article.all.order(criminal_code_id: :asc, number: :asc)
    @criminal_codes = CriminalCode.all
    puts @criminal_codes[0].id

    respond_to do |format|
      format.html
      format.json
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"articles.csv\""
        headers['Content-Type'] ||= 'text/csv'
      end
    end
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
  end

  # GET /articles/new
  def new
    @article = Article.new
  end

  # GET /articles/1/edit
  def edit
  end

  # POST /articles
  # POST /articles.json
  def create
    @article = Article.new(article_params)

    respond_to do |format|
      if @article.save
        format.html { redirect_to @article, notice: 'Article was successfully created.' }
        format.json { render :show, status: :created, location: @article }
      else
        format.html { render :new }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /articles/1
  # PATCH/PUT /articles/1.json
  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to @article, notice: 'Article was successfully updated.' }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /articles/1
  # DELETE /articles/1.json
  def destroy
    @article.destroy
    respond_to do |format|
      format.html { redirect_to articles_url, notice: 'Article was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    def set_prisoners_with_article
      @prisoners_with_article = Prisoner.by_article(@article.id)
    end

    def set_gon_variables
      gon.tinymce_config = YAML.load_file("config/tinymce.yml")
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def article_params
      params.require(:article).permit(:number, :criminal_code_id, :description)
    end
end
