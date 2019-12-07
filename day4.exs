defmodule DayFour do
    
    def load_data(file_name) do
        File.read!(file_name)
        |> String.trim
        |> String.split("\n")
        |> sort_records
    end

    def sort_records(records) do
        records
        |> Enum.sort
    end

    def parse_time_and_date(datestr) do
        [date, time] = datestr |> String.split(" ")
        parsed_date = String.split(date, "-") 
                      |> Enum.reduce({},
                          fn val, acc -> Tuple.append(acc, String.to_integer(val)) 
                          end)
        parsed_time = String.split(time, ":")
                      |> Enum.reduce({},
                          fn val, acc -> Tuple.append(acc, String.to_integer(val))
                          end)
        [parsed_date, parsed_time]
    end

    def parse_id_and_action(idaction) do
        regex = ~r/Guard #(?<id>[0-9]+) begins shift/
            cond do
                String.contains?(idaction, "#") ->
                    %{"id" => id} = Regex.named_captures(regex, idaction)
                    {String.to_integer(id), :begins}
                String.contains?(idaction, "asleep") ->
                    {0, :sleep}
                String.contains?(idaction, "wakes") ->
                    {0, :wakes}
            end
    end

    def parse_record(record) do
        regex = ~r/\[(?<time>.+)\](?<action>.+)/
        %{"time" => time, "action" => action} = Regex.named_captures(regex, record)
        [d, t] = parse_time_and_date(time)
        {id, ac} = parse_id_and_action(action)
        {d, t, id, ac}
    end


end


ExUnit.start()

defmodule DayFourTest do
    import DayFour
    use ExUnit.Case

    setup do
        data = [ "[1518-11-01 00:00] Guard #10 begins shift",
                "[1518-11-01 00:05] falls asleep",
                "[1518-11-01 00:25] wakes up",
                "[1518-11-01 00:30] falls asleep",
                "[1518-11-01 00:55] wakes up",
                "[1518-11-01 23:58] Guard #99 begins shift",
                "[1518-11-02 00:40] falls asleep",
                "[1518-11-02 00:50] wakes up",
                "[1518-11-03 00:05] Guard #10 begins shift",
                "[1518-11-03 00:24] falls asleep",
                "[1518-11-03 00:29] wakes up",
                "[1518-11-04 00:02] Guard #99 begins shift",
                "[1518-11-04 00:36] falls asleep",
                "[1518-11-04 00:46] wakes up",
                "[1518-11-05 00:03] Guard #99 begins shift",
                "[1518-11-05 00:45] falls asleep",
                "[1518-11-05 00:55] wakes up" ]
        {:ok, data: data}
    end

    test "should sort list in time order", context do
       assert sort_records(Enum.shuffle(context[:data])) == context[:data]
    end

    test "should parse time and date string" do
        assert parse_time_and_date("1518-11-01 00:00") == [{1518, 11, 1}, {0, 0}]
    end

    test "should parse id and action" do
        assert parse_id_and_action("Guard #10 begins shift") == {10, :begins}
    end

    test "should parse shift begin", context do
        shift_start = context[:data] |> List.first
        assert parse_record(shift_start) == {{1518,11,01}, {00,00}, 10, :begins}
    end

    test "should parse fall asleep", context do
        fall_asleep = context[:data] |> Enum.at(1)
        assert {{1518,11,01},{0,5}, _, :sleep} = parse_record(fall_asleep)
    end
    
    test "should parse wakes up", context do
        fall_asleep = context[:data] |> Enum.at(2)
        assert {{1518,11,01},{0,25}, _, :wakes} = parse_record(fall_asleep)
    end

end


