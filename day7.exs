defmodule DaySeven do
  
    def load_data(file_name) do
        File.read!(file_name)
        |> String.trim
        |> String.split("\n")
    end

end

ExUnit.start()

defmodule DaySevenTest do
    import DaySeven
    use ExUnit.Case

    test "should do something" do
        assert true == true
    end

end

