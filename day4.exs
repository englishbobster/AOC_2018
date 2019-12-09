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
                    {nil, :sleep}
                String.contains?(idaction, "wakes") ->
                    {nil, :wakes}
            end
    end

    def parse_record(record) do
        regex = ~r/\[(?<time>.+)\](?<action>.+)/
        %{"time" => time, "action" => action} = Regex.named_captures(regex, record)
        [d, t] = parse_time_and_date(time)
        {id, ac} = parse_id_and_action(action)
        {d, t, id, ac}
    end
    
    def parse_records(records) do
        parse_records(records, nil, [])
    end
    def parse_records([], _, current_result) do
        current_result
    end
    def parse_records([head|tail], currentid, current_result) do
        case parse_record(head) do
            {d, t, nil, ac} ->
                parse_records(tail, currentid, current_result ++ [{d, t, currentid, ac}])
            {d, t, id, ac} ->
                parse_records(tail, id, current_result ++ [{d, t, id, ac}])
        end
    end


    def minutes_asleep(records) do
        minutes_asleep(records, 0, %{})
    end
    def minutes_asleep([], _, result_map) do
        result_map
    end
    def minutes_asleep([{_date, {_hr, _min}, id, :begins}|t], _current_minute, result_map) do
        if get_in(result_map, [id]) == nil do
            minutes_asleep(t, 0, put_in(result_map, [id], 0))
        else
            minutes_asleep(t, 0, result_map)
        end
    end
    def minutes_asleep([{_date, {_hr, min}, _id, :sleep}|t], _current_minute, result_map) do
        minutes_asleep(t, min, result_map) 
    end
    def minutes_asleep([{_date, {_hr, min}, id, :wakes}|t], current_minute, result_map) do
        timediff = min - current_minute
        minutes_asleep(t, 0, update_in(result_map, [id], fn val -> val + timediff end))
    end

    def find_sleepiest(records) do
        records
        |> sort_records() 
        |> parse_records()
        |> minutes_asleep()
        |> Enum.reduce({0, 0}, fn {k, v}, {id, min} ->
            if (v > min) do
                {k,v}
            else
                {id, min} 
            end
        end)
    end     

    def get_records_with_id(records, id) do
        records |> sort_records() |> parse_records()
        |> Enum.filter(fn {_d, _t, i, _ac} -> i == id end) 
    end

    def create_ranges(records) do
        create_ranges(records, 0, 0, %{}) 
    end
    def create_ranges([]. _, _, result_map) do
        result_map
    end
    def create_ranges([{date, {_hr, min}, _id, :begins}|t], _start, _stop, result_map) do
        if get_in(result_map, [date]) == nil do
            create_ranges(t, 0, 0, put_in(result_map, [date], 0))
        else #not gonna work since we will prolly have more than one range on a given day
            create_ranges(t, 0, result_map)
        end
    end
    def create_ranges([{date, {_hr, min}, _id, :sleep}|t], _start, _stop, result_map) do
    end
    def create_ranges([{date, {_hr, min}, _id, :wakes}|t], _start, _stop, result_map) do
    end

    def find_sleepiest_minute(records) do
        {id, _min} = find_sleepiest(records)
        id_recs = get_records_with_id(records, id)
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

    test "should create minute range" do
        data = [{{1518, 3, 10}, {23, 57}, 73, :begins}, 
            {{1518, 3, 11}, {0, 6}, 73, :sleep},
            {{1518, 3, 11}, {0, 22}, 73, :wakes}]
        assert create_ranges(data) == {{1518, 3, 11}, 6..21}
    end

    test "should produce sleep cycle for first guard" do
        testdata = [{{1518, 11, 1},{0, 0}, 10, :begins},
            {{1518, 11, 1},{0, 5}, 10, :sleep}, 
            {{1518, 11, 1},{0, 25}, 10, :wakes},
            {{1518, 11, 1},{0, 30}, 10, :sleep}, 
            {{1518, 11, 1},{0, 55}, 10, :wakes}]
        assert minutes_asleep(testdata) == %{10 => 45}
    end

    test "should find sleepiest", context do
        assert find_sleepiest(context[:data]) == {10, 50}
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

    test "should parse begin asleep wakesup", context do
        triplet = context[:data] |> Enum.slice(0, 3)
        assert parse_records(triplet) == [{{1518,11,01}, {00,00}, 10, :begins},
            {{1518,11,01}, {00,5}, 10, :sleep}, {{1518,11,01},{0,25}, 10, :wakes}] 
    end

    test "should parse all", context do
        thedata = context[:data] 
        assert parse_records(thedata) |> List.last == {{1518,11,05},{0,55}, 99, :wakes} 
    end


end

initial = DayFour.load_data("day_4_input.txt")
#IO.puts "Answer ONE: #{initial |> DayFour.find_sleepiest_minute}"
