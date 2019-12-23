defmodule DaySix do
    def parse_line(ln) do
        String.split(",")
        |> Enum.map(fn int_str -> String.trim(int_str) end)
        |> Enum.reduce({}, fn x, acc -> Tuple.append(acc, String.to_integer(x)) end)
    end

    def load_data(file) do
        File.read!(file)
        |> String.trim
        |> String.split("\n")
        |> Enum.map(fn ln -> parse_line(ln) end)
    end

    def find_largest_x_y(coords) do
        coords
        |> Enum.reduce({0,0}, fn {x, y}, {xmax, ymax} ->
            cur_x = if x > xmax, do: x, else: xmax
            cur_y = if y > ymax, do: y, else: ymax
            {cur_x, cur_y}
        end)
    end

    def find_smallest_x_y(coords) do
        coords
        |> Enum.reduce({10000, 10000}, fn {x, y}, {xmin, ymin} ->
            cur_x = if x < xmin, do: x, else: xmin
            cur_y = if y < ymin, do: y, else: ymin
            {cur_x, cur_y}
        end)
    end
    
    def make_grid({x1,y1},{x2,y2}) do
        row = x1..x2 |> Enum.map(fn _val -> 46 end)
        y1..y2 |> Enum.map(fn _val -> row end)
    end

    def update_at(grid, {x,y}, val) do
        row = Enum.at(grid, y) |> List.update_at(x, fn _v -> val end)
        List.update_at(grid, y, fn _r -> row end)
    end

    def manhatten_distance({x1,y1}, {x2,y2}) do
        abs(x1 - x2) + abs(y1 - y2)
    end
    
    def generate_symbols(values) do #{coord, atom}
        atoms = for x <- 65..90, y <- 65..90, do: String.to_atom(String.Chars.to_string([x,y]))
        some_atoms = Enum.take(atoms, length(values))
        Enum.zip(values, some_atoms)
    end

    def build_area_map(values) do
        {xs, ys} = find_smallest_x_y(values)
        largest = find_largest_x_y(values)
        grid = make_grid({xs,ys}, largest)
        generate_symbols(values) 
        |> Enum.reduce(grid, fn {{x,y}, symbol}, grid -> update_at(grid, {(x - xs), (y - ys)}, symbol) end)
    end
end


ExUnit.start()

defmodule DaySixTest do
    import DaySix
    use ExUnit.Case

    setup do
        data = [{1,3},{66,122},{45,90},{35,111},{90,1},{55, 67}]
        empty_grid = [[46,46,46,46,46],
                                            [46,46,46,46,46],
                                            [46,46,46,46,46],
                                            [46,46,46,46,46],
                                            [46,46,46,46,46]]

        {:ok, data: data, empty_grid: empty_grid}
    end
    
    test "try to reduce" do
        assert [{{0,0}, :A}] |>
        Enum.reduce([[46]], fn {coord, symbol}, grid -> update_at(grid, coord, symbol) end) == [[:A]]
    end

    test "should generate a grid with symbols", context do
        assert build_area_map(context[:data]) == []
   end

    test "should find largest coords", context do
        assert find_largest_x_y(context[:data]) == {90, 122}
    end

    test "should find smallest coords", context do
        assert find_smallest_x_y(context[:data]) == {1, 1}
    end

    test "should make a grid", context do
        assert make_grid({1,1},{5,5}) == context[:empty_grid]
    end

    test "should update a grid", context do
        assert update_at(context[:empty_grid], {0, 1}, 65) == [[46,46,46,46,46],
                                                                 [65,46,46,46,46],
                                                                 [46,46,46,46,46],
                                                                 [46,46,46,46,46],
                                                                 [46,46,46,46,46]]
    end

    test  "should calculate distance" do
        assert manhatten_distance({9,4}, {3,6}) == 8
    end

    test "should zip with grid symbols" do
        coords = [{1,1}, {2,2}, {3,3}]
        assert generate_symbols(coords) == [{{1, 1}, :AA}, {{2, 2}, :AB}, {{3, 3}, :AC}]
    end      
end

