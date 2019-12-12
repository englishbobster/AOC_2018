defmodule DayFive do

    def react(str) do
        {_na, res} = str
        |> String.to_charlist 
        |> Enum.reduce({' ',''}, fn ch, {current, result} ->
            if (abs(ch - List.first(current))) != 32 do
                {' ', result}
            else
                {[ch], result ++ [ch]}
            end
        end)
        String.Chars.to_string(res)
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
