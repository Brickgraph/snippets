let
    // Replace REPORT-CODE with the code, available from the Brickgraph app Reports page
    ApiUrl = "https://public.brickgraph.io/reports/ORG-UID/REPORT-CODE",
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
        CheckRecords = if Source[records] = 0 then null else Source,
        ProcessData = if CheckRecords = null then null else
            let
                data = Source[data],
                tableFromData = Table.FromList(data, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
                expandedColumn = Table.ExpandRecordColumn(tableFromData, "Column1", {"record"}, {"record"}),
                // Get all column names
                firstRecord = expandedColumn{0}[record],
                allFieldNames = if firstRecord <> null then Record.FieldNames(firstRecord) else {},
                // Dynamically expand all fields
                finalTable = Table.ExpandRecordColumn(expandedColumn, "record", allFieldNames, allFieldNames)
            in
                finalTable
    in
        ProcessData,

    FetchAllPages = (offset) =>
        let
            CurrentPage = FetchData(offset),
            CombinedData = if CurrentPage = null then
                        Table.FromRecords({})  // Return an empty table when there's no more data
                    else if offset = 0 then
                        Table.Combine({CurrentPage, @FetchAllPages(offset + Limit)})
                    else
                        Table.Combine({CurrentPage, @FetchAllPages(offset + Limit)})
        in
            CombinedData,

    AllData = FetchAllPages(0)
in
    AllData