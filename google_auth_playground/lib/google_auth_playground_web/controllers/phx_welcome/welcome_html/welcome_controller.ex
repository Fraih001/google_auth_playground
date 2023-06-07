defmodule GoogleAuthPlaygroundWeb.WelcomeController do
  use GoogleAuthPlaygroundWeb, :controller

  def welcome(socket, _params) do
    # conn =
    #   case Map.get(socket.assigns.flash, "token") do
    #     nil -> socket
    #     token -> assign(socket, :token, token)
    #   end

    conn =
      case Map.get(socket.assigns.flash, "profile") do
        nil -> socket
        profile -> assign(socket, :profile, profile)
      end

    # dbg(conn)

    case get_token(conn) do
      {:ok, token} ->
        headers = [
          Authorization: "Bearer #{token.access_token}",
          "Content-Type": "application/json"
        ]

        # Get primary calendar
        {:ok, primary_calendar} =
          HTTPoison.get("https://www.googleapis.com/calendar/v3/calendars/primary", headers)
          |> parse_body_response()

        # Get events of first calendar
        params = %{
          maxResults: 20,
          singleEvents: true
        }

        {:ok, event_list} =
          HTTPoison.get(
            "https://www.googleapis.com/calendar/v3/calendars/#{primary_calendar.id}/events",
            headers,
            params: params
          )
          |> parse_body_response()

        render(conn, :welcome)

      _ ->
        conn |> redirect(to: ~p"/")
    end

    # render(conn, :welcome)
  end

  defp get_token(conn) do
    case Map.get(conn.assigns.flash, "token") do
      nil -> {:error, nil}
      token -> {:ok, token}
    end
  end

  defp parse_body_response({:error, err}), do: {:error, err}

  defp parse_body_response({:ok, response}) do
    dbg(response)
    body = Map.get(response, :body)
    # make keys of map atoms for easier access in templates
    if body == nil do
      {:error, :no_body}
    else
      {:ok, str_key_map} = Jason.decode(body)
      atom_key_map = for {key, val} <- str_key_map, into: %{}, do: {String.to_atom(key), val}
      {:ok, atom_key_map}
    end
  end
end
