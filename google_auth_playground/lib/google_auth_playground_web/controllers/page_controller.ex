defmodule GoogleAuthPlaygroundWeb.PageController do
  use GoogleAuthPlaygroundWeb, :controller

  def index(conn, _params) do
    # oauth_google_url = ElixirAuthGoogle.generate_oauth_url(conn)
    render(conn, :index)
  end
end
