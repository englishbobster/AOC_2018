defmodule DayThree do
    def load_data(file_name) do
        File.read!(file_name)
        |> String.trim
        |> String.split("\n")
    end
    
    def multiple_claims(data) do
        data
        |> Enum.map(fn claim -> parse_claim(claim) end)
        |> Enum.map(fn claim_tup -> create_map_entries(claim_tup) end)
        |> Enum.flat_map(&(&1))
        |> make_claim_map
        |> count_overlaps
    end

    def parse_claim(str) do
        values = str
        |> String.split(["#", "@", ":"])
        |> Enum.map(&String.trim&1)
        id = Enum.at(values, 1) |> String.to_integer
        pos = Enum.at(values,2) |> String.split(",") 
              |> Enum.map(fn v -> String.to_integer(v) end) |> List.to_tuple
        size = Enum.at(values, 3) |> String.split("x") 
               |> Enum.map(fn v -> String.to_integer(v) end) |> List.to_tuple
        {id, pos, size}
    end

    def create_map_entries({id, {x, y}, {w, h}}) do
        for j <- (y + 1)..(y + h), i <- (x + 1)..(x + w), do: {id, i, j} 
    end

    def make_claim_map(entries) do
        entries
        |> Enum.reduce(%{}, fn {x,y}, acc -> cond do
            get_in(acc, [Access.key(x, %{}), Access.key(y)]) == nil ->
                put_in(acc, [Access.key(x, %{}), Access.key(y)], "#")
            get_in(acc, [Access.key(x, %{}), Access.key(y)]) == "#" ->
                put_in(acc, [Access.key(x, %{}), Access.key(y)], "X")
            get_in(acc, [Access.key(x, %{}), Access.key(y)]) == "X" ->
                put_in(acc, [Access.key(x, %{}), Access.key(y)], "X")
                end
        end)
    end

    def count_overlaps(map) do
        Map.values(map) 
        |> Enum.flat_map(fn mp -> Map.values(mp) end)
        |> Enum.reduce(0, fn sym, acc -> if sym == "X", do: acc + 1, else: acc end)
    end

end

ExUnit.start()

defmodule DayTwoTest do
    import DayThree
    use ExUnit.Case

    test "should split line to {id, {x, y}, {w, h}}" do
        data = "#1 @ 1,3: 4x5"
        assert parse_claim(data) == {1, {1, 3}, {4,5}}
    end

    test "should create map entries from parse claim data" do
        data = {1, {3, 2}, {5, 4}}
        assert create_map_entries(data) == [{4,3}, {5,3}, {6,3}, {7,3}, {8,3},
                                    {4,4}, {5,4}, {6,4}, {7,4}, {8,4},
                                    {4,5}, {5,5}, {6,5}, {7,5}, {8,5},
                                    {4,6}, {5,6}, {6,6}, {7,6}, {8,6}]
    end

    test "should map given entries in map structure with overlap" do
        data = [{4,3}, {5,3}, {6,3}, {7,3}, {8,3},
                                    {4,4}, {5,4}, {6,4}, {7,4}, {8,4},
                                    {4,5}, {5,5}, {6,5}, {7,5}, {8,5},
                                    {4,6}, {5,6}, {6,6}, {7,6}, {8,6}, {5,5}, {6,5}]
        assert make_claim_map(data) == %{4 => %{3 => "#", 4 => "#", 5 => "#", 6 => "#"}, 
                                         5 => %{3 => "#", 4 => "#", 5 => "X", 6 => "#"},
                                         6 => %{3 => "#", 4 => "#", 5 => "X", 6 => "#"},
                                         7 => %{3 => "#", 4 => "#", 5 => "#", 6 => "#"},
                                         8 => %{3 => "#", 4 => "#", 5 => "#", 6 => "#"}}
    end

    test "should count X in the map structure" do
        data = %{4 => %{3 => "#", 4 => "#", 5 => "#", 6 => "#"}, 
                                         5 => %{3 => "#", 4 => "#", 5 => "X", 6 => "#"},
                                         6 => %{3 => "#", 4 => "#", 5 => "X", 6 => "#"},
                                         7 => %{3 => "#", 4 => "#", 5 => "#", 6 => "#"},
                                         8 => %{3 => "#", 4 => "#", 5 => "#", 6 => "#"}}
        assert count_overlaps(data) == 2
    end
    
    test "should map given entries in map structure" do
        data = [{4,3}, {5,3}, {6,3}, {7,3}, {8,3},
                                    {4,4}, {5,4}, {6,4}, {7,4}, {8,4},
                                    {4,5}, {5,5}, {6,5}, {7,5}, {8,5},
                                    {4,6}, {5,6}, {6,6}, {7,6}, {8,6}]
        assert make_claim_map(data) == %{4 => %{3 => "#", 4 => "#", 5 => "#", 6 => "#"}, 
                                         5 => %{3 => "#", 4 => "#", 5 => "#", 6 => "#"},
                                         6 => %{3 => "#", 4 => "#", 5 => "#", 6 => "#"},
                                         7 => %{3 => "#", 4 => "#", 5 => "#", 6 => "#"},
                                         8 => %{3 => "#", 4 => "#", 5 => "#", 6 => "#"}}
    end

    test "should detect multiple claims" do
        data = ["#1 @ 1,3: 4x4", "#2 @ 3,1: 4x4", "#3 @ 5,5: 2x2"]
        assert multiple_claims(data) == 4
    end

    test "should detect larger multiple claims" do
        data = ["#1 @ 1,3: 4x4", "#2 @ 3,1: 4x4", "#3 @ 5,4: 2x2"]
        assert multiple_claims(data) == 6
    end

    test "should detect larger multiple claims with multiple overlaps" do
        data = ["#1 @ 1,3: 4x4", "#2 @ 3,1: 4x4", "#3 @ 4,4: 2x2"]
        assert multiple_claims(data) == 6 
    end
    
    test "should detect total overlap" do
        data = ["#1 @ 1,3: 4x4", "#2 @ 1,3: 4x4", "#3 @ 1,3: 4x4"]
        assert multiple_claims(data) == 16 
    end

end

initial = DayThree.load_data("day_3_input.txt")
IO.puts "Answer ONE: #{initial |> DayThree.multiple_claims()}"

