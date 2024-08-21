let
    // Replace ORG-UID and ENTITY-TYPE with the appropriate values
    ApiUrl = "https://public.brickgraph.io/reports/ORG-UID/relationship/RELATIONSHIP-TYPE",
    // Replace API-KEY with one of your api keys, available from the Brickgraph app
    ApiKey = "API-KEY",
    Limit = 100,

    FetchData = (Offset) =>
        let
            Source = Json.Document(Web.Contents(ApiUrl, [
                Query = [
                    api_key = ApiKey,
                    offset = Text.From(Offset),
                    limit = Text.From(Limit)
                ]
            ])),
            data = Source[data]
        in
            data,

    FetchAllPages = (offset) =>
        let
            CurrentPage = FetchData(offset),
            NextPage = if List.Count(CurrentPage) < Limit then null else @FetchAllPages(offset + Limit),
            CombinedData = List.Combine({CurrentPage, NextPage})
        in
            if NextPage = null then CurrentPage else CombinedData,

    AllData = FetchAllPages(0),
    ToTable = Table.FromList(AllData, Splitter.SplitByNothing(), null, null, ExtraValues.Error)
in
    ToTable