defmodule TodexWeb.PageControllerTest do
  use TodexWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Todex"
  end
end
