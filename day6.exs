defmodule DaySix do
    def parse_line(ln) do
        ln
        |> String.split(",")
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
        row = x1..x2 |> Enum.map(fn _val -> :empty end)
        y1..y2 |> Enum.map(fn _val -> row end)
    end

    def update_at(grid, {x,y}, val) do
        row = Enum.at(grid, y) |> List.update_at(x, fn _v -> val end)
        List.update_at(grid, y, fn _r -> row end)
    end

    def get_at(grid, {x,y}) do
        row = Enum.at(grid, y)
        Enum.at(row, x)
    end

    def manhatten_distance({x1,y1}, {x2,y2}) do
        abs(x1 - x2) + abs(y1 - y2)
    end
    
    def generate_symbols(values) do 
        atoms = for x <- 65..90, y <- 65..90, do: String.to_atom(String.Chars.to_string([x,y]))
        some_atoms = Enum.take(atoms, length(values))
        Enum.zip(values, some_atoms)
    end

    def lower_atom(atm) when is_atom(atm) do
        atm |> Atom.to_string |> :string.lowercase |> String.to_atom
    end

    def calculate_nearest(coords_symbol, this_coord) do
        results = coords_symbol
        |> Enum.map(fn {coord, symbol} -> {{coord, symbol}, manhatten_distance(coord, this_coord)} end)
        |> Enum.sort_by(fn {coord_symbol, distance} -> distance end, &<=/2)
        
        if length(results) > 1 do
            [{{coords, symbol}, dist},{{_coords2, _symbol2}, dist2}] = results |> Enum.take(2)
            if dist == dist2, do: :., else: symbol
        else
            [{{coords, symbol}, dist}] = results
        end
    end

    def calculate_sum(values, this_coord) do
        values
        |> Enum.reduce(0, fn val, acc -> acc + manhatten_distance(val, this_coord) end)
    end

    def build_area_grid(values) do
        {xs, ys} = find_smallest_x_y(values)
        {xl, yl} = find_largest_x_y(values)
        grid = make_grid({xs,ys}, {xl,yl})
        values_with_symbols = generate_symbols(values)
        updated_grid = for x <- xs..xl, y <- ys..yl, reduce: grid do
            acc -> 
            sym = calculate_nearest(values_with_symbols, {x,y})
            update_at(acc, {(x - xs), (y - ys)}, lower_atom(sym))
       end

       Enum.reduce(values_with_symbols, updated_grid,
            fn {{x,y}, symbol}, acc -> update_at(acc, {(x - xs), (y - ys)}, symbol) end)
    end
    
    def build_grid_with_distance_sums(values) do
        {xs, ys} = find_smallest_x_y(values)
        {xl, yl} = find_largest_x_y(values)
        grid = make_grid({xs,ys}, {xl,yl})
        for x <- xs..xl, y <- ys..yl, reduce: grid do
            acc ->
            distance_sum = calculate_sum(values, {x, y})
            update_at(acc, {(x - xs), (y - ys)}, distance_sum)
        end
    end

    def count_region_area(grid) do
        y_max = (length(grid) - 1)
        flat_grid = 0..y_max |> Enum.reduce([], fn y, acc -> acc ++ Enum.at(grid, y) end) |> List.flatten
        flat_grid |> Enum.filter(fn val -> val < 10000 end) |> length
    end

    def strip_edge_symbols(grid) do
        y_max = (length(grid) - 1)
        x_max = (length(Enum.at(grid,0)) - 1)

        top_bottom = Enum.at(grid, 0) ++ Enum.at(grid, y_max)
        left = 0..y_max |> Enum.reduce([], fn ycoord, acc -> acc ++ [get_at(grid, {0, ycoord})] end)
        right = 0..y_max |> Enum.reduce([], fn ycoord, acc -> acc ++ [get_at(grid, {x_max, ycoord})] end)
        to_remove = top_bottom ++ left ++ right |> List.flatten |> Enum.uniq |> Enum.filter(fn atm -> atm != :. end)
        
        updated_grid = for x <- 0..x_max, y <- 0..y_max, reduce: grid do
            acc -> 
            if Enum.member?(to_remove, get_at(grid, {x,y})) do
                update_at(acc, {x, y}, :.)
            else
                acc
            end
       end
    end

    def find_largest(grid) do
        y_max = (length(grid) - 1)
        flat_grid = 0..y_max |> Enum.reduce([], fn y, acc -> acc ++ Enum.at(grid, y) end) |> 
        Enum.filter(fn sym -> sym != :. end) |> Enum.map(fn sym -> lower_atom(sym) end) |> List.flatten
        val_map = Enum.reduce(flat_grid, %{}, fn val, acc -> 
            cond do
            get_in(acc, [val]) == nil ->
                put_in(acc, [val], 1)
            get_in(acc, [val]) >= 1 ->
                update_in(acc, [val], &(&1 + 1))
        end
        end)
        val_map |> Map.values |> Enum.max
    end

    def find_area(values) do
        build_area_grid(values)
        |> strip_edge_symbols()
        |> find_largest()
    end

    def find_region(values) do
        build_grid_with_distance_sums(values)
        |> count_region_area
    end

end


ExUnit.start()

defmodule DaySixTest do
    import DaySix
    use ExUnit.Case

    setup do
        data = [{1,3},{66,122},{45,90},{35,111},{90,1},{55, 67}]
        data_with_symbols = [{{1,3}, :AA}, {{66,122}, :AB}, {{45,90}, :AC}, {{35,111}, :AD}, {{90,1}, :AE}, {{55,67}, :AF}]
        empty_grid = [[:empty, :empty, :empty, :empty, :empty],
            [:empty, :empty, :empty, :empty, :empty],
            [:empty, :empty, :empty, :empty, :empty],
            [:empty, :empty, :empty, :empty, :empty],
            [:empty, :empty, :empty, :empty, :empty]]

        area_grid = [[:AA, :aa, :aa, :aa, :., :ac, :ac, :ac],
            [:aa, :aa, :ad, :ad, :ae, :ac, :ac, :ac],
            [:aa, :ad, :ad, :ad, :ae, :ac, :ac, :AC],
            [:., :ad, :AD, :ad, :ae, :ae, :ac, :ac],
            [:ab, :., :ad, :ae, :AE, :ae, :ae, :ac],
            [:AB, :ab, :., :ae, :ae, :ae, :ae, :.],
            [:ab, :ab, :., :ae, :ae, :ae, :af, :af],
            [:ab, :ab, :., :ae, :ae, :af, :af, :af],
            [:ab, :ab, :., :af, :af, :af, :af, :AF]]
        
        stripped_grid = [[:., :., :., :., :., :., :., :.],
            [:., :., :ad, :ad, :ae, :., :., :.],
            [:., :ad, :ad, :ad, :ae, :., :., :.],
            [:., :ad, :AD, :ad, :ae, :ae, :., :.],
            [:., :., :ad, :ae, :AE, :ae, :ae, :.],
            [:., :., :., :ae, :ae, :ae, :ae, :.],
            [:., :., :., :ae, :ae, :ae, :., :.],
            [:., :., :., :ae, :ae, :., :., :.],
            [:., :., :., :., :., :., :., :.]]

        example = [{1,1}, {1,6}, {8,3}, {3,4}, {5,5}, {8,9}]
        {:ok, data: data, empty_grid: empty_grid, data_with_symbols: data_with_symbols, example: example, area_grid: area_grid, stripped_grid: stripped_grid}
    end

    test "should count the areas and get largest", context do
        assert find_largest(context[:stripped_grid]) == 17
    end

    test "should build map", context do
        assert build_area_grid(context[:example]) == context[:area_grid]
    end

    test "should strip edge symbols", context do
        assert strip_edge_symbols(context[:area_grid]) == context[:stripped_grid]
    end

    test "make atom small case" do
        assert lower_atom(:GH) == :gh
    end

    test "should calculate nearest", context do
        assert calculate_nearest(context[:data_with_symbols], {44, 87}) == :AC
    end

    test "try to reduce" do
        assert [{{0,0}, :A}] |>
        Enum.reduce([[46]], fn {coord, symbol}, grid -> update_at(grid, coord, symbol) end) == [[:A]]
    end

    test "should get from grid", context do
        grid = update_at(context[:empty_grid], {1, 1}, :MUMU)
        assert get_at(grid, {1,1}) == :MUMU
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
        assert update_at(context[:empty_grid], {0, 1}, :bobo) == [[:empty, :empty, :empty, :empty, :empty],
            [:bobo, :empty, :empty, :empty, :empty],
            [:empty, :empty, :empty, :empty, :empty],
            [:empty, :empty, :empty, :empty, :empty],
            [:empty, :empty, :empty, :empty, :empty]]
    end

    test  "should calculate distance" do
        assert manhatten_distance({9,4}, {3,6}) == 8
    end

    test "should zip with grid symbols" do
        coords = [{1,1}, {2,2}, {3,3}]
        assert generate_symbols(coords) == [{{1, 1}, :AA}, {{2, 2}, :AB}, {{3, 3}, :AC}]
    end      
end

initial = DaySix.load_data("day_6_input.txt")
IO.puts "Answer ONE: #{initial |> DaySix.find_area}"
IO.puts "Answer ONE: #{initial |> DaySix.find_region}"
