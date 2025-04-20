defmodule GitPaywall2Web.Router do
  use GitPaywall2Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GitPaywall2Web.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GitPaywall2Web do
    pipe_through :browser

    get "/", PageController, :home
  end

  # API endpoints
  scope "/api", GitPaywall2Web do
    pipe_through :api

    get "/repos/:repo_id", RepoController, :get
    get "/repos/:repo_id/clone", RepoController, :clone
    post "/repos/:repo_id/price", RepoController, :set_price
  end

  # Git protocol handler
  scope "/git", GitPaywall2Web do
    get "/:repo_id", GitController, :serve
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:git_paywall2, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GitPaywall2Web.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
