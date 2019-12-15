defmodule DayFive do
    def load_data(file) do
        File.read!(file)
        |> String.trim
    end

    def react(str) do
        as_list = String.to_charlist(str)
        react(as_list, 0)
    end
    def react(cl, prev_len) when length(cl) == prev_len, do: String.Chars.to_string(cl)
    def react(cl, _prev_len) do
        {_, cl_reduced} = Enum.reduce(cl, {0,''}, fn ch, {prev_ch,result} ->
            if length(result) == 0 or abs(prev_ch - ch) != 32 do
                {ch, result ++ [ch]}
            else
                {_, rest} = List.pop_at(result, -1)
                {0, rest}
            end
        end)
        old = length(cl)
        IO.puts "cl: #{old}"
        react(cl_reduced, old)
   end 
end

ExUnit.start()

defmodule DayFiveTest do
    import DayFive
    use ExUnit.Case

    test "react single unit" do
        assert react("aA") == ""
    end

    test "react double unit" do
        assert react("aAbB") == ""
    end

    test "react double unit again" do
        assert react("BaAb") == ""
    end
 
    test "react not at all" do
        assert react("abAB") == "abAB"
    end
 
    test "react larger" do
        assert react("dabAcCaCBAcCcaDA") == "dabCBAcaDA"
    end


end

initial = DayFive.load_data("day_5_input.txt")
result_str = initial |> DayFive.react
IO.puts "Answer ONE: #{length(String.to_charlist(intitial))}"
IO.puts "Answer TWO: #{}"

