-module(cs_preflist_finder).

%% Note that this should be run from `riak escript`, not `riak-cs escript`

%% script_main is where the action is
script_main(_LocalNode, TargetNode, _Cookie, [CSBucketIn, CSKeyIn, NValueIn]) ->
    FindPreflist = fun(CSBucket, CSKey, NValue) ->
        KVBucket = <<"0o:", (crypto:hash(md5, CSBucket))/binary>>,
        KVKey = CSKey,
        BKey = {KVBucket,KVKey},
        {ok, Ring} = riak_core_ring_manager:get_my_ring(),
        DocIdx = riak_core_util:chash_key(BKey),
        UpNodes = riak_core_ring:all_members(Ring),
        Preflist = riak_core_apl:get_apl_ann(DocIdx, list_to_integer(NValue), Ring, UpNodes),
        [IndexNode || {IndexNode, _Type} <- Preflist]
    end,
    io:format("Connecting to ~p to find preflist for CS identifier pair ~s ~s~n",[TargetNode, CSBucketIn, CSKeyIn]),
    io:format("~p~n",[rpc:call(TargetNode, erlang, apply, [FindPreflist, [CSBucketIn, CSKeyIn, NValueIn]], infinity)]);
script_main(_LocalNode, _TargetNode, _Cookie, _) ->
    usage().

usage() ->
    io:format("Usage: riak escript <path/to/cs_preflist_finder.erl> [options] <CSBucket> <CSKey> <NValue>~n"),
    io:format("  Options:~n"),
    io:format("\t-c|--cookie <cookie>\t\tDistribution cookie~n"),
    io:format("\t-n|--nodename <nodename>\t\tLocal node name~n"),
    io:format("\t-t|--targetnode <nodename>\t\tName of Riak node to connect to~n"),
    ok.


%%common boilerplate

main(Args) ->
    {MyNode, TargetNode, Cookie, RestArgs} = parse_args(Args),
    {MyName, TargetName, CookieName} = determine_target(MyNode, TargetNode, Cookie),
    {ok, _} = net_kernel:start([MyName]),
    true = erlang:set_cookie(node(),CookieName),
    pong = net_adm:ping(TargetName),
    script_main(MyName, TargetName, CookieName, RestArgs).

parse_args(Args) ->
    parse_args(Args,[]).

parse_args([], Options) ->
    {proplists:get_value(nodename, Options),
     proplists:get_value(targetnode, Options),
     proplists:get_value(cookie, Options),
     lists:reverse(proplists:get_value(args, Options, []))};
parse_args([Opt,NodeName|Rest], Options) when Opt =:= "-t"; Opt =:= "--target"; Opt =:= "--targetnode" ->
    parse_args(Rest, [{targetnode, make_atom(NodeName)} | proplists:delete(targetnode,Options)]);
parse_args([Opt,NodeName|Rest], Options) when Opt =:= "-n"; Opt =:= "--node"; Opt =:= "--nodename" ->
    parse_args(Rest, [{nodename, make_atom(NodeName)} | proplists:delete(nodename,Options)]);
parse_args([Opt,Cookie|Rest], Options) when Opt =:= "-c"; Opt =:= "--cookie"; Opt =:= "--setcookie" ->
    parse_args(Rest, [{cookie, make_atom(Cookie)} | proplists:delete(cookie,Options)]);
parse_args([Other|Rest], Options) ->
    Prev = proplists:get_value(args, Options, []),
    parse_args(Rest, [{args, [Other|Prev]}|Options]).

determine_target(undefined, undefined, undefined) ->
    {ok, Name} = find_env(code:which(riak_core)),
    Cmd = "/bin/sh -c '. " ++ Name ++ "/env.sh; echo \"${NAME_ARG}|${COOKIE_ARG}\" | sed -e \"s/-[^ ]* //g\"' " ++ Name ++ "/env.sh",
    Data = os:cmd(Cmd),
    [NodeStr,CookieStr] = string:tokens(Data,"|"),
    Node = make_atom(strip(NodeStr)),
    MyName = make_atom("bucket_resolver" ++ strip(NodeStr)),
    Cookie = make_atom(strip(CookieStr)),
    {MyName, Node, Cookie};
determine_target(MyName, TargetName, CookieName) when MyName =/= undefined, TargetName =/= undefined, CookieName =/= undefined ->
    {MyName, TargetName, CookieName};
determine_target(MyName, TargetName, CookieName) ->
    {Name, Target, Cookie} = determine_target(undefined, undefined, undefined),
    {pick_defined(MyName, Name),
     pick_defined(TargetName, Target),
     pick_defined(CookieName, Cookie)}.

pick_defined(undefined, ValueB) ->
    ValueB;
pick_defined(ValueA, _) ->
    ValueA.

make_atom(A) when is_list(A) ->
    list_to_atom(A);
make_atom(A) when is_atom(A) ->
    A.

strip(L) ->
    strip(L,[$\ ,$\n]).

strip(L,[]) -> L;
strip(L,[C|Rest]) ->
    strip(string:strip(L, both, C), Rest).

find_env([]) ->
    erlang:error("file not found env.sh");
find_env("/") ->
    find_env([]);
find_env(Path) ->
    case filelib:is_file(filename:join(Path,"env.sh")) of
        true -> {ok,Path};
        false -> find_env(filename:dirname(Path))
    end.