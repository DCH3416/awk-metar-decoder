# awk-metar-decoder
Metar decoder written in awk, outputs to WeatherSTAR format or json

Usage:

  ```awk -f ./metar.awk ./METAR.file```

JSON output:

  ```awk -f ./metar.awk -v json=1 ./METAR.file```

Short output (LO, RC):

  ```awk -f ./metar.awk -v outmode=2 ./METAR.file```
  
  ```awk -f ./metar.awk -v outmode=3 ./METAR.file```

Set units:
  ```awk -f ./metar.awk -v setunits=2 ./METAR.file```
  
  Where ```setunits=1``` for US. ```setunits=2``` for international. ```setunits=0``` to passthrough.

Display Location:

  ```awk -f ./metar.awk -v disploc='City Name' ./METAR.file```
