# awk-metar-decoder
Metar decoder written in awk, outputs to WeatherSTAR format or json

Usage:
  "awk -f ./metar.awk ./METAR.file"
  
JSON output:
  "awk -f ./metar.awk -v json=1 ./METAR.file"

Short output (LO, RC):
  "awk -f ./metar.awk -v outmode=2 ./METAR.file"
  "awk -f ./metar.awk -v outmode=3 ./METAR.file"

Display Location:
  "awk -f ./metar.awk -v disploc='City Name' ./METAR.file"
