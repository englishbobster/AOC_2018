defmodule DaySeven do
    def parse_row(row) do
        words = row |> String.split(" ")
        first = Enum.at(words, 1)
        next = Enum.at(words, 7)
        {String.to_atom(first), String.to_atom(next)}
    end

    def load_data(file_name) do
        File.read!(file_name)
        |> String.trim
        |> String.split("\n")
    end

end

ExUnit.start()

defmodule DaySevenTest do
    import DaySeven
    use ExUnit.Case

    setup do
        data = [{:C, :A}, {:C, :F}, {:A, :B}, {:A, :D}, {:B, :E}, {:D, :E}, {:F, :E}]
        {:ok, data: data}
    end

    test "should parse a line to tuple", context do
        [head|_t] = context[:data]
        assert parse_row("Step C must be finished before step A can begin.") == head
    end

end

