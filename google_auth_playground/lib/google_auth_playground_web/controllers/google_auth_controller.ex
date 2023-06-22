defmodule GoogleAuthPlaygroundWeb.GoogleAuthController do
  use GoogleAuthPlaygroundWeb, :controller
  plug Ueberauth
  alias GoogleAuthPlayground.UserFromAuth

  @doc """
  `index/2` handles the callback from Google Auth API redirect.
  """
  
  # def index(conn, %{"code" => code}) do
  #   # creates one-time auth token based on response code from Google after authentication
  #   {:ok, token} = ElixirAuthGoogle.get_token(code, GoogleAuthPlaygroundWeb.Endpoint.url())
  #   # requests the person's profile data from Google based on the access_token
  #   {:ok, profile} = ElixirAuthGoogle.get_user_profile(token.access_token)
  #   IO.inspect(token)
  #   IO.inspect(profile)
  #   create_subscription(conn, token, profile)
    
  #   conn
  #   |> put_flash(:token, token)
  #   |> put_flash(:profile, profile)
  #   |> redirect(to: ~p"/welcome")
  # end
  
  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: ~p"/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    IO.inspect(auth)
    case UserFromAuth.find_or_create(auth) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:current_user, user)
        |> configure_session(renew: true)
        |> redirect(to: ~p"/welcome")

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: ~p"/")
    end
end
  
  
  def create_subscription(conn, token, _profile) do
    notification_id = UUID.uuid1()
    calendar_id = "fraiha26@gmail.com"
    
    headers = [
      {"Authorization", "Bearer #{token.access_token}"},
      {"Content-Type", "application/json"},
      {"X-CSRF-Token", Plug.CSRFProtection.get_csrf_token()}
    ]
    
    body = %{
      "id" => notification_id,
      "type" => "web_hook",
      "address" => "https://8d34-24-228-150-250.ngrok.io/notifications",
    }
    
    case HTTPoison.post("https://www.googleapis.com/calendar/v3/calendars/#{calendar_id}/events/watch", Poison.encode!(body), headers) do
      {:ok, %{status_code: 200, body: body}} ->
        IO.puts("++++++++++++++++++++++++++")
        IO.inspect(body)
        IO.inspect("Subscription successful!")
        IO.puts("++++++++++++++++++++++++++")
  
      {:ok, %{status_code: status_code, body: body}} ->
        json(conn, %{error: "Failed to create subscription: #{status_code} - #{inspect(body)}"})
  
      {:error, reason} ->
        json(conn, %{error: reason})
    end
  end
  
  def handle_notifications(conn, _params) do
    case Plug.Conn.read_body(conn) do
      {:ok, body, conn} ->
        # Process the notification body
        IO.puts("++++++++++++++++++++++++++")
        IO.inspect(body) # body will always be an empty string, as the google notification does not contain a resp_body 
        IO.inspect(conn)
        IO.inspect("Received Successfully!")
        IO.puts("++++++++++++++++++++++++++")
        send_resp(conn, 200, "Notification received successfully")

      {:error, reason} ->
        send_resp(conn, 400, "Failed to read notification body: #{reason}")
    end
  
end

end
