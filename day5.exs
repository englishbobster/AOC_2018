defmodule DayFive do
    
    def react(str) do
        {_, reduced} = str |> String.to_charlist
        |> Enum.reduce({0,''}, fn ch, {prev_ch,result} ->
            if length(result) == 0 or abs(prev_ch - ch) != 32 do
                {ch, result ++ [ch]}
            else
                {_, rest} = List.pop_at(result, -1)
                {0, rest}
            end
        end)
        String.Chars.to_string(reduced)
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
