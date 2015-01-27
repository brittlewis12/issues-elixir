defmodule Issues.GithubIssues do
  @user_agent [ {"User-agent", "Elixir brittlewis12@gmail.com"} ]
  @github_url Application.get_env(:issues, :github_url)

  def fetch(user, project) do
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  defp issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  defp handle_response({:ok, %{status_code: 200, body: body}}), do: JSX.decode(body)
  defp handle_response({:ok, %{status_code: _, body: body}}) do
    case JSX.decode(body) do
      {:ok, resp} -> {:error, resp}
      resp = {:error, _} -> resp
    end
  end
  defp handle_response({:error, %{reason: reason}}), do: { :error, reason }
end
