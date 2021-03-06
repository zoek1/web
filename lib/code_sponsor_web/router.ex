defmodule CodeSponsorWeb.Router do
  use CodeSponsorWeb, :router
  use Coherence.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session
  end

  pipeline :protected do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Coherence.Authentication.Session, protected: true
    plug :put_layout, {CodeSponsorWeb.LayoutView, :admin}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end
  
  pipeline :exq do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
    plug ExqUi.RouterPlug, namespace: "exq"
  end

  scope "/exq", ExqUi do
    pipe_through :exq
    forward "/", RouterPlug.Router, :index
  end

  scope "/" do
    pipe_through :browser
    coherence_routes()
  end

  scope "/" do
    pipe_through :protected
    coherence_routes :protected
  end

  # LEGACY IMPRESSION LINK: https://codesponsor.io/t/l/653d56e083fec2a9ae1b6c7cde4e5f5f/pixel.png
  # LEGACY CLICK LINK: https://codesponsor.io/t/c/653d56e083fec2a9ae1b6c7cde4e5f5f/

  scope "/", CodeSponsorWeb do
    pipe_through :browser
    
    get "/", PageController, :index
    get "/t/l/:property_id/pixel.png", TrackController, :pixel
    get "/t/l/:property_id/logo.png", TrackController, :logo
    get "/t/c/:property_id/", TrackController, :click
  end

  scope "/", CodeSponsorWeb do
    pipe_through :protected

    get "/dashboard", DashboardController, :index
    resources "/properties", PropertyController
    resources "/campaigns", CampaignController
    resources "/sponsorships", SponsorshipController
    resources "/clicks", ClickController
    resources "/impressions", ImpressionController
  end

  # Other scopes may use custom stacks.
  # scope "/api", CodeSponsorWeb do
  #   pipe_through :api
  # end
end
