defmodule GoogleAuthPlayground.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :console, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :console])
    |> validate_required([:name, :console])
  end
end
