defmodule Issues.TableFormatter do
  def print_table_with_columns(data, columns) do
    data_by_columns = split_into_columns(data, columns)
    column_widths   = widths_of(data_by_columns)
    format          = format_for(column_widths)

    puts_one_line_in_columns(columns, format)
    IO.puts separator(column_widths)
    puts_in_columns(data_by_columns, format)
  end

  def split_into_columns(data, columns) do
    for column <- columns do
      for row <- data, do: printable(row[column])
    end
  end

  def widths_of(columns) do
    for column <- columns do
      column |> Enum.map(&String.length/1) |> Enum.max
    end
  end

  def format_for(widths) do
    Enum.map_join(widths, " | ", &("~-#{&1}s")) <> "~n"
  end

  defp printable(data) when is_binary(data), do: data
  defp printable(data), do: to_string(data)

  defp separator(widths) do
    Enum.map_join(widths, "-+-", &(List.duplicate("-", &1)))
  end

  defp puts_in_columns(data_by_columns, format) do
    data_by_columns
    |> List.zip
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.each(&puts_one_line_in_columns(&1, format))
  end

  defp puts_one_line_in_columns(columns, format) do
    :io.format(format, columns)
  end
end
