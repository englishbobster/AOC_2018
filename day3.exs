defmodule DayThree do
        
    def load_data(file_name) do
        File.read!(file_name)
        |> String.trim
        |> String.split("\n")
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
        for j <- (y + 1)..(y + h), i <- (x + 1)..(x + w), do: {id, {i, j}} 
    end

    def make_claim_map(entries) do
        entries
        |> Enum.reduce(%{}, fn {id, {x,y}}, acc -> cond do
            get_in(acc, [Access.key(x, %{}), Access.key(y)]) == nil ->
                put_in(acc, [Access.key(x, %{}), Access.key(y)], id)
            get_in(acc, [Access.key(x, %{}), Access.key(y)]) != "X" ->
                put_in(acc, [Access.key(x, %{}), Access.key(y)], "X")
            get_in(acc, [Access.key(x, %{}), Access.key(y)]) == "X" ->
                put_in(acc, [Access.key(x, %{}), Access.key(y)], "X")
                end
        end)
    end

    def data_to_claim_map(data) do
        data
        |> Enum.map(fn claim -> parse_claim(claim) end)
        |> Enum.map(fn claim_tup -> create_map_entries(claim_tup) end)
        |> Enum.flat_map(&(&1))
        |> make_claim_map
    end 

    def count_overlaps(map) do
        Map.values(map) 
        |> Enum.flat_map(fn mp -> Map.values(mp) end)
        |> Enum.reduce(0, fn sym, acc -> if sym == "X", do: acc + 1, else: acc end)
    end

    def multiple_claims(data) do
        data_to_claim_map(data) |> count_overlaps
    end

    def count_all_ids(map) do
        Map.values(map) 
        |> Enum.flat_map(fn mp -> Map.values(mp) end)
        |> Enum.reduce(%{}, fn val, acc -> cond do
            get_in(acc, [val]) == nil ->
                put_in(acc, [val], 1)
            get_in(acc, [val]) >= 1 ->
                update_in(acc, [val], &(&1 + 1))
        end
        end)
    end

    def calculate_areas(claims) do
        claims
        |> Enum.reduce(%{}, fn {id, {_x, _y}, {w, h}}, acc -> Map.put(acc, id, w * h) end)
    end

   def find_complete_claim(data) do
       actual_areas = data_to_claim_map(data) |> count_all_ids
       expected_areas = data 
       |> Enum.map(fn claim -> parse_claim(claim) end)
       |> calculate_areas()

       {id, _value} = actual_areas |> Enum.find(fn {k,v} -> get_in(expected_areas, [k]) == v end)
       id
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
        assert create_map_entries(data) == [{1,{4,3}}, {1,{5,3}}, {1,{6,3}}, {1,{7,3}}, {1,{8,3}},
            {1,{4,4}}, {1,{5,4}}, {1,{6,4}}, {1,{7,4}}, {1,{8,4}},
            {1,{4,5}}, {1,{5,5}}, {1,{6,5}}, {1,{7,5}}, {1,{8,5}},
            {1,{4,6}}, {1,{5,6}}, {1,{6,6}}, {1,{7,6}}, {1,{8,6}}]
    end

    test "should map given entries in map structure with overlap" do
        data =[{1,{4,3}}, {1,{5,3}}, {1,{6,3}}, {1,{7,3}}, {1,{8,3}},
            {1,{4,4}}, {1,{5,4}}, {1,{6,4}}, {1,{7,4}}, {1,{8,4}},
            {1,{4,5}}, {1,{5,5}}, {1,{6,5}}, {1,{7,5}}, {1,{8,5}},
            {1,{4,6}}, {1,{5,6}}, {1,{6,6}}, {1,{7,6}}, {1,{8,6}}, 
            {2,{5,5}}, {2,{6,5}}]
        assert make_claim_map(data) == %{4 => %{3 => 1, 4 => 1, 5 => 1, 6 => 1}, 
                                         5 => %{3 => 1, 4 => 1, 5 => "X", 6 => 1},
                                         6 => %{3 => 1, 4 => 1, 5 => "X", 6 => 1},
                                         7 => %{3 => 1, 4 => 1, 5 => 1, 6 => 1},
                                         8 => %{3 => 1, 4 => 1, 5 => 1, 6 => 1}}
    end

    test "should produce a map of id and area" do
        data = [{1,{7,7},{4,3}}, {2,{7,7},{5,3}}, {3,{7,7},{6,3}}, {4,{7,7},{7,3}}, {5,{7,7},{8,3}}]
        assert calculate_areas(data) == %{1 => 12, 2 => 15, 3 => 18, 4 => 21, 5 => 24}
    end

    test "should count X in the map structure" do
        data = %{4 => %{3 => "#", 4 => "#", 5 => "#", 6 => "#"}, 
                                         5 => %{3 => "#", 4 => "#", 5 => "X", 6 => "#"},
                                         6 => %{3 => "#", 4 => "#", 5 => "X", 6 => "#"},
                                         7 => %{3 => "#", 4 => "#", 5 => "#", 6 => "#"},
                                         8 => %{3 => "#", 4 => "#", 5 => "#", 6 => "#"}}
        assert count_overlaps(data) == 2
    end
    
     test "should count all Id's in the map structure" do
        data =  %{4 => %{3 => 1, 4 => 1, 5 => 1, 6 => 2}, 
                                         5 => %{3 => 1, 4 => 1, 5 => "X", 6 => 2},
                                         6 => %{3 => 1, 4 => 1, 5 => "X", 6 => 2},
                                         7 => %{3 => 4, 4 => 4, 5 => 3, 6 => 3},
                                         8 => %{3 => 4, 4 => 4, 5 => 3, 6 => 3}}
        assert count_all_ids(data) == %{1 => 7, 2 => 3, 3 => 4, 4 => 4, "X" => 2}
    end
 
    test "should map given entries in map structure" do
       data =[{1,{4,3}}, {1,{5,3}}, {1,{6,3}}, {1,{7,3}}, {1,{8,3}},
            {1,{4,4}}, {1,{5,4}}, {1,{6,4}}, {1,{7,4}}, {1,{8,4}},
            {1,{4,5}}, {1,{5,5}}, {1,{6,5}}, {1,{7,5}}, {1,{8,5}},
            {1,{4,6}}, {1,{5,6}}, {1,{6,6}}, {1,{7,6}}, {1,{8,6}}] 
 
        assert make_claim_map(data) == %{4 => %{3 => 1, 4 => 1, 5 => 1, 6 => 1}, 
                                         5 => %{3 => 1, 4 => 1, 5 => 1, 6 => 1},
                                         6 => %{3 => 1, 4 => 1, 5 => 1, 6 => 1},
                                         7 => %{3 => 1, 4 => 1, 5 => 1, 6 => 1},
                                         8 => %{3 => 1, 4 => 1, 5 => 1, 6 => 1}}
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
IO.puts "Answer TWO: #{initial |> DayThree.find_complete_claim()}"
