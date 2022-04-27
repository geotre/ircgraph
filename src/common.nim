

proc isTime*(t: string): bool =
  # Check if string matches time format, e.g. 22:41:57
  # This is ugly
  if t.len != 8: return
  if not (t[0] in {'0'..'9'}): return
  if not (t[1] in {'0'..'9'}): return
  if t[2] != ':': return
  if not (t[3] in {'0'..'9'}): return
  if not (t[4] in {'0'..'9'}): return
  if t[5] != ':': return
  if not (t[6] in {'0'..'9'}): return
  if not (t[7] in {'0'..'9'}): return
  return true
