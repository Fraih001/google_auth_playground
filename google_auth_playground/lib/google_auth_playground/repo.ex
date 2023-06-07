defmodule GoogleAuthPlayground.Repo do
  use Ecto.Repo,
    otp_app: :google_auth_playground,
    adapter: Ecto.Adapters.Postgres
end
