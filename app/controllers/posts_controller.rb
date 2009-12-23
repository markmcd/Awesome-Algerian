class PostsController < ApplicationController
  before_filter :require_user, :only => [ :new, :edit, :delete ]

  # GET /posts
  # GET /posts.xml
  def index
    @posts = Post.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @posts }
    end
  end

  # GET /posts/1
  # GET /posts/1.xml
  def show
    @post = Post.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
    end
  end

  # GET /posts/new
  # GET /posts/new.xml
  def new
    @post = Post.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @post }
    end
    make_rss
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.xml
  def create
    @post = Post.new(params[:post])

    @post.update_attribute(:user_id, current_user.id)

    respond_to do |format|
      if @post.save
        flash[:notice] = 'Post was successfully created.'
        format.html { redirect_to(@post) }
        format.xml  { render :xml => @post, :status => :created, :location => @post }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
    make_rss
  end

  # PUT /posts/1
  # PUT /posts/1.xml
  def update
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        flash[:notice] = 'Post was successfully updated.'
        format.html { redirect_to(@post) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @post.errors, :status => :unprocessable_entity }
      end
    end
    make_rss
  end

  # DELETE /posts/1
  # DELETE /posts/1.xml
  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to(posts_url) }
      format.xml  { head :ok }
    end
    make_rss
  end

  # http://rubyrss.com/
  def make_rss
    require 'rss/maker'
    version = "2.0"
    destination = "/home/thedji/algerian/public/feed/posts.xml"

    content = RSS::Maker.make(version) do |m|
      m.channel.title = "Awesome Algerian"
      m.channel.link = "http://awesomealgerian.com"
      m.channel.description = "The finest in Algerian"
      m.items.do_sort = true
  
      Post.all.last(30).each {|p|
        i = m.items.new_item
        i.title = p.title
        i.link = "http://awesomealgerian.com/posts/#{p.id}"
        i.date = Time.parse("#{p.created_at}")
        i.description = "<img src='#{p.image_url}'/><p>#{p.description}</p>"
      }
    end

    File.open(destination, "w") do |f|
      f.write(content)
    end
  end
end
