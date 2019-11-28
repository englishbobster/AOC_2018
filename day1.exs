defmodule DayOne do

    def calculate_freq(freq_list) do
      Enum.sum(freq_list) 
    end

    def load_data(file_name) do
        File.read!(file_name)
        |> String.trim
        |> String.split("\n")
        |> Enum.map(fn str -> String.to_integer(str) end) 
    end
    
    def find_first_duplicate(the_list) do
        find_first_duplicate(the_list, [], [], 1)
    end
   
    def find_first_duplicate(the_list, initial_list, uniqued, index) do
        cond do
            length(uniqued) < length(initial_list) -> 
                List.last(initial_list)
            length(uniqued) == length(initial_list) ->
                new_list = frequency_change_list(the_list, index)
                find_first_duplicate(the_list, new_list, 
                    new_list |> Enum.uniq,
                    index + 1) 
        end
    end

    defp frequency_change_list(list, nr_elements) do
        IO.puts("list generated with #{nr_elements}")
        Stream.cycle(list)
        |> Enum.take(nr_elements)
        |> Enum.reduce([0], fn fr, acc -> acc ++ [fr + List.last(acc)] end)
    end

    def find_first_duplicate_2(list) do
        Stream.cycle(list)
        |> Enum.reduce_while({0, MapSet.new([0])},
            fn freq, {current, checked} ->
                new_val = freq + current

                cond do
                    MapSet.member?(checked, new_val) -> {:halt, new_val}
                    true -> {:cont, {new_val, MapSet.put(checked, new_val)}}
                end
            end
        )
    end

end

ExUnit.start()

defmodule DayOneTest do
    import DayOne
    use ExUnit.Case

    test "should result in 3" do
        list = [1, 1, 1]
        assert calculate_freq(list) == 3
    end

    test "should result in 0" do
        list = [1, 1, -2]
        assert calculate_freq(list) == 0
    end
    
    test "should result in -6" do
        list = [-1, -2, -3]
        assert calculate_freq(list) == -6
    end

    test "should see that zero occurs twice" do
        list = [1, -1]
        assert find_first_duplicate_2(list) == 0
    end
      
    test "should see that ten occurs twice" do
        list = [3, 3, 4, -2, -4]
        assert find_first_duplicate_2(list) == 10
    end

    test "should see that five occurs twice" do
        list = [-6, 3, 8, 5, -6]
        assert find_first_duplicate_2(list) == 5
    end

    test "should see that fourteen occurs twice" do
        list = [7, 7, -2, -7, -4]
        assert find_first_duplicate_2(list) == 14 
    end
end

initial = DayOne.load_data("day_1_input.txt")
IO.puts "Answer ONE: #{initial |> DayOne.calculate_freq}"

IO.puts "Answer TWO: #{DayOne.find_first_duplicate_2(initial)}"
