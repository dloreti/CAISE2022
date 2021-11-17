% Utility for adding timestamps to traces that born without timestamps.

add :-
    InputFileName = 'dreyers_negatives_without_timestamps.xes'
    , OutputFileName = 'dreyers_negatives_timestamps.xes'

    , open(InputFileName, read, InputStream)
    , open(OutputFileName, write, OutputStream)

        , process_single_line(InputStream, OutputStream, 0, 1)

    , close(InputStream)
    , close(OutputStream)
    .

%  process_single_line(InputStream, OutputStream, CurrentTime, EventPosition)
process_single_line(InputStream, OutputStream, CurrentTime, EventPosition) :-
    read_line_to_string(InputStream, Line)
    , write_single_line(Line, InputStream, OutputStream, CurrentTime, EventPosition).


%% </log>
write_single_line(Line, _InputStream, OutputStream, _CurrentTime, _EventPosition) :-
    sub_string(Line, _Start, 6, _After, "</log>") 
    , !
    , write(OutputStream, Line).
%% <event>
write_single_line(Line, InputStream, OutputStream, CurrentTime, EventPosition) :-
    sub_string(Line, _Start, 7, _After, "<event>") 
    , !
    , write(OutputStream, Line)
    , nl(OutputStream)
        , CurrentTimestamp is CurrentTime + EventPosition
        , NewEventPosition is EventPosition + 1 
	    , format_time(string(StampString), '%FT%T.000%:z', CurrentTimestamp)
	    , atomics_to_string([
		    '\t\t\t<date key="time:timestamp" value="', StampString, '"></date>'
	    ], TheString)
    , write(OutputStream, TheString)
    , nl(OutputStream)
    , process_single_line(InputStream, OutputStream, CurrentTime, NewEventPosition)
    .
%% <trace>
write_single_line(Line, InputStream, OutputStream, _CurrentTime, _EventPosition) :-
    sub_string(Line, _Start, 7, _After, "<trace>") 
    , !
    , write(OutputStream, Line)
    , nl(OutputStream)
        , get_time(NewCurrentTime)
    , process_single_line(InputStream, OutputStream, NewCurrentTime, 1)
    .
%% all the others
write_single_line(Line, InputStream, OutputStream, CurrentTime, EventPosition) :-
    write(OutputStream, Line)
    , nl(OutputStream)
    , process_single_line(InputStream, OutputStream, CurrentTime, EventPosition)
    .