defmodule GoogleAuthPlaygroundWeb.WelcomeHTML do
  use GoogleAuthPlaygroundWeb, :html

  def welcome(assigns) do
    ~H"""
    <section class="phx-hero">
      <h1> Welcome <%= @profile.given_name %>!
      </h1>
      <p> You are <strong>signed in</strong>
      with your <strong>Google Account</strong> <br />
      <strong style="color:teal;"><%= @profile.email %></strong>
      </p>
    </section>

    """
  end
end