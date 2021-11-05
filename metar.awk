#MIT License
#
#Copyright (c) 2021 DCH3416
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

function abs(n) { return n < 0 ? -n : n }

BEGIN {

# icon default
icoobs = "na.png";

#Set Units:
if (!setunits) {
setunits = 1;
}

# 0 to pass.
# 1 for US.
# 2 for international.
# Incomplete.

}

{

#Todo:
# Interpret international METAR
# Remarks, AO2 station readings, etc.
# Complete units conversion

if (jsenable == 1 || jsenable == 2) {
	dval = "\\\\"
} else if(starfmt == 1) {
	dval = "\\"
} else {
	dval = "°";
}
    # Begin read

    for(i=1; i<=NF; i++) {

        vis=match($i, /[0-9]?..SM/)

        # Valid Time
        if ($i ~ /^......Z$/) {
		#valid time
		vdatt_z = $i;
		vzx = substr($i, 3, 5);
		vzhx = substr(vzx, 0, 2);
		vzmx = substr(vzx, 3, 2);

		#currently supports hourly, negative time zones, dirty
		ch = strftime("%H");
		cz = strftime("%z");
		czx = substr(cz, 0, 3)
		chx = (ch - czx) % 24;
		cmx = strftime("%M");
		cdatt_z = sprintf("%s%02.0f%sZ", strftime("%d") ,chx, cmx);

		datt = sprintf("Now: %s  --  Val: %s", cdatt_z, vdatt_z);
		i--;
		code = $i;
		i++;
	}

	# Sky conditions group
	if ($i ~ /^VV.../ || $i ~ /^CLR/ || $i ~ /^FEW...?.?./ ||
		$i ~ /^SCT...?.?.?.$/ || $i ~ /^BKN...?.?.?./ ||
		$i ~ /^OVC...?.?./ || $i ~ /^SKC/) {

            # Sky cover in 8ths, (few cloud (M Clear?), P Cloudy, M Cloudy, Cloudy)

            sc = 0;
            if ($i ~ /^FEW/) { sc = 1; }
            if ($i ~ /^SCT/) { sc = 3; }
            if ($i ~ /^BKN/) { sc = 5; }
            if ($i ~ /^OVC/) { sc = 8; }

            #ceiling, probably needs rewritten

            c0u = "ft.";

	    if ($i ~ /^VV.../ || $i ~ /^BKN/ || $i ~ /^OVC/) {
                if (match($i, /[+0-9]*$/) && Fc0 == 0) {
                    cx = substr($i, RSTART, RLENGTH);
                    c0 = cx;
                    if (length(cx) != 0) {
                        c0s = sprintf("Ceiling:%3.0f00 %s", c0, c0u);
                        Fc0 = 1 # Found
                    }
                }
            } else if ($i ~ /^CLR/ || $i ~ /^FEW...?.?./ || $i ~ /^SCT...?.?.?.$/) {
                if (Fc0 == 0) {
                    # Ceiling is Unlimited:
                    # Must report sky condition
                    c0s = "Ceiling Unlimited";
                }
            }

            if (sc == 0 && $i ~ /SKC/) {
				#CLEAR/SUNNY, manual obs
				skyobs = "Clear";
				shskyobs = sprintf("Clear");
				# icon support
				icoobs = "Sunny.png";
				if (night == 1) { icoobs = "Clear.png"; }
			} else if (sc == 0 && $i ~ /CLR/) {
				#Most stations are AUTO
                skyobs = "Clear Below 12,000 ft.";
				shskyobs = sprintf("Fair");
				# icon support
				icoobs = "Fair.png";
				if (night == 1) { icoobs = "Mostly-Clear.png" }	
            }
            if (sc >= 1 && sc <= 2) {
		#Technically
                #skyobs = "A Few Clouds";
		#But we'll show
                skyobs = "Partly Cloudy";
				shskyobs = sprintf("P Cloudy");
				# icon support
				icoobs = "Partly-Cloudy.png";
				if (night == 1) { icoobs = "Mostly-Clear.png" }
            }
            if (sc >= 3 && sc <= 4) {
                skyobs = "Partly Cloudy";
				shskyobs = sprintf("P Cloudy");
				# icon support
				icoobs = "Partly-Cloudy.png";
				if (night == 1) { icoobs = "Mostly-Clear.png" }
            }
            if (sc >= 5 && sc <= 7) {
                skyobs = "Mostly Cloudy";
				shskyobs = sprintf("M Cloudy");
				# icon support
				icoobs = "Mostly-Cloudy.png";
				if (night == 1) { icoobs = "Partly-Clear.png" }
            }
            if (sc == 8) {
                skyobs = "Cloudy";
				shskyobs = sprintf("Cloudy  ");
				icoobs = "Cloudy.png";
            }

			# Windy (Special)
			if (ws0mph > 20) {
				if (length(skyobs) != 0) {
					skyobs = sprintf("%s and Windy ", skyobs);
					# icon support
					if (icoobs == "Fair.png") { 
						icoobs = "Fair-Wind.png";
					} else if (icoobs == "Partly-Cloudy.png") { 
						icoobs = "Partly-Cloudy-Wind.png";
					} else if (icoobs == "Mostly-Cloudy.png") { 
						icoobs = "Mostly-Cloudy-Wind.png";
					} else if (icoobs == "Mostly-Clear.png") { 
						icoobs = "Mostly-Clear-Wind.png";
					} else if (icoobs == "Partly-Clear.png") { 
						icoobs = "Partly-Clear-Wind.png";
					} else if (icoobs == "Cloudy.png") { 
						icoobs = "Cloudy-Wind.png";
					}
				}
				if (sc == 0) {
					skyobs = sprintf("Windy ");
					shskyobs = sprintf("Windy   ");
					# icon support
					icoobs = "Sunny-Wind.png";
					if (night == 1) { icoobs = "Clear-Wind.png" }
				}
			}

            Fsc0 = 1; # Found
		}

        # Weather group
        else if ($i ~ /[A-Z].?.?./ && i > 2) {

            # 1. Intensity
            wix = 0;
            if ($i ~ /-/ ) { wix_l = 1 } # Light
            if ($i ~ /\+/) { wix_h = 1 } # Heavy
            if ($i ~ /VC/) { wix_v = 1 } # Vicinity

            # 2. Descriptor
            if ($i ~ /DR/) { wdx_dr = 1 } # Drifting
            if ($i ~ /BL/) { wdx_bl = 1 } # Blowing
            if ($i ~ /BLSN/) { wdx_bl = 1 } # Blowing Snow
            if ($i ~ /SH/) { wdx_sh = 1 } # Showers
            if ($i ~ /TS/) { wdx_ts = 1 } # Thunderstorm
            if ($i ~ /FZ/) { wdx_fz = 1 } # Freezing
            if ($i ~ /FZFG/) { wdx_fzfg = 1 } # Freezing Fog

            # 3. Condition
            if ($i ~ /DZ/) { wcx_dz = 1 } # Drizzle
            if ($i ~ /RA/) { wcx_ra = 1 } # Rain
            if ($i ~ /SN/) { wcx_sn = 1 } # Snow
            if ($i ~ /IC/) { wcx_ic = 1 } # Ice Crystals
            if ($i ~ /PL/) { wcx_pl = 1 } # Ice Pellets
            if ($i ~ /GR/) { wcx_gr = 1 } # Hail
            if ($i ~ /GS/) { wcx_gs = 1 } # Small Hail
            if ($i ~ /UP/) { wcx_up = 1 } # Unknown Precipitation

            # 4. Obscuration
            if ($i ~ /BR/) { wcx_fg = 1 } # Mist - Set to display Fog
            if ($i ~ /FG/) { wcx_fg = 1 } # Fog
            if ($i ~ /FU/) { wcx_fu = 1 } # Smoke
            if ($i ~ /VA/) { wcx_va = 1 } # Volcanic Ash
            if ($i ~ /DU/) { wcx_du = 1 } # Dust
            if ($i ~ /SA/) { wcx_sa = 1 } # Sand
            if ($i ~ /HZ/) { wcx_hz = 1 } # Haze
            if ($i ~ /PY/) { wcx_py = 1 } # Spray

            # Compose observation

            obs = ""; shobs = "";

            # Drizzle conditions
            if (wcx_dz == 1) {
                if (wix_l == 1) { obs = sprintf("%sLight ", obs) }
                if (wix_h == 1) { obs = sprintf("%sHeavy ", obs) }

                if (wdx_fz == 1) { obs = sprintf("%sFreezing ", obs) }

                obs = sprintf("%sDrizzle ", obs);

                if (wdx_ts == 1) { obs = sprintf("%swith Thunder ", obs) }
                if (wix_v == 1) { obs = sprintf("%sin Vicinity ", obs) }

                if (wcx_fg == 1) { obs = sprintf("%sand Fog ", obs) }
                if (wcx_br == 1) { obs = sprintf("%sand Mist ", obs) }

		#shobs
                shobs = sprintf("Drizzle ", shobs);
                if (wix_l == 1) { shobs = sprintf("Lgt Drzl") }
                if (wix_h == 1) { shobs = sprintf("Hvy Drzl") }
                if (wix_fz == 1) { shobs = sprintf("Frz Drzl") }
		# icon support
				icoobs = "Shower.png";
            }
            # Rain conditions
            else if (wcx_ra == 1) {
                if (wix_l == 1) { obs = sprintf("%sLight ", obs) }
                if (wix_h == 1) { obs = sprintf("%sHeavy ", obs) }

                if (wdx_fz == 1) { obs = sprintf("%sFreezing ", obs) }
                if (wdx_bl == 1) { obs = sprintf("%sBlowing ", obs) }
                if (wdx_dr == 1) { obs = sprintf("%sDrifting ", obs) }

                obs = sprintf("%sRain ", obs);
                if (wdx_sh == 1) { obs = sprintf("%sShowers ", obs) }

                if (wdx_ts == 1) { obs = sprintf("%swith Thunder ", obs) }
                if (wix_v == 1) { obs = sprintf("%sin Vicinity ", obs) }

                if (wcx_fg == 1) { obs = sprintf("%sand Fog ", obs) }
                if (wcx_br == 1) { obs = sprintf("%sand Mist ", obs) }

		#shobs
		shobs = sprintf("Rain    ", shobs);
                if (wix_l == 1)  { shobs = sprintf("Lgt Rain") }
                if (wix_h == 1)  { shobs = sprintf("Hvy Rain") }
                if (wix_fz == 1) { shobs = sprintf("Frz Rain") }
                if (wix_sh == 1) { shobs = sprintf("Rain Swr") }
                if (wdx_ts == 1)  { shobs = sprintf("T Storm ") }
		# icon support
				icoobs = "Rain.png";
				if (wcx_pl == 1)  { icoobs = sprintf("Rain-Sleet.png") }
				if (wdx_ts == 1)  { icoobs = sprintf("Thunderstorm.png") }
            }
            # Snow conditions
            else if (wcx_sn == 1) {
                if (wix_l == 1) { obs = sprintf("%sLight ", obs) }
                if (wix_h == 1) { obs = sprintf("%sHeavy ", obs) }

                if (wdx_bl == 1) { obs = sprintf("%sBlowing ", obs) }
                if (wdx_dr == 1) { obs = sprintf("%sDrifting ", obs) }

                obs = sprintf("%sSnow ", obs);
                if (wdx_sh == 1) { obs = sprintf("%sShowers ", obs) }

                if (wdx_ts == 1) { obs = sprintf("%swith Thunder ", obs) }
                if (wix_v == 1) { obs = sprintf("%sin Vicinity ", obs) }

                if (wdx_fz == 1 && wcx_fg == 1) { obs = sprintf("%sand Freezing Fog ", obs) }
                if (wdx_fz == 0 && wcx_fg == 1) { obs = sprintf("%sand Fog ", obs) }
                if (wcx_br == 1) { obs = sprintf("%sand Mist ", obs) }
                if (wcx_hz == 1) { obs = sprintf("%sand Haze ", obs) }

		#shobs
				shobs = sprintf("Snow    ", shobs);
                if (wix_l == 1)  { shobs = sprintf("Lgt Snow") }
                if (wix_h == 1)  { shobs = sprintf("Hvy Snow") }
                if (wix_fz == 1) { shobs = sprintf("Frz Snow") }
                if (wdx_bl == 1) { shobs = sprintf("Blo Snow") }
                if (wdx_dr == 1) { shobs = sprintf("Drf Snow") }
                if (wdx_sh == 1) { shobs = sprintf("Snow Swr") }
		# icon support
				icoobs = "Snow.png";
				if (wix_l == 1)  { icoobs = sprintf("Light-Snow.png") }
				if (wcx_ra == 1) { icoobs = sprintf("Rain-Snow.png") }
				if (wcx_pl == 1)  { icoobs = sprintf("Snow-Sleet.png") }
				if (wdx_bl == 1) { icoobs = sprintf("Blowing-Snow.png") }
				if (wdx_ts == 1)  { icoobs = sprintf("ThunderSnow.png") }
            }
            # Thunderstorm
            else if (wdx_ts == 1 ) {
                if (wix_l == 1) { obs = sprintf("%sLight ", obs) }
                if (wix_h == 1) { obs = sprintf("%sHeavy ", obs) }

                obs = sprintf("%sThunderstorm ", obs)

                if (wcx_fg == 1) { obs = sprintf("%sand Fog ", obs) }
                if (wcx_br == 1) { obs = sprintf("%sand Mist ", obs) }

		#shobs
		shobs = sprintf("T Storm ", shobs);
                if (wix_l == 1)  { shobs = sprintf("Lgt Tsrm") }
                if (wix_h == 1)  { shobs = sprintf("Hvy Tsrm") }
		# icon support
				icoobs = "Thunderstorm.png";
            }
            # Dust
            else if (wcx_du == 1 ) {
                if (wdx_bl == 1) { obs = sprintf("%sBlowing ", obs) }

                obs = sprintf("Dust ", obs)

                if (wcx_fg == 1) { obs = sprintf("%sand Fog ", obs) }
                if (wcx_br == 1) { obs = sprintf("%sand Mist ", obs) }

		#shobs
		shobs = sprintf("DUST    ", shobs);
                if (wix_bl == 1) { shobs = sprintf("Blo Dust") }
                if (wix_l == 1)  { shobs = sprintf("Lgt Dust") }
                if (wix_h == 1)  { shobs = sprintf("Hvy Dust") }
            }
            # Sand
            else if (wcx_sa == 1) {
                obs = sprintf("%sSandstorm ", obs)

			#shobs
			shobs = sprintf("SNDSTORM", shobs);
            }
			# Smoke
			else if (wcx_fu == 1) {
				obs = sprintf("%sSmoke ", obs)

				if (wcx_fg == 1) { obs = sprintf("%swith Fog ", obs) }
				if (wcx_br == 1) { obs = sprintf("%swith Mist ", obs) }
				if (wcx_hz == 1) { obs = sprintf("%swith Haze ", obs) }

				#shobs
				shobs = sprintf("Smoke   ", shobs);
			}
	    # Misc condition
            else if (wcx_up == 1) {
                if (wix_bl == 1) { obs = sprintf("%sBlowing ", obs) }
                if (wix_l == 1) { obs = sprintf("%sLight ", obs) }
                if (wix_h == 1) { obs = sprintf("%sHeavy ", obs) }

                obs = sprintf("%sWintry Mix ", obs)

                if (wcx_fg == 1) { obs = sprintf("%sand Fog ", obs) }
                if (wcx_br == 1) { obs = sprintf("%sand Mist ", obs) }

		#shobs
		shobs = sprintf("WTRY MIX", shobs);
                if (wix_bl == 1) { shobs = sprintf("Blo Mix ") }
                if (wix_l == 1)  { shobs = sprintf("Lgt Mix ") }
                if (wix_h == 1)  { shobs = sprintf("Hvy Mix ") }
		# icon support
				icoobs = "Winty-Mix.png";
            }
	    # Fog / Mist (exclusive)
		if (wdx_fzfg == 1 && length(obs) == 0) { obs = sprintf("%sFreezing Fog ", obs) }

		if (wcx_fg == 1 && length(obs) == 0) { obs = sprintf("%sFog ", obs) }
		if (wcx_br == 1 && length(obs) == 0) { obs = sprintf("%sMist ", obs) }
		if (wcx_fu == 1 && length(obs) == 0) { obs = sprintf("%sSmoke ", obs) }
		if (wcx_hz == 1 && length(obs) == 0) { obs = sprintf("%sHaze ", obs) }

		#shobs
		if (wcx_fg == 1 && length(shobs) == 0) { shobs = sprintf("Fog     ") }
		if (wcx_br == 1 && length(shobs) == 0) { shobs = sprintf("Mist    ") }
		if (wcx_hz == 1 && length(shobs) == 0) { shobs = sprintf("Haze    ") }
		if (wcx_fu == 1 && length(shobs) == 0) { shobs = sprintf("Smoke   ") }

		# icon support
		if (wcx_fg == 1 && length(obs) == 0) { icoobs = "Fog.png" }
		if (wcx_br == 1 && length(obs) == 0) { icoobs = "Fog.png" }
		if (wcx_hz == 1 && length(shobs) == 0) { icoobs = "Haze.png" }
		
	    # Windy (special)
	    if (ws0mph > 20) {
		if (length(obs) != 0) {
			if (obs ~ /and/) {
				#match(
			}
			obs = sprintf("%s/ Wind ", obs)
			if (icoobs == "Snow.png") { icoobs = "Snow-Wind.png" }
			if (icoobs == "Rain.png") { icoobs = "Rain-Wind.png" }
		}
	    }

            Fwx0 = 1; # Found
        }

	# Winds group
	if ($i ~ /^[VRB||0-9]?...?...*KT$/) {

		wdrx = substr($i, RSTART, 3);
		wdrv = wdrx;
		wdrx = wdrx + 0; # Cast to number

		wd0 = "   ";

		# Wind direction
		if (wdrx !~ /VRB/) {
			if (wdrx >= 348.75 && wdrx <= 360 || wdrx >= 0 && wdrx < 11.25) {
				wd0 = "N";
			} if (wdrx >= 11.25 && wdrx < 33.75) {
				wd0 = "NNE";
			} if (wdrx >= 33.75 && wdrx < 56.25) {
				wd0 = "NE";
			} if (wdrx >= 56.25 && wdrx < 78.75) {
				wd0 = "ENE";
			} if (wdrx >= 78.75 && wdrx < 101.25) {
				wd0 = "E";
			} if (wdrx >= 101.25 && wdrx < 123.75) {
				wd0 = "ESE";
			} if (wdrx >= 123.75 && wdrx < 146.25) {
				wd0 = "SE";
			} if (wdrx >= 146.25 && wdrx < 168.75) {
				wd0 = "SSE";
			} if (wdrx >= 168.75 && wdrx < 191.25) {
				wd0 = "S";
			} if (wdrx >= 191.25 && wdrx < 213.75) {
				wd0 = "SSW";
			} if (wdrx >= 213.75 && wdrx < 236.25) {
				wd0 = "SW";
			} if (wdrx >= 236.25 && wdrx < 258.75) {
				wd0 = "WSW";
			} if (wdrx >= 258.75 && wdrx < 281.25) {
				wd0 = "W";
			} if (wdrx >= 281.25 && wdrx < 303.75) {
				wd0 = "WNW";
			} if (wdrx >= 303.75 && wdrx < 326.25) {
				wd0 = "NW";
			} if (wdrx >= 326.25 && wdrx < 348.75) {
				wd0 = "NNW";
			}

			#short direction
			if (wdrx >= 337.5 && wdrx <= 360 || wdrx >= 0 && wdrx < 22.5) {
				shwd0 = "N";
			} if (wdrx >= 22.5 && wdrx < 67.5) {
				shwd0 = "NE";
			} if (wdrx >= 67.5 && wdrx < 112.5) {
				shwd0 = "E";
			} if (wdrx >= 112.5 && wdrx < 157.5) {
				shwd0 = "SE";
			} if (wdrx >= 157.5 && wdrx < 202.5) {
				shwd0 = "S";
			} if (wdrx >= 202.5 && wdrx < 247.5) {
				shwd0 = "SW";
			} if (wdrx >= 247.5 && wdrx < 292.5) {
				shwd0 = "W";
			} if (wdrx >= 292.5 && wdrx < 337.5) {
				shwd0 = "NW";
			}

			#really short wind direction
			if (wdrx >= 315 && wdrx <= 360 || wdrx >= 0 && wdrx < 45) {
				rshwd0 = "N";
			} if (wdrx >= 45 && wdrx < 135) {
				rshwd0 = "E";
			} if (wdrx >= 135 && wdrx < 225) {
				rshwd0 = "S";
			} if (wdrx >= 225 && wdrx < 315) {
				rshwd0 = "W";
			}

		} if (wdrv ~ /VRB/) {
			wd0 = "Var";
		}

		# Wind speed
		if (match($i, /.*.KT/)) {
			wsx = substr($i, RSTART + 3, RLENGTH);

			split(wsx, wss, "KT");

			# Gusts
			if (wss[1] ~ /G/) {
				split(wss[1], wsg, "G");

				ws0 = wsg[1];
				wg0 = wsg[2];

			} else {
				ws0 = wss[1];
			}
		}

		# MPH, intended for calculating Wind Chill
		ws0mph = ws0 * 1.151;

			# Wind speed unit conversion
			if (setunits == 1) {
				ws0 = ws0 * 1.151;
				wg0 = wg0 * 1.151;
				wu0 = "MPH ";
			} else if (setunits == 2) {
				ws0 = ws0 * 1.852;
				wg0 = wg0 * 1.852;
				wu0 = "km/h";
			} else if (setunits == 3) {
				ws0 = ws0 * 0.514;
				wg0 = wg0 * 0.514;
				wu0 = "m/s ";
			} else {
				wu0 = "KT. ";
			}
			# short speed
			if (ws0 == 0) {
				shwsd0s = "Calm";
			} else if (ws0 > 0 && ws0 < 10) {
				shwsd0s = sprintf("%-3s%.0f", wd0, ws0);
			} else if (ws0 >= 10 && ws0 < 100) {
				shwsd0s = sprintf("%-2s%.0f", shwd0, ws0);
			} else if (ws0 >= 100) {
				shwsd0s = sprintf("%-1s%.0f", shwd0, ws0);
			}

		#output
		if (ws0 > 0) {
        		wds0s = sprintf ("Wind: %-3s%3.0f %s ", wd0, ws0, wu0);
            	} else {
                	wds0s = sprintf ("Wind: Calm        ");
            	}

		if (wg0 != 0) { wg0s = sprintf ("Gusts to %3.0f", wg0) }

		Fwdsg0 = 1; # Found

	}

	# Visibility group
	if ($i ~ /[0-9]?.?.SM/) {

		#check for fractional (eg. 2 1/2)
		i--;
		if ($i !~ /.*[A-Z].*/) {
			visx = $i;
		}
		i++;

		split($i, vx, "SM");

		#vis contains 1/2, 3/4, etc.
		if (vx[1] ~ /\//) {
			split(vx[1], vsx, "/");
			vcx = vsx[1] / vsx[2];
                	#round up instead of truncate
                	v0 = (vcx + visx + .05);
                	v0 = sprintf("%2.1f", v0);
		} else {
			v0 = vx[1];
			v0 = v0 + 0;
		}

		#TODO: Unit conversion
		#output
		v0u = "mi."
		v0s = sprintf ("Visib: %3s %s ", v0, v0u);

		Fv0 = 1; # Found
	}

	# Tmp/Dew/Hum + HI/WC group
	if ($i ~ /^.?..*[0-9]\/[0-9]*.?..$/ && !/....\/..\/../) {

		#swap M char with negative
		gsub(/M/, "-", $i);
		split($i, tdx, "/");

		rt0 = tdx[1];
		rd0 = tdx[2];

		# F, intended for calulcating heat index
		t0f = (tdx[1] * 9/5) + 32;
		d0f = (tdx[2] * 9/5) + 32;

		#C to F
		if (setunits == 1) {
			t0u = "F";
			t0 = (tdx[1] * 9/5) + 32;
			d0u = "F"
			d0 = (tdx[2] * 9/5) + 32;
		} else {
			t0u = "C"
			t0 = tdx[1];
			d0u = "C"
			d0 = tdx[2];
		}

		#drop the negative for printing out
		if (t0 < 0.5 && t0 >= -0.5) {
			t0 = 0;
		}
		if (d0 < 0.5 && d0 >= -0.5){
			d0 = 0;
		}

		#output
		if (setunits == 1) {
			t0s = sprintf ("Temp: %3.0f%s%s    ", t0, dval, t0u);
			d0s = sprintf ("Dewpoint:%3.0f%s%s", d0, dval, d0u);
		} else {
			t0s = sprintf ("Temp: %3.0f%s%s    ", t0, dval, t0u);
			d0s = sprintf ("Dewpoint:%3.0f%s%s", d0, dval, d0u);
		}

		# Humidity calculation
		svp = 6.11 * (10 ^ (7.5 * rt0 / (237.7 + rt0)))
		avp = 6.11 * (10 ^ (7.5 * rd0 / (237.7 + rd0)))
		h0 = (avp / svp)
		h0 = h0 * 100

		#output
		h0s = sprintf ("Humidity: %3.0f%%   ", h0);

		# Heat Index calculation

		hx0 = -42.379 + 2.04901523 * t0f + 10.14333127 * h0 - .22475541 * t0f * h0 - .00683783 * t0f * t0f - .05481717*h0*h0 + .00122874*t0f*t0f*h0 + .00085282*t0f*h0*h0 - .00000199*t0f*t0f*h0*h0

		#if the h0 is below 13% & temp between 82-112, then apply this adjustment
		if (h0 < 13) {
			if (t0f > 82 && t0f < 112) {
				aAhx0 = ((13-(h0))/4) * sqrt((17 - abs(t0f - 95)) / 17)
			} else { aAhx0 = 0 }
		} else { aAhx0 = 0 }

		#or if the h0 is above 85% & temp is between 80-87
		if (h0 > 85) {
			if (t0f > 80 && t0f < 87) {
				aBhx0 = (((h0)-85)/10) * ((87-t0f)/5)
			} else { aBhx0 = 0 }
		} else { aBhx0 = 0 }

		hx0 = hx0 + aAhx0 + aBhx0;

		# TODO: unit conversion
		if (setunits == 2) {
			hx0u = "C";
			hx0 = (hx0 - 32) * (5 / 9);
		} else {
			hx0u = "F";
		}

		if (setunits == 1) {
			if (t0f >= 79) { hx0s = sprintf("Heat Index:%3.0f%s%s", hx0, dval, hx0u) }
		} else if (setunits == 2) {
			if (t0f >= 79) { hx0s = sprintf("Heat Index:%3.0f%s%s", hx0, dval, hx0u) }
		} else {
			if (t0f >= 79) { hx0s = sprintf("Heat Index:%3.0f%s%s", hx0, dval, hx0u) }
		}

		# Wind Chill calculation

		wc0 = 35.74 + (0.6215 * t0f) - (35.75 * (ws0mph ^ .16)) + (0.4275 * t0f *(ws0mph ^ .16))

		# TODO: unit conversion
		if (setunits == 2) {
			wc0u = "C";
			wc0 = wc0 - 32 * (5 / 9);
		} else {
			wc0u = "F";
		}

		#wind speed handled as int to truncate, must be greater than 3mph for Wind Chill
		if (setunits == 1) {
			if (t0f < 50 && int(ws0mph) > 3) { wc0s = sprintf("Wind Chill:%3.0f%s%s", wc0, dval, wc0u) }
		} else if (setunits == 2) {
			if (t0f < 50 && int(ws0mph) > 3) { wc0s = sprintf("Wind Chill:%3.0f%s%s", wc0, dval, wc0u) }
		} else {
			if (t0f < 50 && int(ws0mph) > 3) { wc0s = sprintf("Wind Chill:%3.0f%s%s", wc0, dval, wc0u) }
		}

		Ftdh0 = 1; # Found
	}

	# Pressure group
	if ($i ~ /^A....$/) {
		split($i, px, "A");

		# TODO: unit conversion
		if (setunits == 1) {
			p0 = px[2] * .01;
		} else if (setunits == 2) {
			p0 = (px[2] * .01) * 33.86389;
		} else {
			p0 = px[2] * .01;
		}

		#output
		if (setunits == 1) {
			p0u = "in.";
			p0s = sprintf ("Barometric Pressure: %5.2f %s", p0, p0u);
		} else if (setunits == 2) {
			p0u = "hPa";
			p0s = sprintf ("Barometric Pressure: %5.0f %s", p0, p0u);
		} else {
			p0u = "in.";
			p0s = sprintf ("Barometric Pressure: %5.2f %s", p0, p0u);
		}

		Fp0 = 1; # Found
	}

		if(vis) {
			#print substr($i, RSTART, RLENGTH);
			#print visx, datt;
		}

    # Breaks out at RMK, TODO
    if ($i ~ /^RMK$/) { i = NF }

    }
} END {
	# Leftover cleanup work

	#printf ("%s",datt);

	if (length(shobs) != 0) { shobso = shobs }
    else if (length(shskyobs) != 0) { shobso = shskyobs }
	if (length(disploc) != 0) { dispout = disploc } else { dispout = code }

	if (Ftdh0 == 1) {
		sht0s = sprintf("%3.0f", t0);
	} else {
		sht0s = "";
	}


	# Begin output print

	if (json == 1) {
		# JSON output
		printf("{\n");
		
		# begin data
		printf("\t\"location\": \"%s\",\n", dispout);
		
		printf("\t\"observation\": {\n");

			printf("\t\t\"string\": \"");
				if (length(obs) != 0) { printf ("%s", obs) }
				else if (length(skyobs) != 0) { printf ("%s", skyobs) }
			printf("\",\n");
			printf("\t\t\"short\": \"%s\",\n", shobso);
			printf("\t\t\"icon\": \"%s\",\n", icoobs);

			if (length(obs) != "" && length(skyobs) != "") {
				printf("\t\t\"valid\": 1\n");
			} else {
				printf("\t\t\"valid\": 0\n");
			}

		printf("\t},\n");

		printf("\t\"temp\": {\n");

			printf("\t\t\"string\": \"%s\",\n", t0s);
			printf("\t\t\"fvalue\": %f,\n", t0);
			printf("\t\t\"svalue\": \"%3.0f\",\n", t0);
			printf("\t\t\"value\": %0.0f,\n", t0);
			printf("\t\t\"unit\": \"%s%s\",\n", dval, t0u);
			if (length(t0s) != 0) {
				printf("\t\t\"valid\": 1\n");
			} else {
				printf("\t\t\"valid\": 0\n");
			}

		printf("\t},\n");


		printf("\t\"heat\": {\n");

			if (length(hx0s) != 0) {
				printf("\t\t\"string\": \"%s\",\n", hx0s);
				printf("\t\t\"fvalue\": %f,\n", hx0);
				printf("\t\t\"svalue\": \"%3.0f\",\n", hx0);
				printf("\t\t\"value\": %0.0f,\n", hx0);
				printf("\t\t\"unit\": \"%s%s\",\n", dval, hx0u);
				printf("\t\t\"valid\": 1\n");
			} else {
				printf("\t\t\"string\": \"%s\",\n", hx0s);
				printf("\t\t\"fvalue\": 0.000000,\n", hx0);
				printf("\t\t\"svalue\": \"\",\n", hx0);
				printf("\t\t\"value\": 0,\n", hx0);
				printf("\t\t\"unit\": \"%s%s\",\n", dval, hx0u);
				printf("\t\t\"valid\": 0\n");
			}

		printf("\t},\n");

		printf("\t\"chill\": {\n");

			if (length(wc0s) != 0) {
				printf("\t\t\"string\": \"%s\",\n", wc0s);
				printf("\t\t\"fvalue\": %f,\n", wc0);
				printf("\t\t\"svalue\": \"%3.0f\",\n", wc0);
				printf("\t\t\"value\": %0.0f,\n", wc0);
				printf("\t\t\"unit\": \"%s%s\",\n", dval, wc0u);
				printf("\t\t\"valid\": 1\n");
			} else {
				printf("\t\t\"string\": \"%s\",\n", wc0s);
				printf("\t\t\"fvalue\": 0.000000,\n", wc0);
				printf("\t\t\"svalue\": \"\",\n", wc0);
				printf("\t\t\"value\": 0,\n", wc0);
				printf("\t\t\"unit\": \"%s%s\",\n", dval, wc0u);
				printf("\t\t\"valid\": 0\n");
			}


		printf("\t},\n");

		printf("\t\"dewpoint\": {\n");

			printf("\t\t\"string\": \"%s\",\n", d0s);
			printf("\t\t\"fvalue\": %f,\n", d0);
			printf("\t\t\"svalue\": \"%3.0f\",\n", d0);
			printf("\t\t\"value\": %0.0f,\n", d0);
			printf("\t\t\"unit\": \"%s%s\",\n", dval, d0u);
			if (length(d0s) != 0) {
				printf("\t\t\"valid\": 1\n");
			} else {
				printf("\t\t\"valid\": 0\n");
			}


		printf("\t},\n");
		
		printf("\t\"humidity\": {\n");

			printf("\t\t\"string\": \"%s\",\n", h0s);
			printf("\t\t\"fvalue\": %f,\n", h0);
			printf("\t\t\"svalue\": \"%3.0f\",\n", h0);
			printf("\t\t\"value\": %0.0f,\n", h0);
			printf("\t\t\"unit\": \"%%\",\n");
			if (length(h0s) != 0) {
				printf("\t\t\"valid\": 1\n");
			} else {
				printf("\t\t\"valid\": 0\n");
			}


		printf("\t},\n");

		printf("\t\"pressure\": {\n");

			printf("\t\t\"string\": \"%s\",\n", p0s);
			printf("\t\t\"fvalue\": %f,\n", p0);
			printf("\t\t\"svalue\": \"%5.2f\",\n", p0);
			printf("\t\t\"value\": %5.2f,\n", p0);
			printf("\t\t\"unit\": \"%s\",\n", p0u);
			if (length(p0s) != 0) {
				printf("\t\t\"valid\": 1\n");
			} else {
				printf("\t\t\"valid\": 0\n");
			}

		printf("\t},\n");

		printf("\t\"wind\": {\n");

			printf("\t\t\"string\": \"%s\",\n", wds0s);
			printf("\t\t\"short\": \"%s\",\n", shwsd0s);
			printf("\t\t\"sdirection\": \"%-3s\",\n", wd0);
			printf("\t\t\"direction\": \"%s\",\n", wd0);
			printf("\t\t\"fspeed\": %f,\n", ws0);
			printf("\t\t\"sspeed\": \"%3.0f\",\n", ws0);
			printf("\t\t\"speed\": %0.0f,\n", ws0);
			if (ws0 == 0) {
				printf("\t\t\"calm\": 1,\n", ws0);
			} else {
				printf("\t\t\"calm\": 0,\n", ws0);
			}
			printf("\t\t\"unit\": \"%s\",\n", wu0);
			if (length(wds0s) != 0) {
				printf("\t\t\"valid\": 1\n");
			} else {
				printf("\t\t\"valid\": 0\n");
			}

		printf("\t},\n");

		printf("\t\"gusts\": {\n");

			printf("\t\t\"string\": \"%s\",\n", wg0s);
			printf("\t\t\"fvalue\": %f,\n", wg0);
			printf("\t\t\"svalue\": \"%3.0f\",\n", wg0);
			printf("\t\t\"value\": %0.0f,\n", wg0);
			printf("\t\t\"unit\": \"%s\",\n", wu0);
			if (length(wg0s) != 0) {
				printf("\t\t\"valid\": 1\n");
			} else {
				printf("\t\t\"valid\": 0\n");
			}

		printf("\t},\n");

		printf("\t\"visibility\": {\n");

			printf("\t\t\"string\": \"%s\",\n", v0s);
			printf("\t\t\"fvalue\": %f,\n", v0);
			printf("\t\t\"svalue\": \"%3s\",\n", v0);
			printf("\t\t\"value\": %2.1f,\n", v0);
			printf("\t\t\"unit\": \"%s\",\n", v0u);
			if (length(v0s) != 0) {
				printf("\t\t\"valid\": 1\n");
			} else {
				printf("\t\t\"valid\": 0\n");
			}

		printf("\t},\n");

		printf("\t\"ceiling\": {\n");

			printf("\t\t\"string\": \"%s\",\n", c0s);
			printf("\t\t\"fvalue\": %3f,\n", c0);
			if (Fc0 == 1) {
				printf("\t\t\"svalue\": \"%3.0f00 %s\",\n", c0, c0u);
				printf("\t\t\"unlimited\": 0,\n");
				printf("\t\t\"value\": %0.0f00,\n", c0);
			} else {	
				printf("\t\t\"svalue\": \"Unlimited\",\n", c0);
				printf("\t\t\"unlimited\": 1,\n");
				printf("\t\t\"value\": %0.0f,\n", c0);
			}
			printf("\t\t\"unit\": \"%s\",\n", c0u);
			if (length(c0s) != 0) {
				printf("\t\t\"valid\": 1\n");
			} else {
				printf("\t\t\"valid\": 0\n");
			}

		printf("\t}\n");


		printf("}\n");

	} else if (outmode == 2) {
		#short obs
		#print "Location       \\F Weather   Wind"
		if (sht0s == "" && shobso == "" && shwsd0s == "") {
			printf("%-14.14s%3s %-9.9s %-4.4s\n", dispout, sht0s, "No Report", shwsd0s);
		} else {
			printf("%-14.14s%3s %-9.9s %-4.4s\n", dispout, sht0s, shobso, shwsd0s);
		}
	} else if (outmode == 3) {
		#print "  Conditions Across The Region"
		#printf ("Location            Weather   %sF\n", dval);
		if (shobso == "" && sht0s == "") {
			printf("%-20.19s%-9.9s%3s\n", dispout, "No Report", sht0s);
		} else {
			printf("%-20.19s%-9.9s%3s\n", dispout, shobso, sht0s);
		}
	} else {
		# By default print out CC data
		if (jsenable == 1) { newline = "\\n"; } else { newline = "\n" }
		if (jsenable == 1) {
			printf("var ldlraw = \"\n");
		}
		#long obs
		#print "================================"
		if (length(disploc) != 0) { printf("Conditions at %-19.19s%s", disploc, newline) } else { print code }
		if (length(obs) != 0) { printf ("%s%s", obs, newline) }
		else if (length(skyobs) != 0) { printf ("%s%s", skyobs, newline) } else { nacntr++ }
		if (length(t0s) != 0) { printf ("%s%s%s%s", t0s, hx0s, wc0s, newline) } else { nacntr++ }
		if (length(h0s) != 0 || length(d0s) != 0) { printf ("%s%s%s",h0s, d0s, newline) } else { nacntr++ }
		if (length(p0s) != 0) { printf ("%s%s", p0s, newline) } else { nacntr++ }
		if (length(wds0s) != 0) { printf ("%s%s%s", wds0s, wg0s, newline) } else { nacntr++ }
		if (length(v0s) != 0 || length(c0s) != 0) { printf ("%s%s%s", v0s, c0s, newline) } else { nacntr++ }
		if (nacntr == 6) { printf("") }
		#print "================================"
		if (jsenable == 1) { printf("\";\n"); }
		if (jsenable == 1) { printf("ldlseq = ldlraw.split(\"\\n\");\n"); }
		if (jsenable == 1) { printf("ldlseq = ldlseq.filter(function (el) {return el != \"\";});\n"); }
	}
}
