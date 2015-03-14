defmodule CliTest do
  use ExUnit.Case

  import Issues.CLI, only: [parse_args: 1, sort_ascending: 1]

  test ":help returned when parsing options --help or -h" do
    assert parse_args(["--help", "anything"]) == :help
    assert parse_args(["-h", "anything"]) == :help
  end

  test ":help returned when parsing bad options" do
    assert parse_args(["--bananas"]) == :help
    assert parse_args(["-b"]) == :help
  end

  test "returns three values if given three values" do
    assert parse_args(["user", "project", "99"]) == {"user", "project", 99}
  end

  test "returns default count if two values given" do
    assert parse_args(["user", "project"]) == {"user", "project", 4}
  end

  test "sort_ascending orders the list by created_at" do
    result = sort_ascending(fake_created_at_list(["c", "a", "b"]))
    issues = for issue <- result, do: issue["created_at"]
    assert issues == ~w{a b c}
  end

  defp fake_created_at_list(values) do
    data = for value <- values, do: [{"created_at", value}, {"other_data", "xxx"}]
    data |> Enum.map(&Enum.into(&1, HashDict.new))
  end
end
