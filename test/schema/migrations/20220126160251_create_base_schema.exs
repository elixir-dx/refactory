defmodule Refactory.Test.Repo.Migrations.CreateBaseSchema do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :first_name, :string
      add :last_name, :string
    end

    create table(:list_templates) do
      add :title, :string, null: false
      add :hourly_points, :float
    end

    create table(:lists) do
      add :title, :string, null: false
      add :created_by_id, references(:users), null: false
      add :from_template_id, references(:list_templates)
      add :hourly_points, :float
      add :archived_at, :utc_datetime
      timestamps()
    end

    create table(:tasks) do
      add :title, :string, null: false
      add :desc, :string
      add :list_id, references(:lists), null: false
      add :created_by_id, references(:users), null: false
      add :completed_at, :utc_datetime
      add :due_on, :date
      add :archived_at, :utc_datetime
      timestamps()
    end

    create table(:list_tags) do
      add :list_id, references(:lists), null: false
      add :name, :string, null: false
    end
  end
end
