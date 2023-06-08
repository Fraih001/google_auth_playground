defmodule GoogleAuthPlaygroundWeb.WelcomeLive do
  use GoogleAuthPlaygroundWeb, :live_view
  import GoogleAuthPlaygroundWeb.WelcomeHTML

  def mount(_params, _session, socket) do
    # We fetch the access token to make the requests.
    # If none is found, we redirect the person to the home page.

    case Map.get(socket.assigns.flash, "profile") do
      nil -> socket
      profile -> assign(socket, :profile, profile)
    end

    case get_token(socket) do
      {:ok, token} ->
        headers = [
          Authorization: "Bearer #{token.access_token}",
          "Content-Type": "application/json"
        ]

        # Get primary calendar
        {:ok, primary_calendar} =
          HTTPoison.get("https://www.googleapis.com/calendar/v3/calendars/primary", headers)
          |> parse_body_response()

        # list of params for event call -> https://developers.google.com/calendar/api/v3/reference/events/list
        # TO DO - account for different time zones
        current = Timex.now("America/New_York")
        start = Timex.shift(current, days: -2)

        # Get events of primary (default) calendar
        params = %{
          timeMin: start |> Timex.beginning_of_day() |> Timex.format!("{RFC3339}"),
          timeMax: current |> Timex.end_of_day() |> Timex.format!("{RFC3339}"),
          # maxResults: 1,
          singleEvents: true,
          orderBy: "startTime"
        }

        {:ok, event_list} =
          HTTPoison.get(
            "https://www.googleapis.com/calendar/v3/calendars/#{primary_calendar.id}/events",
            headers,
            params: params
          )
          |> parse_body_response()

        {:ok, assign(socket, event_list: event_list.items)}

      _ ->
        {:ok, push_redirect(socket, to: ~p"/")}
    end
  end

  defp get_token(socket) do
    case Map.get(socket.assigns.flash, "token") do
      nil -> {:error, nil}
      token -> {:ok, token}
    end
  end

  defp parse_body_response({:error, err}), do: {:error, err}

  defp parse_body_response({:ok, response}) do
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
