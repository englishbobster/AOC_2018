defmodule DayTwo do

    def load_data(file_name) do
        File.read!(file_name)
        |> String.trim
        |> String.split("\n")
    end

    def generate_checksum(data) do
        {x,y} = data
        |> Enum.map(fn id -> {mark_duplicates(id), id} end)
        |> Enum.map(fn {dups, id} -> {dups, mark_triples(id), id} end)
        |> Enum.reduce({0, 0}, fn {d, t, _}, acc -> 
            cond do
                d and t ->
                    {elem(acc, 0) + 1, elem(acc, 1) + 1}
                d ->
                     {elem(acc, 0) + 1, elem(acc, 1)}
                t ->
                    {elem(acc, 0), elem(acc, 1) + 1}
                true ->
                    acc
            end
        end)
        x * y
    end

    defp mark_descreet(id_str, cnt) do
        String.to_charlist(id_str) 
        |> Enum.reduce(%{}, fn l, acc -> Map.update(acc, l, 1, fn v -> v + 1 end) end) 
        |> Map.to_list 
        |> Enum.filter(fn {_, x} -> x == cnt end)
        |> length != 0
    end

    defp mark_duplicates(id_str) do
        mark_descreet(id_str, 2)
    end

    defp mark_triples(id_str) do
        mark_descreet(id_str,3)
    end

    defp count_matching_by_position(str, match) do
        str
        |> String.to_charlist
        |> Enum.with_index
        |> Enum.filter(fn {l, i} -> Enum.at(String.to_charlist(match), i) != l end)
        |> Enum.count
    end

    def find_matching(list) do
        [first_pass | _] = find_matching(list, [])
        [second_pass | _] = find_matching(Enum.reverse(list), [])
        first_pass
        |> String.codepoints
        |> Enum.with_index
        |> Enum.filter(fn {b, i} -> b == Enum.at(String.codepoints(second_pass), i) end)
        |> Enum.map(fn {a, _} -> a end)
        |> Enum.join
    end
    
    defp find_matching([], final) do
        final
    end

    defp find_matching([h|t], result) do
        checked = t |> Enum.filter(fn str -> count_matching_by_position(h, str) == 1 end)
        find_matching(t, result ++ checked) 
    end

        
end




ExUnit.start()

defmodule DayTwoTest do
    import DayTwo
    use ExUnit.Case

    test "should find 12 as checksum" do
        data = ["abcdef", "bababc", "abbcde", "abcccd", "aabcdd", "abcdee", "ababab"]
        assert generate_checksum(data) == 12
    end

    test "should find closely matched" do
        data = ["abcde", "fghij", "klmno", "pqrst", "fguij", "axcye", "wvxyz"]
        assert find_matching(data) == "fgij"
    end
end



initial = DayTwo.load_data("day_2_input.txt")
IO.puts "Answer ONE: #{initial |> DayTwo.generate_checksum()}"

IO.puts "Answer TWO: #{initial |> DayTwo.find_matching()}"
