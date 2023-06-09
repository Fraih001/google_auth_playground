defmodule GoogleAuthPlaygroundWeb.Router do
  use GoogleAuthPlaygroundWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {GoogleAuthPlaygroundWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    
    scope "/", GoogleAuthPlaygroundWeb do
      post "/subscription", GoogleAuthController, :create_subscription
      post "/notifications", GoogleAuthController, :handle_notifications
    end
  end

  scope "/", GoogleAuthPlaygroundWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
    live("/welcome", WelcomeLive)
    get "/auth/google", GoogleAuthController, :request
    get "/auth/google/callback", GoogleAuthController, :callback
    # get("/auth/google/callback", GoogleAuthController, :index)
 
  end

  # Other scopes may use custom stacks.
  # scope "/api", GoogleAuthPlaygroundWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:google_auth_playground, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: GoogleAuthPlaygroundWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
