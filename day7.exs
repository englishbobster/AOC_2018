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

    def create_dag(values) do
        term_steps = values
                      |> Enum.reduce([], fn {_x, y}, acc -> acc ++ [y] end)

        65..90
        |> Enum.map(fn code -> (String.Chars.to_string([code]) |> String.to_atom) end)
        |> Enum.reduce(Keyword.new, fn x, acc -> 
            steps = Keyword.get_values(values, x)
            if not Enum.empty?(steps) do
                Keyword.put_new(acc, x, steps) 
            else
                if Enum.member?(term_steps, x) do
                    Keyword.put_new(acc, x, [])
                else
                    acc
                end
            end
        end)
    end

    def order_steps(dag) do
        []
    end

    def find_starts(dag) do
        all_nodes = Keyword.values(dag) |> List.flatten
        Enum.reduce(dag, [], fn {k, _v}, acc -> 
            case not Enum.member?(all_nodes, k) do
                true -> acc ++ [k]
                false -> acc
            end
        end) |> Enum.sort
    end

    def find_ends(dag) do
        Enum.reduce(dag, [], fn {k, v}, acc ->
            case Enum.empty?(v) do
                true -> acc ++ [k]
                false -> acc
            end
        end) |> Enum.sort
    end

end

ExUnit.start()

defmodule DaySevenTest do
    import DaySeven
    use ExUnit.Case

    setup do
        data = [{:C, :A}, {:C, :F}, {:A, :B}, {:A, :D}, {:B, :E}, {:D, :E}, {:F, :E}]
        dag = [C: [:A, :F], A: [:B, :D], B: [:E], D: [:E], F: [:E], E: []]
        {:ok, data: data, dag: dag}
    end

    test "should find one or more start", context do
        # add another start to the setup data
        assert find_starts(context[:dag] ++ [Z: [:A, :H]]) == [:C, :Z]
    end

    test "should find one or more ends", context do
        assert find_ends(context[:dag]) == [:E]
    end

    test "should order steps", context do
        assert order_steps(context[:dag]) == [:C, :A, :B, :D, :F, :E]
    end

    test "should parse a line to tuple", context do
        [head|_t] = context[:data]
        assert parse_row("Step C must be finished before step A can begin.") == head
    end

    test "should create a dag", context do
        actual_sorted = create_dag(context[:data]) |> Enum.sort
        expected_sorted = context[:dag] |> Enum.sort
        assert actual_sorted == expected_sorted
    end

end

