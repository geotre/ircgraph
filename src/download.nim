
import
  std/[os, strformat, strutils, xmltree, streams, htmlparser],
  pkg/[chrono, puppy, nimquery],
  ./common


proc getDate(currentDay: Calendar) =
  let
    date = currentDay.format("{day/2}-{month/2}-{year/4}")
    filePath = &"downloads/{date}.txt"

  if fileExists(filePath):
    echo &"Skipping existing file: {filePath}"
    return

  let url = &"https://irclogs.nim-lang.org/{date}.html"
  var html: string
  
  try:
    html = fetch(url)
  except PuppyError as e:
    if e.msg.startsWith("Non 200 response code:"):
      echo &"Error: {e.msg}"
      echo &"(for url: {url})"
      return
    else:
      raise e

  let
    xml = parseHtml(newStringStream(html))
    elements = xml.querySelectorAll("td")

  let fs = newFileStream(filePath, fmWrite)
  var lines = 0

  for elem in elements:
    let text = elem.innerText
    if not text.isTime:
      continue
    fs.writeLine(text)
    lines.inc

  fs.close()

  if lines == 0:
    echo &"Warning, no lines in file: {filePath}"
    removeFile(filePath)
    quit(0)  # we've probably reached the end
  else:
    echo &"Saved file: {filePath}"
    sleep(5000)  # rate limit, be kind to server


when isMainModule:
  # start at 2012-05-30 which seems to be the earliest date available
  var currentDay = Calendar(year: 2012, month: 5, day: 30, hour: 0, minute: 0, second: 0)

  while true:
    getDate(currentDay)
    currentDay.add(Day, 1)
