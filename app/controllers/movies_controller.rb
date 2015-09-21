class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.uniq.pluck(:rating)
    @selected_rating = Hash.new(false)
    if !params[:sort_by].nil?
      if(params[:sort_by] =="title")
          @classHilite_title = "hilite"
      else
          @classHilite_release = "hilite"
      
      end
    end

    if params[:ratings].nil?
      @user_rating = @all_ratings
    else
      @user_rating = params[:ratings].keys
    end

    if params[:sort_by].nil? && params[:ratings].nil?
       if !session[:sort_by].nil? || !session[:ratings].nil?
          flash.keep
          redirect_to movies_path :sort_by =>session[:sort_by], :ratings =>session[:ratings]
       end
    elsif !params[:sort_by].nil? && params[:ratings].nil?
       session[:sort_by]= params[:sort_by]
       if !session[:ratings].nil?
          flash.keep
          redirect_to movies_path :sort_by =>params[:sort_by], :ratings =>session[:ratings]
       end
    elsif params[:sort_by].nil? && !params[:ratings].nil?
        session[:ratings] = params[:ratings]
        if !session[:sort_by].nil?
          flash.keep
          redirect_to movies_path :sort_by =>session[:sort_by], :ratings =>params[:ratings]
        end
    end

    @movies = Movie.all.order(params[:sort_by]).where(rating: @user_rating)
    @user_rating.each{ |rate| @selected_rating[rate]="true"}

  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
