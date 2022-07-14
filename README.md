# awk-metar-decoder
Metar decoder written in awk, outputs to WeatherSTAR format or json

Usage:
  "awk -f ./metar.awk ./METAR.file"
  
JSON output:
  "awk -f ./metar.awk -v json=1 ./METAR.file"
