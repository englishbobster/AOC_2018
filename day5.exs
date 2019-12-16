defmodule DayFive do
    def load_data(file) do
        File.read!(file)
        |> String.trim
    end

    def react(str) do
        as_list = String.to_charlist(str)
        react(as_list, 0)
    end
    def react(cl, prev_len) when length(cl) == prev_len do 
       length(cl) 
    end
    def react(cl, _prev_len) do
        {_, cl_reduced} = Enum.reduce(cl, {0,''}, fn ch, {prev_ch,result} ->
            if length(result) == 0 or abs(prev_ch - ch) != 32 do {ch, result ++ [ch]}
            else
                {_, rest} = List.pop_at(result, -1)
                {0, rest}
            end
        end)
        old = length(cl)
        IO.write(".")
        react(cl_reduced, old)
    end 

    def remove_unit_and_react(char, str) do
        IO.puts("removing char: #{String.Chars.to_string(char)}")
        stripped = str
        |> String. to_charlist
        |> Enum.filter(fn ch -> ch != char and ch != char + 32 end)
        |> String.Chars.to_string
        IO.puts(String.length(stripped))
        len = react(stripped)
        IO.puts("got length #{len}")
        len
    end

    def improve_polymer(str) do
        {_, l} = 65..90 
        |> Enum.reduce(%{}, fn c, acc -> Map.put(acc, c, remove_unit_and_react(c, str)) end)
        |> Enum.reduce({0,length(str)}, fn {k,v}, {char, len} ->
            if (v < len) do
                {k,v}
            else
                {char, len}
            end
        end)
       l 
    end
                                                    
end

ExUnit.start()

defmodule DayFiveTest do
    import DayFive
    use ExUnit.Case

    test "react single unit" do
        assert react("aA") == 0
    end

    test "react double unit" do
        assert react("aAbB") == 0
    end

    test "react double unit again" do
        assert react("BaAb") == 0
    end
 
    test "react not at all" do
        assert react("abAB") == 4
    end
 
    test "react larger" do
        assert react("dabAcCaCBAcCcaDA") == 10
    end
end

initial = DayFive.load_data("day_5_input.txt")
#result_str = initial |> DayFive.react
#IO.puts "Answer ONE: #{result_str}"
IO.puts "Answer TWO: #{initial |> DayFive.improve_polymer()}"



