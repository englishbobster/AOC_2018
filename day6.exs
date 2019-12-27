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
        {result, dist} = coords_symbol
        |> Enum.map(fn {coord, _symbol} -> {{coord, _symbol}, manhatten_distance(coord, this_coord)} end)
        |> Enum.min_by(fn {coord_symbol, distance} -> distance end)
        result
    end

    def build_area_map(values) do
        {xs, ys} = find_smallest_x_y(values)
        {xl, yl} = find_largest_x_y(values)
        grid = make_grid({xs,ys}, {xl,yl})
        values_with_symbols = generate_symbols(values)
        updated_grid = Enum.reduce(values_with_symbols, grid,
            fn {{x,y}, symbol}, grid -> update_at(grid, {(x - xs), (y - ys)}, symbol) end)

       for x <- xs..xl, y <- ys..yl, reduce: updated_grid do
            acc -> 
            {{_xn,_yn}, sym} = calculate_nearest(values_with_symbols, {x,y})
            case get_at(acc, {(x - xs), (y - ys)}) do
                :empty -> update_at(acc, {(x - xs), (y - ys)}, lower_atom(sym))
                sym -> acc
                _ -> update_at(acc, {(x - xs), (y - ys)}, :.)
            end
        end
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

        example = [{1,1}, {1,6}, {8,3}, {3,4}, {5,5}, {8,9}]
        {:ok, data: data, empty_grid: empty_grid, data_with_symbols: data_with_symbols, example: example}
    end

    test "should build map", context do
        assert build_area_map(context[:example]) == []
    end

    test "make atom small case" do
        assert lower_atom(:GH) == :gh
    end

    test "should calculate nearest", context do
        assert calculate_nearest(context[:data_with_symbols], {44, 87}) == {{45,90}, :AC}
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

