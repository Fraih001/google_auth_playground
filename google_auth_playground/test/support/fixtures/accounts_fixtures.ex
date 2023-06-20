defmodule GoogleAuthPlayground.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GoogleAuthPlayground.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        console: "some console",
        name: "some name"
      })
      |> GoogleAuthPlayground.Accounts.create_user()

    user
  end
end
