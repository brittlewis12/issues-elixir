defmodule Issues.CLI do
  @default_count 4

  import Issues.TableFormatter, only: [print_table_with_columns: 2]

  @module_doc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating a table
  of the last `n` issues in a github project
  """

  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help.

  Otherwise it is a github username, project name, and
  (optionally) the number of entries.

  Returns a tuple of `{user, project, count}` or `:help`
  if help was given.
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [help: :boolean], aliases: [h: :help])
    case parse do
      {[help: true], _, _}
        -> :help
      {_, [user, project, count], _}
        -> {user, project, count}
      {_, [user, project], _}
        -> {user, project, @default_count}
      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [ count | #{@default_count} ]
    """
    System.halt(0)
  end
  def process({user, project, count}) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response
    |> sort_ascending
    |> Enum.take(count)
    |> print_table_with_columns(["number", "created_at", "title"])
  end

  def sort_ascending(issues_list) do
    Enum.sort(issues_list, &(&1["created_at"] <= &2["created_at"]))
  end

  defp decode_response({:ok, body}), do: body
  defp decode_response({:error, error}) when is_list(error) do
    {_, message} = List.keyfind(error, "message", 0)
    IO.puts "Error fetching from Github: #{message}"
    System.halt(2)
  end
  defp decode_response({:error, reason}) do
    IO.puts "Error fetching from Github: #{reason}"
    System.halt(2)
  end
end
