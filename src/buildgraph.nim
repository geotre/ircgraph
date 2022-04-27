
import
  std/[os, strformat, strutils, tables],
  pkg/[chrono, nimja],
  ./common


type
  StatsTable = OrderedTable[string, int]

  YearData = object
    year: int
    values: ValueList
    totalMessages: int

  ValueList = seq[tuple[t: string, v: int]]


proc collectStats(year: int): StatsTable =
  # initialize result table
  for hour in 0..23:
    for minute in 0..59:
      result[&"{hour:02d}:{minute:02d}"] = 0

  var day = Calendar(year: year, month: 1, day: 1, hour: 0, minute: 0, second: 0)

  while day.year == year:
    let
      date = day.format("{day/2}-{month/2}-{year/4}")
      filePath = &"downloads/{date}.txt"

    day.add(Day, 1)

    if not filePath.fileExists:
      echo &"Skipping day: {filePath}"
      continue

    for line in lines(filePath):
      if line.len != 8:
        continue
      if not line.isTime():
        continue
      try:
        result[line[0..4]] = result[line[0..4]] + 1
      except KeyError:
        echo "Missing key? ", line[0..4]
        quit(1)


proc buildTemplate(years: seq[YearData]): string =
  compileTemplateFile(getScriptDir() / "template.html")


proc buildGraphs(startYear, endYear: int) =
  var years: seq[YearData]

  for year in startYear..endYear:
    let stats = collectStats(year)

    var values: ValueList
    var maxCount = 0

    for key, val in stats:
      if val > maxCount:
        maxCount = val

    var total = 0

    for key, val in stats:
      values.add (key, int(val / maxCount * 100))
      total += val

    years.add YearData(year: year, values: values, totalMessages: total)

  writeFile(&"index.html", buildTemplate(years))


when isMainModule:
  buildGraphs(2012, 2022)
