defmodule GoogleAuthPlayground.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :console, :string

      timestamps()
    end
  end
end
