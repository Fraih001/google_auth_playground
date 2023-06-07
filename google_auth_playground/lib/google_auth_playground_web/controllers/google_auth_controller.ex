defmodule GoogleAuthPlaygroundWeb.GoogleAuthController do
  use GoogleAuthPlaygroundWeb, :controller

  @doc """
  `index/2` handles the callback from Google Auth API redirect.
  """
  def index(conn, %{"code" => code}) do
    # creates one-time auth token based on response code from Google after authentication
    {:ok, token} = ElixirAuthGoogle.get_token(code, GoogleAuthPlaygroundWeb.Endpoint.url())
    # requests the person's profile data from Google based on the access_token
    {:ok, profile} = ElixirAuthGoogle.get_user_profile(token.access_token)

    # Render a :welcome view displaying some profile data to confirm that login with Google was successful.
    conn
    |> put_view(GoogleAuthPlaygroundWeb.WelcomeHTML)
    |> render(:welcome, profile: profile)
  end
end
