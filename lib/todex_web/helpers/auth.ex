defmodule TodexWeb.Helpers.Auth do
  alias Plug.Conn

  def signed_in?(conn) do
    logged_user = Conn.get_session(conn, :current_user)
    logged_user != nil
  end

  def current_user(conn) do
    Conn.get_session(conn, :current_user)
  end
end
